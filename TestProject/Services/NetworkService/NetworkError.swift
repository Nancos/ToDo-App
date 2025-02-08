enum NetworkError: Error {
    case invalidURL
    case httpError(statusCode: Int)
    case decodingError(error: Error)
    case invalidResponce
    case noData
}
