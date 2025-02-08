import UIKit

final class CustomNavigationController: UINavigationController {
    override func viewDidLoad() { setupUI() }
}

private extension CustomNavigationController {
    func setupUI() { navigationBar.tintColor = UIColor(named: "addTaskButton") }
}
