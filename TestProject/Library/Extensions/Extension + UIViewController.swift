import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, titleAction: String = "OK", alertAction: ((UIAlertAction) -> Void)? = nil) {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }),
              let topVC = keyWindow.rootViewController?.presentedViewController ?? keyWindow.rootViewController
        else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleAction, style: .default, handler: alertAction)
        alert.addAction(action)
        topVC.present(alert, animated: true)
    }
}
