import UIKit
import WebKit
import Then
class WebViewViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    var url: URL!

    static func createWith(storyboard: UIStoryboard, url: URL) -> WebViewViewController {
        return (storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController).then { vc in
            vc.url = url
        }
    }

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myRequest = URLRequest(url: url)
        webView.load(myRequest)
    }

}
