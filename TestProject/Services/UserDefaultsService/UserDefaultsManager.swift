import Foundation

final class UserDefaultsManager {
    private let userDefaults: UserDefaults
    private let onboardingKey = "onboardingChecked"
    private let firstLaunchKey = "firstLaunch"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func setOnboardingChecked() {
        userDefaults.set(true, forKey: onboardingKey)
    }
    
    func setFirstLaunchChecked() {
        userDefaults.set(true, forKey: firstLaunchKey)
    }
    
    func getStatusOnboardingChecked() -> Bool {
        return !userDefaults.bool(forKey: onboardingKey)
    }
    
    func getStatusFirstLaunch() -> Bool {
        return !userDefaults.bool(forKey: firstLaunchKey)
    }
    
    func setupDefaults() {
        userDefaults.set(false, forKey: onboardingKey)
        userDefaults.set(false, forKey: firstLaunchKey)
    }
}
