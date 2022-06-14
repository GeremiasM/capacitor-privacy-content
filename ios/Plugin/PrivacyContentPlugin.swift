import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(PrivacyContentPlugin)
public class PrivacyContentPlugin: CAPPlugin {
    private let implementation = PrivacyContent()
    
    var window: UIWindow?
    private var warningWindow: UIWindow?
    
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

  public override func load() {
        self.startPreventingRecording()
        self.startPreventingScreenshot()
    }

    func startPreventingRecording() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDetectRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    func startPreventingScreenshot() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDetectScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    @objc private func didDetectRecording() {
        DispatchQueue.main.async {
            self.bridge?.triggerJSEvent(eventName: "RecordingDetectedEvent", target: "window")
            self.hideScreen()
            self.presentwarningWindow("Madyfit no permite grabar nuestro contenido. Estas infrigiendo las políticas de Derechos de Autor (Copyright)")
        }
    }
    private func hideScreen() {
        if UIScreen.main.isCaptured {
            window?.isHidden = true
        } else {
            window?.isHidden = false
        }
    }

    @objc private func didDetectScreenshot() {
        DispatchQueue.main.async {
           // self.bridge?.triggerJSEvent(eventName: "ScreenshotTakenEvent", target: "window")
            self.notifyListeners("ScreenshotTakenEvent", data: ["toma":"esto"])
            self.hideScreen()
            self.presentwarningWindow( "Madyfit no permite capturas de pantalla de nuestro contenido. Estas infrigiendo las políticas de Derechos de Autor (Copyright)")
        }
    }

    private func presentwarningWindow(_ message: String) {
        // Remove exsiting
        warningWindow?.removeFromSuperview()
        warningWindow = nil

        guard let frame = window?.bounds else { return }

        // Warning label
        let label = UILabel(frame: frame)
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textColor = .white
        label.textAlignment = .center
        label.text = message

        // warning window
        var warningWindow = UIWindow(frame: frame)

        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared
                .connectedScenes
                .first {
                    $0.activationState == .foregroundActive
                }
            if let windowScene = windowScene as? UIWindowScene {
                warningWindow = UIWindow(windowScene: windowScene)
            }
        } else {
            // Fallback on earlier versions
        }

        warningWindow.frame = frame
        warningWindow.backgroundColor = .black
        warningWindow.windowLevel = UIWindow.Level.statusBar + 1
        warningWindow.clipsToBounds = true
        warningWindow.isHidden = false
        warningWindow.addSubview(label)

        self.warningWindow = warningWindow

        UIView.animate(withDuration: 0.15) {
            label.alpha = 1.0
            label.transform = .identity
        }
        warningWindow.makeKeyAndVisible()
    }
}
