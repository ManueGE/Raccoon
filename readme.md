# Raccoon

A nice **Alamofire** serializer that convert JSON into **CoreData** or **Realm** objects.

## Installing Raccoon

##### Using CocoaPods

Add the following to your `Podfile`:

````
pod 'RaccoonCoreData'

````

and/or

``` 
pod 'RaccoonRealm'
````

Then run `$ pod install`.

If you don’t have CocoaPods installed or integrated into your project, you can learn how to do so [here](http://cocoapods.org).

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
`NSManagedObject` instances are serialized using the **wonderful** library **Groot** by [Guillermo González](https://github.com/gonzalezreal). For this reason, **Groot** is a dependency of **Raccoon**. If you are not familiar with it, take a look into the [**Groot** documentation](https://github.com/gonzalezreal/Groot) in order to learn which steps do you need yo make your objects serializable. 

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



## Contact

[Manuel García-Estañ Martínez](http://github.com/ManueGE)  
[@manueGE](https://twitter.com/ManueGE)

## License

Raccoon is available under the [MIT license](LICENSE.md).