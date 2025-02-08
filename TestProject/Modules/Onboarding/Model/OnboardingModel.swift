import Foundation

final class OnboardingModel {
    private let userDefaultsManager = UserDefaultsManager()
    
    func setOnboardingChecked() { userDefaultsManager.setOnboardingChecked() }
}
