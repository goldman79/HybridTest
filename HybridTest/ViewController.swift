//
//  ViewController.swift
//  HybridTest
//
//  Created by KB on 2021/12/07.
//

import UIKit
import WebKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    var popupView: WKWebView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        
        webViewInit()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard Reachability.networkConnected() else {
            let alert = UIAlertController(title: "NetworkError", message: "네트워크가 연결되어 있지 않습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "종료", style: .default) { (action) in
                exit(0)
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }

    
    func webViewInit() {
        
        /*
         WKWebsiteDataStore.default()는 WKWebView에 쿠키, 세션, 로컬 스토리지, 캐시 등 데이터를 관리하는 객체입니다.
         저는 웹사이트 변경사항이 바로 앱에 반영되기를 원하므로 캐시 데이터는 앱 실행 시 제거되도록 코드를 추가하였습니다.
         */
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0)) {
        }
        
        webView.allowsBackForwardNavigationGestures = true
        
        if let url = URL(string: "https://m.officecheckin.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}


extension ViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .default) { (action) in
            completionHandler(false)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            if let text = alert.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}


extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if(message.name == "locationSearch") {
            
            let data:[String:String] = message.body as! Dictionary
            //location Event
            //data["action"] = searchLocation
            
        }
    }
    
//    func postLocationInfo() {
//
//        if let latitude = locationManager.location?.coordinate.latitude,
//           let longitude = locationManager.location?.coordinate.longitude {
//
//            webView.evaluateJavaScript("OCAPP.locationSearch('\(latitude)','\(longitude)');")
//
//        }
//    }
}


extension ViewController {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        popupView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        popupView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupView?.uiDelegate = self
  
        view.addSubview(popupView!)
        
        return popupView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupView {
            popupView?.removeFromSuperview()
            popupView = nil
        }
    }
}
