final class OnboardingPresenter {
    
    private let model = OnboardingModel()
    
    func onboardingCompleted() { model.setOnboardingChecked() }
}
