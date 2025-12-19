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
            if self.secureField != nil { return }
            
            // Find the active window
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first else {
                return
            }
            
            let field = UITextField()
            field.isSecureTextEntry = true
            
            // Add to window view hierarchy
            window.addSubview(field)
            
            // Center it (though it's invisible/hidden behind content essentially)
            field.translatesAutoresizingMaskIntoConstraints = false
            field.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
            field.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            
            // The Layer Hack:
            // 1. Move field's layer to be a sibling of the window's layer (in the superlayer)
            window.layer.superlayer?.addSublayer(field.layer)
            
            // 2. Move the window's layer INSIDE the field's secure layer
            // The secure content is usually the last sublayer of the text field's layer
            if let secureLayer = field.layer.sublayers?.last {
                secureLayer.addSublayer(window.layer)
            } else {
                field.layer.addSublayer(window.layer)
            }
            
            self.secureField = field
        }
    }
    
    private func disableSecureMode() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let field = self.secureField else { return }
            
            // To restore: identify the window from the field's sublayers and put it back
            // The window layer is inside field.layer.sublayers?.last
            
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first else {
                // Fallback attempt to clean up if window not found (unlikely)
                field.removeFromSuperview()
                self.secureField = nil
                return
            }
            
            // Move window layer back to the superlayer of the field (which was the original superlayer of window)
            field.layer.superlayer?.addSublayer(window.layer)
            
            field.removeFromSuperview()
            self.secureField = nil
        }
    }
}
