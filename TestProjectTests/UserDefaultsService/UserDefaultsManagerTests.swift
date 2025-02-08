import XCTest
@testable import TestProject

final class UserDefaultsManagerTests: XCTestCase {
    
    var userDefaults: UserDefaults!
    var userDefaultsManager: UserDefaultsManager!
    
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "testSuite")
        userDefaultsManager = UserDefaultsManager(userDefaults: userDefaults)
        userDefaults.removePersistentDomain(forName: "testSuite")
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "testSuite")
        userDefaults = nil
        userDefaultsManager = nil
        super.tearDown()
    }
    
    func testSetOnboardingChecked() {
        XCTAssertTrue(userDefaultsManager.getStatusOnboardingChecked(), "По умолчанию должно быть true")
        userDefaultsManager.setOnboardingChecked()
        XCTAssertFalse(userDefaultsManager.getStatusOnboardingChecked(), "После установки должно быть false")
    }
    
    func testSetFirstLaunchChecked() {
        XCTAssertTrue(userDefaultsManager.getStatusFirstLaunch(), "По умолчанию должно быть true")
        userDefaultsManager.setFirstLaunchChecked()
        XCTAssertFalse(userDefaultsManager.getStatusFirstLaunch(), "После установки должно быть false")
    }
    
    func testDefaultValues() {
        userDefaultsManager.setupDefaults()
        XCTAssertTrue(userDefaultsManager.getStatusOnboardingChecked(), "По умолчанию должно быть true")
        XCTAssertTrue(userDefaultsManager.getStatusFirstLaunch(), "По умолчанию должно быть true")
    }
}
