struct Tasks: Decodable {
    let todos: [Todo]
    let total: Int
}

struct Todo: Decodable {
    let id: Int
    let todo: String?
    let completed: Bool?
}
