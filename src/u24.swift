import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error { continuation.resume(throwing: error) }
                else if let data, let response { continuation.resume(returning: (data, response)) }
                else { continuation.resume(throwing: URLError(.unknown)) }
            }
            task.resume()
        }
    }
}
#endif

public enum HTTPMethod: String {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE", patch = "PATCH"
}

public struct U24 {
    private let api = "https://u24.gov.ua/api"
    private let apiAssets = "https://u24.gov.ua/assets"
    private let headers = [
        "Accept-Language": "en-US,en;q=0.9",
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36"
    ]

    public init() {}

    private func fetch(from urlString: String,
                       method: HTTPMethod = .get,
                       body: Data? = nil,
                       query: [URLQueryItem] = []) async throws -> Data {
        guard var components = URLComponents(string: urlString) else { throw URLError(.badURL) }
        if !query.isEmpty { components.queryItems = query }
        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    private func fetchJSON(from urlString: String, query: [URLQueryItem] = []) async throws -> Any {
        let data = try await fetch(from: urlString, query: query)
        return try JSONSerialization.jsonObject(with: data)
    }

    private func pathComponent(_ s: String) -> String {
        s.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? s
    }

    public func getCategoryList(category: String,
                                searchTerm: String? = nil,
                                offset: Int? = nil,
                                page: Int? = nil,
                                pageSize: Int? = nil,
                                directionId: Int? = nil,
                                newsCategory: Int? = nil,
                                showOnMain: Bool? = nil) async throws -> Any {
        var items: [URLQueryItem] = []
        func add(_ name: String, _ value: CustomStringConvertible?) {
            if let value { items.append(URLQueryItem(name: name, value: value.description)) }
        }
        add("searchTerm", searchTerm)
        add("offset", offset)
        add("page", page)
        add("pageSize", pageSize)
        add("directionId", directionId)
        add("newsCategory", newsCategory)
        add("showOnMain", showOnMain)

        return try await fetchJSON(from: "\(api)/\(pathComponent(category))/list", query: items)
    }

    public func getLangTranslate(lang: String) async throws -> Any {
        try await fetchJSON(from: "\(apiAssets)/i18n/\(pathComponent(lang)).json")
    }

    public func getPageCategoryBySlug(category: String, slug: String) async throws -> Any {
        try await fetchJSON(from: "\(api)/\(pathComponent(category))/by-slug/\(pathComponent(slug))")
    }
}
