enum Category: String, CaseIterable {
    case swiftUI, swiftServerSide, contentManagement, swiftConcurrency, xcode, devOps, standardLibrary, restAPI

    var name: String {
        switch(self) {
        case .swiftUI:
            return "SwiftUI"
        case .swiftServerSide:
            return "Server-Side Swift"
        case .contentManagement:
            return "Content Management"
        case .swiftConcurrency:
            return "Swift Concurrency"
        case .xcode:
            return "Xcode"
        case .devOps:
            return "DevOps"
        case .standardLibrary:
            return "Standard Library"
        case .restAPI:
            return "REST APIs"
        }
    }
}
