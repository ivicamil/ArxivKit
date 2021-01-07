# ArxivKit

Swift wrapper for arXiv API.

---
**NOTE**

**Currently in beta, not tested for production.**

This project is not affiliated with [arXiv.org](https://arxiv.org). 

The wrapper itself is released under MIT license (see [LICENSE](LICENSE)). For terms and conditions of using the arXiv API itself see [arXiv API Help](https://arxiv.org/help/api).

---

## Usage

### Searching Articles

```swift

let session = FetchSession()

let electronQuery = SearchQuery.all("electron")

let electronRequest = Request(searchQuery: electronQuery)

let fetchTask = session.fethTask(with: electronRequest)

fetchTask.run { result in
    switch result {
    case let .success(response):
        let articles = response.entries
        // Do something with articles.
    case let .failure(error):
        // Handle error.
    }
}

```
### Query Examples

```swift

let astrophysicsQuery = Query.subject(Subjects.Astrophysics.all)

let authorQuery = Query.author("Richard Feynman")

let compoundQuery = Query.abstract("electron").and(.subject(Subjects.CondensedMatter.quantumGases))

```

### Request Examples

```swift

let specificArticleRequest = Request(idList: ["2101.00616"])
    
let recentElectron = Request(query: .all("electron"), sortBy: .lastUpdatedDate)

// Recent Category Theory, 20 articles per page.
let recentCategoryTheory = Request(
    query: .subject(Subjects.Mathematics.categoryTheory),
    itemsPerPage: 20,
    sortBy: .lastUpdatedDate
)

// Recent Category Theory, second page.
let recentCategoryTheoryPage2 = recentCategoryTheory.nextPage()

```


