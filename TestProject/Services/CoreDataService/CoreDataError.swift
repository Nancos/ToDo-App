enum CoreDataError: Error {
    case persistentStoreLoadingFailed(Error)
    case saveFailed(Error)
    case fetchFailed(Error)
    case taskNotFound
    case updateFailed(Error)
    case deleteFailed(Error)
    
    static func description(for error: CoreDataError) -> String {
        switch error {
        case .persistentStoreLoadingFailed(let error):
            return String(format: String(localized: "persistent_store_loading_failed"), error.localizedDescription)
        case .saveFailed(let error):
            return String(format: String(localized: "save_failed"), error.localizedDescription)
        case .fetchFailed(let error):
            return String(format: String(localized: "fetch_failed"), error.localizedDescription)
        case .taskNotFound:
            return String(localized: "task_not_found")
        case .updateFailed(let error):
            return String(format: String(localized: "update_failed"), error.localizedDescription)
        case .deleteFailed(let error):
            return String(format: String(localized: "delete_failed"), error.localizedDescription)
        }
    }
}
