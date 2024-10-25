let post_20240924_heterogeneous_json_arrays = Post("/posts/2024-09-24-heterogeneous-json-arrays", "Heterogeneous JSON Arrays", .none, "DL", "2024-09-24T12:00:00Z", (.standardLibrary, .restAPI), ["JSON", "Swift", "Codable", "enum"], discussion: 9) { """

As consumers of RESTful APIs we sometimes encounter JSON responses containing mixed arrays. In Swift arrays must have a single content type, so how can we parse a collection of heterogeneous elements? A solution involving enums with associated values may just be the key.

# JSON mixed arrays

Because JSON is not strongly typed it can represent lists of objects with diverse structures, like this array mixing passports and driver's licenses:

```json
[
  {
    "country" : "United States",
    "fullName" : "Olivia Rodrigo",
    "passportNumber" : "ABC123"
  },
  {
    "birth" : -63114076800,
    "firstName" : "Olivia",
    "lastName" : "Rodrigo",
    "licenseNumber" : 123456
  }
]
```

# Swift mixed arrays

We can represent each identification type with its own `struct` while having each of them be automatically decodable and encodable into standard JSON format:

```swift
struct Passport: Equatable, Codable {
    var passportNumber: String
    var fullName: String
    var country: String
}

struct DriversLicense: Equatable, Codable {
    var firstName: String
    var lastName: String
    var licenseNumber: Int
    var birth: Date
}
```

In Swift if we wanted to mix passports and licenses in an array we would have to wrap those types with an `enum`. Each case of the enumeration should have an associated value of the corresponding identification structure:

```swift
enum Identification: Equatable, Codable {
    case passport(Passport), driversLicense(DriversLicense)
}
```

Simple enough. We even get `Codable` support out of the box synthesized by the compiler. But what kind of JSON representation would we get our of an identifications list?


# Encoding mixed arrays

We declare an array in Swift and encode to see what happens:

```swift
let passport = Identification.Passport(passportNumber: "ABC123", fullName: "Olivia Rodrigo", country: "United States")
let driversLicense = Identification.DriversLicense(firstName: "Olivia", lastName: "Rodrigo", licenseNumber: 123456, birth: .distantPast)

let identifications = [Identification.passport(passport), .driversLicense(driversLicense)]

var encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

let data = try encoder.encode(identifications)
print(String(data: data, encoding: .utf8)!)
```

The resulting document will look exactly like this:

```json
[
  {
    "passport" : {
      "_0" : {
        "country" : "United States",
        "fullName" : "Olivia Rodrigo",
        "passportNumber" : "ABC123"
      }
    }
  },
  {
    "driversLicense" : {
      "_0" : {
        "birth" : -63114076800,
        "firstName" : "Olivia",
        "lastName" : "Rodrigo",
        "licenseNumber" : 123456
      }
    }
  }
]
```

Note how by default Swift uses each enumeration case as key and then another positional key for the associated value. That is quite a departure from what we wanted to be able to parse initially.
 
# Custom JSON format encoding

We can override the `encode(to:)` method to get the format we want:

```swift
enum Identification: Equatable, Codable { …

    func encode(to encoder: Encoder) throws {
        switch self {
        case .passport(let passport):
            try passport.encode(to: encoder)
        case .driversLicense(let driversLicense):
            try driversLicense.encode(to: encoder)
        }
    } …
```

Simply forwarding the task to the corresponding associated struct we get an output matching our original JSON example.

# Custom JSON decoding

To decode from the same custom format we need to implement the `init(from:)` initializer. We will arbitrarily try to decode as `Passport` first, then `DriversLicense` and if we can't we will throw a type mismatch error: 

```swift
enum Identification: Equatable, Codable { …

    init(from decoder: Decoder) throws {
        self = if let passport = try? Passport(from: decoder) {
            .passport(passport)
        } else if let driversLicense = try? DriversLicense(from: decoder) {
            .driversLicense(driversLicense)
        } else {
            throw DecodingError.typeMismatch(Self.self, .init(codingPath: decoder.codingPath, debugDescription: "Could not decode as either Passport or DriversLicense."))
        }
    } …
```

# Conclusion

This technique is useful for times when we do not control the format of the data that we need to parse but it's also useful in Swift world as it allows us to combine different unrelated types in one array. Furthermore, we ourselves could want to encode our `enum`s in a more compact way than the compiler's default.

""" } summary: { """
Decoding heterogeneous JSON arrays with Swift enums and associated values.
""" }
