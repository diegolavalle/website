let post_20240722_counter_as_a_service = Post("/posts/2024-07-22-counter-as-a-service", "Counter as a Service", .none, "DL", "2024-07-22T12:00:00Z", (.swiftUI, .swiftConcurrency), ["Actors", "Swift", "SwiftUI", "Service"], discussion: 8) { """
Counters are simple in terms of functionality. We can implement a counter using a mere integer variable, a class or a struct. Building UI for these implementation variants is quite straightforward but what happens when we throw actors in the mix?

Actors are great for implementing services. As it turns out modeling a basic counter as a service helps us anticipate many of the challenges of integrating an asynchronous API into a SwiftUI application.

To make things more interesting let's imagine we need to manage a set of distinct counters. We start by recapping how we would do this using classes.

```swift
@MainActor @Observable class Counter: Identifiable {
    var value = 0
    func increment() { value += 1 }
}

@MainActor @Observable class CountersModel {
    var counters = [Counter]()
    func addNew() { counters.append(.init()) }
}

struct ContentView: View {

    var model = CountersModel()

    var body: some View {
        NavigationStack {
            List(model.counters) { counter in
                NavigationLink("\\(counter.value)") {
                    CounterView(counter: counter)
                }
            }
            .toolbar {
                Button("Add New") { model.addNew() }
            }
            .navigationTitle("Counters")
        }
    }
}

struct CounterView: View {

    var counter: Counter

    var body: some View {
        Form {
            LabeledContent("Value", value: "\\(counter.value)")
            Button("Increment") { counter.increment() }
        }
        .navigationTitle("\\(counter.id)")
    }
}
```

By annotating our classes with `@Observable` there is little else we need to do to gain the functionality that we wanted. Each counters displays its current state appropriately within the list and can be independently incremented.

Now what if we want to use a struct instead and benefit from their value semantics? SwiftUI makes this easy for us with the `@Bindable` and `@Binding` property wrappers: 

```swift
@MainActor struct Counter: Identifiable {
    let id: Int // We'll need an explicit identifier.
    var value = 0
    mutating func increment() { value += 1 }
}

@MainActor @Observable class CountersModel {
    var counters = [Counter]()
    func addNew() {
        counters.append(.init(id: counters.count)) // Using the index as ID.
    }
}

struct ContentView: View {

    // We'll need to generate a binding for each counter.
    @Bindable var model = CountersModel()

    var body: some View {
        NavigationStack {
            // Iterating bindings instead, the rest of the view is untouched.
            List($model.counters) { counter in
                NavigationLink("\\(counter.wrappedValue.value)") {
                    CounterView(counter: counter)
                }
            }
            .toolbar {
                Button("Add New") { model.addNew() }
            }
            .navigationTitle("Counters")
        }
    }
}

struct CounterView: View {

    // We'll take a binding to our model instead, the rest is untouched.
    @Binding var counter: Counter

    var body: some View {
        Form {
            LabeledContent("Value", value: "\\(counter.value)")
            Button("Increment") { counter.increment() }
        }
        .navigationTitle("\\(counter.id)")
    }
}
```

As we can see the UI code remains largely unchanged.

Now for the main act, what if we have the following seemingly innocent implementation of our beloved counter?

```swift
actor CounterService {
    var value = 0
    func increment() { value += 1 }
}
```

Apparently there is nothing to it except for replacing `class` keyword for `actor`. The result is even marginally less verbose than its `struct` counterpart and yet it is more powerful.

See actors help us eliminate potential data races introduced by even the most trivial of functions like our `CounterService.increment()` above. The Swift 6 language mode helpfully identifies these potential races for us giving us a chance to do the right thing and while we are at it, unlock the power of parallel computing.

Because all UI code runs on the _main actor_ we are going to need some glue to be able to call our now asynchronous functions and properties in each actor instance.

The solution presented below introduces a `CounterModel` to wrap calls to each individual counter service, much like we would for remote endpoint calls in Web API clients. 

```swift
@MainActor @Observable class CounterModel: Identifiable {

    let id: Int // Like with struct, we need an explicit ID.
    var value = Int?.none // We may not have this value at first.
    let service: CounterService // The service we are wrapping/

    // To get a copy of the counter state we need to perform an asynchronous call to the actor's value property.
    func refresh() async { value = await service.value }

    func increment() async {
        await service.increment()
        await refresh() // After incrementing, we need to refresh our copy of the counter state for displaying.
    }
}

@MainActor @Observable class CountersModel {

    var counters = [CounterModel]()

    func addNew() async {
        counters.append(.init(id: counters.count, service: .init()))
        await counters.last!.refresh() // Every time we add a counter, we refresh it to get its state.
    }
}

struct ContentView: View {

    var model = CountersModel()

    var body: some View {
        NavigationStack {
            List(model.counters) { counter in
                NavigationLink("\\(counter.value ?? 0)") {
                    CounterView(counter: counter)
                }
            }
            .toolbar {
                Button("Add New") { Task {
                    await model.addNew()
                } }
            }
            .navigationTitle("Counters")
        }
    }
}

struct CounterView: View {

    var counter: CounterModel

    var body: some View {
        Form {
            if let value = counter.value {
                LabeledContent("Value", value: "\\(value)")
                Button("Increment") { Task {
                    await counter.increment()
                } }
            } else {
                ProgressView() // We are now prepared for distributed/remote calls.
            }
        }
        .navigationTitle("\\(counter.id)")
    }
}
```

The additional model allows us to keep most of the remaining logic intact. It is worth noting that because calls are now `async`, that means we need to be prepared for the lapse while the required data is not yet available to us for presentation.

Lastly this technique enables us to be prepared for an eventual remote or even [distributed](https://www.swift.org/blog/distributed-actors/) versions of the service.
""" } summary: { """
A simple counter service implemented as a Swift Actor poses some challenges when it comes to building a UI around it.
""" }
