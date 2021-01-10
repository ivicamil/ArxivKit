# ArxivKit

Swift DSL wrapper for arXiv API.

---
**NOTE**

**Currently in beta. Public API may change.**

This project is not affiliated with [arXiv.org](https://arxiv.org). 

The wrapper itself is released under MIT license (see [LICENSE](LICENSE)). For terms and conditions of using the arXiv API itself see [arXiv API Help](https://arxiv.org/help/api).

---

## Usage

### Arxiv Session

Arxiv session object enapsulates network communication and keeps track of individual fetch tasks. Due to internal implementation details, It is more efficient to reuse a single session instance for all requests inside the app or command line tool. Currently, only  `ArxivSession.default` instance is available. Future `ArxivKit` versions may include configurable initialisers. Construct and store a session object by calling its constructor:

```swift
let session = ArxivSession.default
```

### Searching Articles

`ArxivQuery` type encapsulates different possible information that can be searched on [arXiv](https://arxiv.org). A query instance is used to construct `ArxivRequest`, which can be configured with various modifier methods to define desired number of articles per page, sorting order and criterion etc. The request is used for constructing `ArxivFetchTask` object by calling `ArxivSession`'s `fethTask(with:completion:)`. Finally, the actual search is performed by calling `run()` on given task.

However, a more declarative and fluent approach is to construct ArxivRequest by calling func `makeRequest(scope:)` on an `ArxivQuery` instance, configure it by chaining desired modifiers and perform the search by calling func `fetch(using:completion:)` at the end. Below are examples of some of the possible queries and requests.

### Performing Search

```swift
ArxivQuery
    .term("electron", in: .any)
    .makeRequest()
    .fetch(using: session) { result in
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
ArxivQuery.term("dft", in: .any)
ArxivQuery.term("dft", in: .title)
ArxivQuery.term("dft", in: .abstract)
ArxivQuery.term("Feynman", in: .author)
ArxivQuery.term("20 pages", in: .comment)
ArxivQuery.term("AMS", in: .journalReference)

ArxivQuery.subject(ArxivSubjects.Physics.computationalPhysics)

let now = Date()
let fiveDaysAgo = Date(timeInterval: -5 * 24 * 60 * 60, since: now)
let lastFiveDays = DateInterval(start: fiveDaysAgo, end: now)

ArxivQuery.submitted(lastFiveDays)
ArxivQuery.lastUpdated(lastFiveDays)
```

### Complex Queries

``` swift
ArxivQuery
    .allOf(
        .anyOf(
            .term("dft", in: .title),
            .term("ab initio", in: .title)
        ),
        .subject(ArxivSubjects.Physics.computationalPhysics)
    )
    .excluding(
        .term("Cu", in: .title)
    )
}
```

### Fetching Specific Articles

```swift
ArxivRequest(idList: ["2101.02212", "2101.02215"])
    .fetch(using: session) { result in
        // Do something with the result
    }
```

### Fetching All Versions of an Articles

```swift
let entry: ArxivEntry = ...

ArxivRequest(idList: entry.allVersionsIDs)
    .fetch(using: session) { result in
        // Do something with the result
    }
```

### Paging Example

```swift
var currentReposnse: ArxivResponse?

func fetchElectronArticles(startIndex i: Int) {
    ArxivQuery
        .term("electron", in: .any)
        .makeRequest()
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

ArxivQuery
    .term("electron", in: .any)
    .makeRequest()
    .sortedBy(.relevance)
    .sortingOrder(.descending)
    .itemsPerPage(20)
    .startIndex(60)
    .fetch(using: session) { result in
        // Do something with the result
    }
```


