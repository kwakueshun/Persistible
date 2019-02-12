# Persistible
# Helper for Persisting `Codable` classes to file and retrieving them

Create a model object that conforms to `Codable` and `Hashable` and give an
appropriate `fileName` after conforming to `Persistible`
###### Example
```swift
struct Person: Codable, Hashable, Persistible {

    let name: String
    let age: Int
    let school: String

    static var fileName: String {
        return "person_data"
    }
}
```

Get instances of your object, for instance from the return of a network
call helper.

```swift
let sam = Person(name: "Samuel", age: 35, school: "Accra Academy")
let amy = Person(name: "Amy", age: 25, school: "Accra Girls")
let maame = Person(name: "Maame", age: 25, school: "Accra High")
```

To save to file for array, do:
```swift
do {
    try [sam, amy].saveToFile()
}
catch {
    print(error)
}
```

or save for single instance, do:
```swift
do {
    try sam.saveToFile()
}
catch {
    print(error)
}
```

To read your object from file, do one of the below:
You can use a do-catch block based on preference.
1. Single instance
```swift
    let person = try? Person.loadFromFile()
```

2. Array instance
```swift
    let people = try? Person.loadListFromFile()
```

3. Loads single or array wrapped inside a `PersistenceData` enum value based on what it finds. This is the preferred
usage.
```swift
    do {
        try Person.load { data in

            switch data {

            case .single(let val):
                print("\(val.name), \(val.age), \(val.school)")

            case .array(let values):
                print(values.compactMap { "\($0.name), \($0.age), \($0.school)" })
            }
        }
    }
    catch {
        print(error.localizedDescription)
    }
```
