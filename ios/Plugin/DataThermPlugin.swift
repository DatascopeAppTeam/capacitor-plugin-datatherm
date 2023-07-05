import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(DataThermPlugin)
public class DataThermPlugin : CAPPlugin {

    var call: CAPPluginCall?
    override init(){
        super.init()
    }
    
    @objc func getImage(_ call: CAPPluginCall){
        self.call = call
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "DataFlirStoryBoard", bundle: nil)
            let dataFlirViewController = storyboard.instantiateViewController(identifier: "DataFlirUI") as! DataFlirViewController
            dataFlirViewController.modalPresentationStyle = .fullScreen
            dataFlirViewController.dataFlirDelagate = self
            self.bridge?.viewController?.present(dataFlirViewController, animated: true)
        }
    }
}

extension DataThermPlugin: DataFlirDelegate{
    func hasCancelled() {
        self.call?.resolve(["Canceled":true])
    }
    
    func hasDismissed(temp: Double, img: String) {
        self.call?.resolve(["Celsius":temp, "Image": "data:image/jpeg;base64," + img])
    }
    
    func logToIonic(_ message:String) {
        self.notifyListeners("pluginLog", data: ["LogMessage":message])
    }
}
