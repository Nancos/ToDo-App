import UIKit
import CoreData
import Network

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var monitor: NWPathMonitor?
    
    private let userDefaultsManager = UserDefaultsManager()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let onboardingChecked = userDefaultsManager.getStatusOnboardingChecked()
        let isFirstLaunch = userDefaultsManager.getStatusFirstLaunch()
        if isFirstLaunch || onboardingChecked { firstLaunch(isFirstLaunch) }
        else { regularLaunch(isFirstLaunch) }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let notPassed = userDefaultsManager.getStatusOnboardingChecked()
        if notPassed { userDefaultsManager.setupDefaults() }
    }
}

private extension AppDelegate {
    func firstLaunch(_ isFirstLaunch: Bool) {
        userDefaultsManager.setFirstLaunchChecked()
        setupVC(OnboardingViewController(isFirstLaunch))
        startNetworkMonitoring()
    }
    
    func regularLaunch(_ isFirstLaunch: Bool) {
        setupVC(CustomNavigationController(rootViewController: TabBarViewController(isFirstLaunch)))
    }
    
    func startNetworkMonitoring() {
        monitor = NWPathMonitor()
        monitor?.start(queue: DispatchQueue.global(qos: .background))
        monitor?.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.stopNetworkMonitoring()
            }
        }
    }
    
    func setupVC(_ vc: UIViewController) {
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }

    func stopNetworkMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
}
