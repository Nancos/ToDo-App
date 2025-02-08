import UIKit

struct OnboardingSlide {
    let image: UIImage?
    let title: String
    let description: String
    
    static func getSlides() -> [OnboardingSlide] {
        return [
            OnboardingSlide(image: UIImage(named: "onboarding_1"),
                            title: "Welcome to the ToDo App",
                            description: "Watch your tasks come to life."),
            OnboardingSlide(image: UIImage(named: "onboarding_2"),
                            title: "Share",
                            description: "Share, edit and delete your tasks."),
            OnboardingSlide(image: UIImage(named: "onboarding_3"),
                            title: "Get Started",
                            description: "Start your day with us today.")
        ]
    }
}
