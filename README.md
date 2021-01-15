# ArxivKit

Swift DSL wrapper for [arXiv API](https://arxiv.org/help/api/).

This project is not affiliated with [arXiv.org](https://arxiv.org). 

## Supported Platforms

Minimal version of Swift required for building the package is 5.3. Following platforms are supported:

- macOS (from v11.0)
- iOS, iPadOS, Mac Catalyst (from v14.0)
- Linux (tested on Ubuntu 20.04)

## Installation

To use in an Xcode project, add `https://github.com/ivicamil/ArxivKit.git` as package dependency as explained in [Apple developer documentation](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

In [package-based](https://swift.org/package-manager/) projects, add `ArxivKit` dependency to `Package.swift` as explained bellow: 

```swift
// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ProjectName",
    platforms: [],
    dependencies: [
        // Replace the version string with your own desired minimal version.
        .package(url: "https://github.com/ivicamil/ArxivKit.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "ProjectName",
            dependencies: ["ArxivKit"])
    ]
)
```

## Usage

### Networking

`ArxivKit` uses `URLSession` for sending API requests. It is strongly recommended to reuse a single session instance for multiple related tasks. For detailed information about creating, configuring and using `URLSession` and related APIs see [Apple Developer documentation for the class](https://developer.apple.com/documentation/foundation/urlsession). In many cases, including all the examples from this document, a session with default configuration is enough:

```swift
let session = URLSession(configuration: .default)
```
or

```swift
let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
```

`ArxivKit` defines convenience extension methods on `URLSession` and `ArxivRequest` that create `URLSessionDataTask` for sending arXiv API requests and parsing received response. In more advanced cases, clients can implement their own custom networking layer and still use this library as a Domain Specific Language for constructing `ArxivRequest` values. In that case, `ArxivParser` can be used for parsing raw API responses to `ArxivReponse` values.

### Arxiv Query

`ArxivQuery` type specifies different possible information that can be searched on [arXiv](https://arxiv.org). `ArxivQuery` conforms to `ArxivRequest` protocol and it can be used to create and run fetch tasks. Before fetching, an `ArxivRequest` can be configured with various modifier methods to define desired number of articles per page, sorting order and criterion etc.

`ArxivKit` enables construction of all the search queries available in Arxiv API. Articles can be searched for a term in any of the available fields, by arXiv subject or by publication and update dates. All the subjects are available as constants under following namespaces:

- `Physics`
- `Astrophysics`
- `CondensedMatter`
- `NonlinearSciences`
- `OtherPhysicsSubjects`
- `Mathematics`
- `ComputerScience`
- `QuantitativeBiology`
- `ElectricalEngineeringAndSystemsScience`
- `Statistics`
- `QuantitativeFinance`
- `Economy`

Queries are constructed by using an embedded Domain Specific Language created with Swift feature called [Result Builders](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md), that was first used in Apple's [SwiftUI Framework](https://developer.apple.com/xcode/swiftui/). The DSL enables creating arbitrarily complex query trees by using an intuitive syntax. 

After a query is constructed and configured, `fetch(using:completion:)` or other related methods can be used to construct and run a fetch task. If no error occurs, fetch task returns an `ArxivResponse`, a parsed arXiv API atom feed. The response stores various metadata and a list of `ArxivEntry` values. Each entry stores information about a single arXiv article, such as its title, abstract, authors, PDF link etc.

Bellow are some of the common use scenarios. For detailed explanation of all available APIs, see [ArxivKit Wiki](https://github.com/ivicamil/ArxivKit/wiki).

### Performing Search

```swift
term("electron").fetch(using: session) { result in
    switch result {
    case let .success(response):
        let articles = response.entries
        print("Found \(response.totalResults) articles")
        print()
        print(articles.map { $0.title }.joined(separator: "\n\n"))
    case let .failure(error):
        print("Could not fetch articles: \(error.localizedDescription)")
    }
}
```
### Simple Queries

```swift
term("dft")
term("dft", in: .title)
term("dft", in: .abstract)
term("Feynman", in: .authors)
term("20 pages", in: .comment)
term("AMS", in: .journalReference)

subject(Physics.computationalPhysics)

submitted(in: .past(.month))
lastUpdated(in: .past(5, unit: .day))
```

### Complex Queries

``` swift
all {
    any {
        term("dft", in: .title)
        term(#""ab initio""#, in: .title)
    }
    subject(Physics.computationalPhysics)
}
.excluding {
    term("conductivity", in: .title)
}
```

### Fetching Specific Articles

```swift
ArxivIdList("2101.02212", "2101.02215")
    .fetch(using: session) { result in
        // Do something with the result
    }
```

### Fetching All Versions of an Article

```swift
let entry: ArxivEntry = ...

ArxivIdList(ids: entry.allVersionsIDs)
    .fetch(using: session) { result in
        // Do something with the result
    }
```

### Paging Example

```swift
var currentResponse: ArxivResponse?

func fetchElectronArticles(startIndex i: Int) {
    term("electron")
        .itemsPerPage(20)
        .startIndex(i)
        .fetch(using: session) { result in
            switch result {
            case let .success(response):
                currentResponse = response
                print("Page \(response.currentPage) fetched.")
            case let .failure(error):
                // Deal with error
            }
        }
}

// Fetch the first page
fetchElectronArticles(startIndex: 0)

// When we are sure that the first page is fetched, we can fetch the second page
if let response = currentResponse, let secondPageIndex = response.nextPageStartIndex {
    fetchElectronArticles(startIndex: secondPageIndex)
}
```

### Configuring Request

```swift

term("electron")
    .sorted(by: .relevance)
    .sortingOrder(.descending)
    .itemsPerPage(20)
    .startIndex(60)
    .fetch(using: session) { result in
        // Do something with the result
    }
```

## License

`ArxivKit` is released under [MIT license](LICENSE). For terms and conditions of using the arXiv API itself see [arXiv API Help](https://arxiv.org/help/api).
