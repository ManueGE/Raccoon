# Raccoon

A nice [**Alamofire**](https://github.com/Alamofire/Alamofire) serializer that convert JSON into **CoreData** or [**Realm**](https://github.com/realm/realm-cocoa) objects.

Raccoon is a set of pods that simplifies the connection between **Alamofire**, **CoreData** and **Realm**: 

* **Raccoon/CoreData**: Serialize JSON responses from **Alamofire** into `NSManagedObject` instances. 
* **Raccoon/Realm**: Serialize JSON responses from **Alamofire** into **Realm** `Object` instances. 
* **Raccoon/Client**: Client that put together **Alamofire**, **Raccoon** and [**PromiseKit**](https://github.com/mxcl/PromiseKit). 

## Installing Raccoon

##### Using CocoaPods

Add one of more of the following to your `Podfile`:

````
pod 'Raccoon/CoreData'
````

``` 
pod 'Raccoon/Realm'
````

``` 
# If you add this pod, you'll probably want to add one of the previous pod as well.
pod 'Raccoon/Client'
````

Then run `$ pod install`.

And finally, in the classes where you need **Raccoon**: 

````
import Raccoon
````

**Note**: If you just write `pod 'Raccoon'` the CoreData version and the Client will be used.

If you don’t have CocoaPods installed or integrated into your project, you can learn how to do so [here](http://cocoapods.org).

--------------------
# Serialization
## Usage
### Getting started
Using **Raccoon** is quite simple. Let's suposse you have an `User` model. This is the **CoreData** version:

````
class User: NSManagedObject {
}

extension User {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var birthday: NSDate?
}

````

and this one the **Realm** one:

````
class User: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var birthday: NSDate! = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
````

If we have an **Alamofire** request that returns a single object, we will do:

````
myRequest.response(User.self, context: context) { (response) in
   
    if response.result.isSuccess {
        let user = response.result.value! // this is an User instance
        print("\(user)")
    }
    
}

````

As you see, we need to pass a `context` to perform the insertion of the data. The context will be a `NSManagedObjectContext` for the **CoreData** version and a `Realm` in the **Realm** version. The object is nicely inserted into the given context. 

If we have another request that returns an array of `User` instances, the we will do:

````
myRequest.response([User].self, context: context) { (response) in
   
    if response.result.isSuccess {
        let users = response.result.value! // this is an Array of User instances
        print("\(users)")
    }
}

````
Again, all the returned objects are inserted into the given context.


### Serializing notes

There are some clarification to be done about how the objects are serialized.
#### CoreData
`NSManagedObject` instances are serialized using the **wonderful** library **Groot**. For this reason, **Groot** is a dependency of **Raccoon**. If you are not familiar with it, take a look into the [**Groot** documentation](https://github.com/gonzalezreal/Groot) in order to learn which steps do you need yo make your objects serializable. 

#### Realm
**Raccoon** make use of the built-in JSON serialization by **Realm**:

````
let json = ["id": 10, "name": "Manue"]
realm.create(User, value: json, update: true)
````

So, if all the keys and types of your json match the names of your properties, you are done and you don't have to provide any additional configuration. 

However, most of times this is not the case so, in addition, **Raccoon** provides a set of methods to achieve the serialization. 

If you just need to rename the keys and/or apply a transformation (as convert a string to a date), you can override this one: `class var keyPathsByProperties: [String: KeyPathConvertible]?`. As an example, in our `User` model, if the JSON we get from the server is this way:

````
{
    "id": 1,
    "username": "manue",
    "birthday_date": "1983-18-11"
}

````

we must override that property this way

````
class User: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var birthday: NSDate! = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
        
    override class var keyPathsByProperties: [String: KeyPathConvertible]? {
        return [
            "id": "id",
            "name": "username",
            "birthday": KeyPathTransformer(keyPath: "birthday_date", transformer:DateConverter.date)
        ]
    }
}

struct DateConverter {
    static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
   
    static func dateFromString(string: String) -> NSDate {
        return formatter.dateFromString(string)!
    }
}
````

As you can see, the keys of the dictionary are the name of the properties of the model. The values are the keypath of the JSON where the right value is. They can be `String` (if not any transformation is required) or a `KeyPathTransformer` (where you must set the keypath and the transformer). 

This should be enough in most of the cases, but if you need more customization, just override `class func convertJSON(json: [String: AnyObject]) -> [String: AnyObject]` where you get the JSON received from the server and you must return the JSON expected by **Realm**.

A final note about **Realm**: all the instances used by raccoon that declare a **PrimaryKey** will be updated. The ones that do not declare it will be just inserted.


### Wrapper
Sometimes, our models are not sent directly by the server responses. Instead they are wrapped into a bigger json. For example, let's suppose that we have a response for our login request where we get the user info, the access token and the validity date for the token:

````
{
    "token": "THIS_IS_MY_TOKEN",
    "validity": "2020-01-01",
    "user": {
    	"id": "1",
    	"name": "manue",
    }
}
```` 

To handle this, we have to create a new class or structure and adopt the `Wrapper` protocol. For example:

````
class LoginResponse: Wrapper {
    
    var token: String!
    var validityDate: NSDate!
    var user: User!
    
    // MARK: Wrapper protocol methods
    required init() {}
    
    func map(map: Map) {
        token <- map["token"]
        validityDate <- (map["validity"], DateConverter.dateFromString)
        user <- map["user"]
    }
}
````

The `Wrapper` protocol includes a required init without parameters and the `map()` function. 

The map function must use the same syntax as the example shows, by using the `<-` operator. The right term of the operator might include a transformer if the data needs to be transformed. If the var at the left of the operator is a `NSManagedObject`, `[NSManagedObject]`, a `Object`, a `[Object]` or a `Wrapper` it is serialized. If is other kind of object, it is returned in the same format that it comes from the json (or its transformed value). The string inside the brackets is the keypath where we will find the object inside the JSON.

#### Root keypath
There is a special case when we want to map to an object which is in the root level of the JSON. For example, if we have a `Pagination` object that implements `Wrapper`:

````
class Pagination: Wrapper {
	var total: Int = 0
	var current: Int = 0
	var previous: Int?
	var next: Int?	
	
	// MARK: Wrapper protocol methods
    required init() {}
    
    func map(map: Map) {
        total <- map["total"]
        current <- map["current"]
        previous <- map["previous"]
        next <- map["next"]
    }
}

````
And the response that we have is:

````
{
	"total": 100,
	"current": 3,
	"previous": 2,
	"next": 4,
	
	"users": [
		{"id": "1", "name": "manue"},
		{"id": "2", "name": "ana"},
		{"id": "3", "name": "lola"}
	]
}
````

Look that the pagination is not under any key, but it is in the root of the JSON. In this case, we can create the next object:

````
class UserListResponse: Wrapper {
	var pagination: Pagination!
	var users: [User]!
	
	// MARK: Wrapper protocol methods
    required init() {}
    
    func map(map: Map) {
        pagination <- map[.Root]
        users <- map["users"]
    }
}

````

### Data Converter
Sometimes, the data we get from the server is not in the right format. It could happens that we have for instance a XML where one of its fields is the JSON we have to parse (yes, I've found things like these 😅). In order to solve this issues, **Raccoon** provides a way to pre-process the data before being serialized:

````
public typealias ResponseConverter = NSData? throws -> NSData?
````

We can pass it as a parameter in the `response()` method: 

````
myRequest.response([User].self, context: context, converter: MyConverterMethod) { (response) in
   
    if response.result.isSuccess {
        let users = response.result.value! // this is an Array of User instances
        print("\(users)")
    }
}

````

if the `ResponseConverter` throws a `NSError`, it will be propagated in the response, so the request will fail. You can take advantage to perform internal validation to your `request`.

--------
# RaccoonClient

**Note**: To use this library you should be familiar with **PromiseKit**. If you are not, take a look into the [**PromiseKit** documentation site](http://promisekit.org).

## The Client
`Client` is the main component of the library. Is the responsible to perform the request and return the response as a `Promise`. 

To create a simple client you can do:

````
let client = Client(baseURL: "http://host.com/", context: context)
````

where `context` is a `NSManagedObjectContext` if we want to insert objects into CoreData or a `Realm` if we are using **Realm**.

we can add a third parameter:

````
let client = Client(baseURL: "http://host.com/", context: context, responseConverter: converter)
````
where `converter` is a `ResponseConverter` as explained before. 


### Sending requests

If we have a `Request` that return an object `User`, we can send the request this way:

````
client.request(myRequest, type: User.self)
````

This will return a `Promise<User>`.

If our request returns an array of `User` instances:

````
client.request(myRequest, type: [User].self)
````

We can send requests that return one of the following types:

* `NSManagedObject`
* `[NSManagedObject]`
* `Object`
* `[Object]`
* `Wrapper`

we can also send a request that return an empty promise: `Promise<Void>` this way:

````
client.request(request)
````


## Endpoint
Raccoon provides the `Endpoint` class and the `EndpointConvertible` protocol to simplify the request creation. 

And endpoint is something quite similar to a request. It could have a method, encoding and some parameters or headers. But instead of having an url it just have a path. 

`Endpoint` has the following method:

````
public func request(withBaseURL URL: String) -> Request
````

which creates a `Request` with all the parameters of the `Endpoint` and append its path to the given base URL.

For example:

````
let client = Client(baseURL: "http://host.com", context: context)

let loginEndpoint = Endpoint(method: .POST, 
							  path:"/auth/login",
							  parameters: ["user": "manue", "pass": "my_pass"],
							  encoding: .JSON,
							  headers: [:])

client.request(loginEndpoint, type: LoginResponse.self)
							  					
````

We can override the `Endpoint` class to add some custom parameters as authentication headers, api keys, perform validations or [log the request](http://github.com/ManueGE/AlamofireActivityLogger). For instance:

````
class MyAppEndpoint: Endpoint {
    
    override init(method: Alamofire.Method, path: String, parameters: [String : AnyObject], encoding: Alamofire.ParameterEncoding, headers: [String : String]) {
        
        // adds an api key
        var parameters = parameters
        parameters["api_key"] = apiKey
        
        // add a auth header
        var headers = headers
        headers["Authentication"] = "Bearer MY_TOKEN"
        
        super.init(method: method, path: path, parameters: parameters, encoding: encoding, headers: headers)
    }
    
    override func request(withBaseURL URL: String) -> Request {
        
        // we add aditional validations
        let request = super.request(withBaseURL: URL)
        return request
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .log()
    }
}
````

            
### EndpointConvertible

Finally we have the `EndpointConvertible` protocol. Every object that conform the `EndpointConvertible` protocol must have the following property:

````
var endpoint: Endpoint { get }
````

This allow us to create endpoints using the **Router** approach described in **Alamofire** documentation. The example before can be now written this way:

````
enum LoginRouter: EndpointConvertible {
    case Login(user: String, password: String)
    
    var endpoint: Endpoint {
        switch self {
        case let .Login(user, password):
            return Endpoint(method: .POST,
                            path:"/auth/login",
                            parameters: ["user": user, "pass": password],
                            encoding: .JSON)
        }
    }
}
````

and then:

````
let login = LoginRouter.Login(user: "manue", password: "my_pass")
client.request(login, type: LoginResponse.self)
							  					
````


--------


## Contact

[Manuel García-Estañ Martínez](http://github.com/ManueGE)  
[@manueGE](https://twitter.com/ManueGE)

## License

Raccoon is available under the [MIT license](LICENSE.md).