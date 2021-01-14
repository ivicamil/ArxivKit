
/**
 A list of arXiv article identifiers.
 
 The type conforms to `ArxivRequest` and can be used for fetching the articles with specified IDs.
 */
public struct ArxivIdList: ArxivRequest {
    
    /// Returns identifiers from the list.
    public let idList: [String]
    
    /**
     Creates an ID list.
     
     - Parameter firstID: An arXiv article IDs.
     - Parameter otherIDs: Other optional IDs.
     
     To retrieve a specific version of an article, end the corresponding ID with `vN` suffix where `N` is the desired version number. If an identifier without the suffix is provided,
     the most recent version will be retrieved. `ArxivEntry` type has properties for getting the version and versioned IDs of the corresponing article.
     
     For detailed explanation of arXiv identifiers see [arXiv help](https://arxiv.org/help/arxiv_identifier).
     */
    public init(_ firstID: String, _ otherIDs: String...) {
        self.idList = [firstID] + otherIDs
    }
    
    /**
     Creates an ID list.
     
     - Parameter idList: An array of arXiv article IDs.
     
     To retrieve a specific version of an article, end the corresponding ID with `vN` suffix where `N` is the desired version number. If an identifier without the suffix is provided,
     the most recent version will be retrieved. `ArxivEntry` type has properties for getting the version and versioned IDs of the corresponing article.
     
     For detailed explanation of arXiv identifiers see [arXiv help](https://arxiv.org/help/arxiv_identifier).
     */
    public init(ids: [String]) {
        self.idList = ids
    }
    
    /// Returns `ArxivRequestSpecification(idList: idList)`.
    public var requestSpecification: ArxivRequestSpecification {
        return ArxivRequestSpecification(idList: idList)
    }
}
