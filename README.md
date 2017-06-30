# Raccoon

**Raccoon** is a set of protocols and tools that puts together [**Alamofire**](https://github.com/Alamofire/Alamofire), [**PromiseKit**](https://github.com/mxcl/PromiseKit) and **CoreData**.

Internally, Raccoon uses [**Groot**](https://github.com/gonzalezreal/Groot) and [**AlamofireCoreData**](https://github.com/ManueGE/AlamofireCoreData) to serialize JSON into the CoreData objects, so you will need to be familiar with these libraries.

Raccoon is built around:

- **Alamofire 4.0.x** 
- **PromiseKit 4.0.x** 
- **Groot 2.0.x** 
- **AlamofireCoreData 1.0.x** 

With Raccoon you'll be able to perform HTTP request as easy as this:

````swift
let client = Client(context: context)
client.enqueue(userEndpoint)
    .then { (user: User) in
        print(user) // At this point, your user is already inserted in your context
    }
    .catch { error in
        print(error)
}
````

## Installing Raccoon

### Using CocoaPods

Add the following line to your `Podfile`:

````ruby
pod 'Raccoon'
````

Then run `$ pod install`.

And finally, in the files where you need **Raccoon**: 

````swift
import Raccoon
````

If you don’t have CocoaPods installed or integrated into your project, you can learn how to do so [here](http://cocoapods.org).

-

# Usage

## Intro

Raccoon basically consist in two protocols, `Client` and `Endpoint`. 

- `Client` instances are responsible to enqueue http request and return them in the shape of promises. Clients need, at least, a base url (to build the requests) and a `NSManagedObjectContext` where the responses will be inserted.
- `Endpoint` instances are objects that provides information to build the request that will be sent by the clients. Endpoints just must implement one method, `request(withBaseURL:)` which will return the full request built with the given base url. 

Before being ready to work with Raccoon, you should be familiar with:

- [**PromiseKit**](https://github.com/mxcl/PromiseKit): At least, you should be familiar with basic `Promise` handling: `then`, `catch`, `recover`
- [**Groot**](https://github.com/gonzalezreal/Groot): It is used to serialize JSON into CoreData, so your entities must fullfill its requirements.  
- [**AlamofireCoreData**](https://github.com/ManueGE/AlamofireCoreData): At least, you should read about `Wrapper` (to serialize `NSManagedObject` instances from bigger JSONs) and `Many` (to serialize an array of objects). 



## Getting started

To explain how use Raccoon, we are going to build a simple example.

Let's suppose we have an API with 2 methods:

- `GET http://sampleapi.com/users/`: Get a list of users.
- `GET http://sampleapi.com/users/<id>/`: Get the detail of the given user. 

We also have to add an api key as a header in the requests. 

To modelize the response, we have our `NSManagedObject` subclass called `User` which has been prepared to being serialized using [**Groot**](https://github.com/gonzalezreal/Groot).

### Creating the client

The `Client` protocol has two required fields:

- `context: NSManagedObjectContext`: The context used to insert the responses. 
- `baseURL: String`: The base url of the api. 

So, we will create our own `Client` class conforming this protocol: 

````swift

import Raccoon

final class Client: Raccoon.Client {

    let baseURL: String = "http://sampleapi.com/"
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}
````

That's all, now we can create a client by doing: 

````swift
let client = Client(context: aContext)
````

### Creating the endpoint

The `Endpoint` protocol just have one method: 

````swift
func request(withBaseURL baseURL: String) -> DataRequest
````

which is called from the client to build the request. 

In our example, we will create a `Endpoint` subprotocol to helping us to build the actual endpoints: 

````swift
protocol AppEndpoint: Endpoint {
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var params: Parameters? { get }
    var encoding: Alamofire.ParameterEncoding { get }
}

extension AppEndpoint {
    func request(withBaseURL baseURL: String) -> DataRequest {
        let url = URL(base: baseURL, path: path)!
        
        let headers: HTTPHeaders = ["APIKEY": "MY API KEY"]
        
        return Alamofire.request(url,
                                 method: method,
                                 parameters: params,
                                 encoding: encoding,
                                 headers: headers)
    }
}
````

Some notes: 

- First we build the URL from the baseURL and the endpoint path. To build the URL we use a Raccoon extension for `URL`.
- Next we add the api key to the headers. 
- We build the request using the info provided by the endpoint and return it. 

After we have our protocol, we can create the endpoints.

````swift
enum UserEndpoint: AppEndpoint {
    case list
    case detail(id: Int)
    
    // MARK: AppEndpoint
    var method: Alamofire.HTTPMethod { return .get }
    var encoding: Alamofire.ParameterEncoding { return JSONEncoding() }
    var params: Parameters? { return nil }
    
    var path: String {
        switch self {
        case .list:
            return "users"
        case let .detail(id):
            return "users/\(id)/"
        }
    }
}
````

Now, we are ready to send the requests.

### Enqueueing requests

Once we have the `Client` and the `Endpoint`, enqueue the request is very easy: 


````swift
let client = Client(context: context)

client.enqueue(UserEndpoint.list)
.then { (users: Many<User>) in
    print(users)
}
.catch { error in
    print(error)
}

client.enqueue(UserEndpoint.detail(id: 1))
.then { (user: User) in
    print(user)
}
.catch { error in
    print(error)
}
````

#### Cancellable enqueue. 

If you want to cancel a request manually, you can use the `cancellableEnqueue` methods. They return an instance of `Cancellable`, which contains a `Promise` and a `cancel()` method:

````swift
let client = Client(context: context)

let cancellable: Cancellable<Many<User>> = client.cancellableEnqueue(UserEndpoint.list)

cancellable.promise
.then { (users: Many<User>) in
    print(users)
}
.catch { error in
    print(error)
}


// ... later on

cancellable.cancel()

````

## Advanced usage

In the previous example, we used Raccoon in its simplest stage. It allows some additional configuration to adapt itself to your REST API design. 

### Wrapper responses
Let's think we have another call to our api where we perform a login:

````
POST http://sampleapi.com/login/ 
````

The response of this requests is this json:

````json
{
    "token": "authtoken",
    "user": {"id": 1, "name": "manue"}
}
````

In this response, we have two parts, one object to be stored "as is" (the token) and a object to be inserted in the context (the user). 

To handle with this, we create a new object that conforms with [AlamofireCoreData Wrapper protocol](https://github.com/ManueGE/AlamofireCoreData#using-wrapper):

````swift
struct LoginResponse: Wrapper { 
    var token: String!
    var user: User!
    
    init() {}
    
    mutating func map(_ map: Map) {
        token <- map["token"]
        user <- map["user"]
    }
}
````

Now, we can create a new endpoint: 

````swift
struct LoginEndpoint: RestEndpoint {
    let username: String
    let password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    // MARK: AppEndpoint
    var path = "login/"
    var method: Alamofire.HTTPMethod = .post
    var encoding: Alamofire.ParameterEncoding = JSONEncoding()
    var params: Parameters? { 
        return ["username": username, "password": password] 
    }
}    
````

And then enqueueing it: 

````swift
let client = Client(context: context)

client.enqueue(LoginEndpoint(username: "username", password: "password")
.then { (response: LoginResponse) in
    print(response.token) // Here you can save your token in the defaults if needed
    print(response.user) // User already inserted in the context
}
.catch { error in
    print(error)
}
````

### Custom json serialization
In some cases, the data we get from the server is not in the right format. It could even happens that we have a XML where one of its fields is the JSON we have to parse (yes, I've found things like those 😅). In order to solve this issues, the `Client` protocol has an additional optional var that you can use to transform the response into the JSON you need: 

````swift
var jsonSerializer: DataResponseSerializer<Any>
````

`jsonSerializer ` is just a `Alamofire.DataResponseSerializer<Any>`. You can build your serializer as you want; the only condition is that it must return the JSON which you expect and which can be serialized by **Groot**.

For getting more info about how to build this serializer, please read this section of the [AlamofireCoreData documentation](https://github.com/ManueGE/AlamofireCoreData#transforming-your-json)

### Customising the requests

The `Request` provided by the `Endpoint` can be improved in the client side by using the following `Client` optional method:

````swift
func prepare(_ request: DataRequest, for endpoint: Endpoint) -> DataRequest
````

For example, we can add a validator and [a logger for your requests](http://github.com/ManueGE/AlamofireActivityLogger):

````swift
func prepare(_ request: DataRequest, for endpoint: Endpoint) -> DataRequest {
    return request
        .validate()
        .log()
}
````
 

### Processing the promise

Let's suppose we want to save the managed object context every time a request finish successfully. We could add this to every request:

````swift
client.enqueue(endpoint)
  .then { object: User in
     try client.context.save()
  }
````

This is not great, you would have to add it to every request. Instead, you can make use of one of the optional methods of the `Client` protocol: 

````swift
func process<T>(_ promise: Promise<T>, for endpoint: Endpoint) -> Promise<T>
````

This method is called by the client before return the `Promise`. By default it returns the promise itself. 

In our example, you just have to add these lines to your `Client`:

````swift
func process<T>(_ promise: Promise<T>, for endpoint: Endpoint) -> Promise<T> {
    return promise.then { response -> T in
        try self.context.save()
        return response
    }
}
````

You can do whatever you need with your promise on this method, for example `recover` from some errors or show/hide the network indicator of the status bar.

-

## License

Raccoon is available under the [MIT license](LICENSE.md).

## Contact
[Manuel García-Estañ Martínez](http://github.com/ManueGE)  
[@manueGE](https://twitter.com/ManueGE)
