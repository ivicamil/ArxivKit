# ArxivKit

Swift DSL wrapper for arXiv API.

This project is not affiliated with [arXiv.org](https://arxiv.org). 

## Supported Platforms

- macOS
- iOS, iPadOS, Mac Catalyst
- Linux (tested on Ubuntu 20.04)

## Usage

### Arxiv Session

`ArxivSession` object enapsulates network communication and keeps track of individual fetch tasks. It is strongly recomended to reuse a single session instance for multiple related tasks or even a single instance for the entire app or command line tool. Create and retain a session object by calling its initialser:

```swift
let session = ArxivSession()
```

Under the hood, `ArxivSession` uses a `URLSession` instance which can be configured by providing a custom `URLSessionConfiguration` object to `ArxivSession` initialiser.  `ArxivSession` should be sufficient for many applications. If that's not the case, clients can implement their own networking layer and still use this library as a Domain Specific Language for constructing `ArxivRequest` values. In that case, `ArxivParser` can be used for parsing raw API reponses to `ArxivReponse` values.

### Fetching Articles

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

Queries are constructed by using an embeded Domain Specific Language created with Swift feature called [Result Builders](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md), that was first used in Apple's [SwiftUI Framework](https://developer.apple.com/xcode/swiftui/). The DSL enables creating arbitrarily complex query trees by using an intuitive syntax. 

Bellow are some of the common use scenarios.

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
allOf {
    anyOf {
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
var currentReposnse: ArxivResponse?

func fetchElectronArticles(startIndex i: Int) {
    term("electron")
        .itemsPerPage(20)
        .startIndex(i)
        .fetch(using: session) { result in
            switch result {
            case let .success(response):
                currentReposnse = response
                let articles = response.entries
                print("Page \(response.currentPage) fetched.")
            case let .failure(error):
                print("Could not fetch articles: \(error.localizedDescription)")
            }
        }
}

// Fetch the first page
fetchElectronArticles(startIndex: 0)

// When we are sure that the first page is fetched, we can fetch the second page
if let reponse = currentReposnse, let secondPageIndex = reponse.nextPageStartIndex {
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

`ArxivKit` is released under [MIT license](LICENSE)). For terms and conditions of using the arXiv API itself see [arXiv API Help](https://arxiv.org/help/api).
