import Flutter
import UIKit

public class SecureScreenWrapperPlugin: NSObject, FlutterPlugin {
    private var secureField: UITextField?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "secure_screen_wrapper", binaryMessenger: registrar.messenger())
        let instance = SecureScreenWrapperPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "enableSecureMode":
            enableSecureMode()
            result(true)
        case "disableSecureMode":
            disableSecureMode()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func enableSecureMode() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.secureField == nil {
                let textField = UITextField()
                textField.isSecureTextEntry = true
                
                if let window = UIApplication.shared.windows.first {
                    window.addSubview(textField)
                    textField.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
                    textField.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
                    window.layer.superlayer?.addSublayer(textField.layer)
                    textField.layer.sublayers?.first?.addSublayer(window.layer)
                    self.secureField = textField
                }
            }
        }
    }
    
    private func disableSecureMode() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.secureField?.removeFromSuperview()
            self.secureField = nil
        }
    }
}