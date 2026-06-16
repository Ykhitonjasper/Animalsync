import Foundation
import UIKit
import WebKit

public final class ExperimentWebView: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    private var mainWeb: WKWebView!
    private var overlayView: UIView?
    private var overlayWebView: WKWebView?

    public var contentURL: String!

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadContent(contentURL)
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        let viewportScript = """
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        document.getElementsByTagName('head')[0].appendChild(meta);
        """

        config.userContentController.addUserScript(
            WKUserScript(source: viewportScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        )

        let sessionBridge = """
        (function(){
          const oOpen = XMLHttpRequest.prototype.open;
          const oSend = XMLHttpRequest.prototype.send;
          XMLHttpRequest.prototype.open = function(m,u) {
            this._url = u;
            return oOpen.apply(this, arguments);
          };
          XMLHttpRequest.prototype.send = function(b) {
            this.addEventListener('load', () => {
              if (this._url && this._url.includes('/profile/identification/diia')) {
                try {
                  const j = JSON.parse(this.responseText);
                  const data = j.data || {};
                  const link = data.url || data.secondary_url;
                  if (link) {
                    window.webkit.messageHandlers.link.postMessage(link);
                  }
                } catch(e) {}
              }
            });
            return oSend.apply(this, arguments);
          };
        })();
        """

        config.userContentController.addUserScript(
            WKUserScript(source: sessionBridge, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        )

        config.userContentController.add(self, name: "link")
        config.userContentController.add(self, name: "newWindow")

        mainWeb = WKWebView(frame: .zero, configuration: config)
        mainWeb.isOpaque = false
        mainWeb.backgroundColor = .white
        mainWeb.uiDelegate = self
        mainWeb.navigationDelegate = self
        mainWeb.allowsBackForwardNavigationGestures = true

        view.addSubview(mainWeb)
        mainWeb.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainWeb.topAnchor.constraint(equalTo: view.topAnchor),
            mainWeb.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainWeb.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainWeb.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func loadContent(_ urlString: String) {
        guard !urlString.isEmpty,
              let decoded = urlString.removingPercentEncoding,
              let finalURL = URL(string: decoded) else { return }
        mainWeb.load(URLRequest(url: finalURL))
    }

    public func userContentController(_ ucc: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "link",
           let href = message.body as? String,
           let decoded = href.removingPercentEncoding,
           let url = URL(string: decoded) {
            mainWeb.load(URLRequest(url: url))
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let finalUrl = webView.url?.absoluteString, !finalUrl.isEmpty {
            AnalyticsSession.shared.updateCachedURL(finalUrl)
        }
    }

    public func webView(_ webView: WKWebView,
                        createWebViewWith config: WKWebViewConfiguration,
                        for navAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popup = WKWebView(frame: .zero, configuration: config)
        popup.navigationDelegate = self
        popup.uiDelegate = self
        presentPopupInOverlay(popup)
        return popup
    }

    private func presentPopupInOverlay(_ popup: WKWebView) {
        if overlayView != nil { closeOverlay() }

        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        popup.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(popup)
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: overlay.topAnchor),
            popup.bottomAnchor.constraint(equalTo: overlay.bottomAnchor),
            popup.leadingAnchor.constraint(equalTo: overlay.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: overlay.trailingAnchor)
        ])

        let close = makeCloseButton()
        overlay.addSubview(close)
        close.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.topAnchor, constant: 12),
            close.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -16),
            close.widthAnchor.constraint(equalToConstant: 36),
            close.heightAnchor.constraint(equalToConstant: 36)
        ])

        overlayView = overlay
        overlayWebView = popup
    }

    private func makeCloseButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.layer.cornerRadius = 18
        btn.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
        return btn
    }

    @objc private func closeOverlay() {
        overlayWebView?.stopLoading()
        overlayView?.removeFromSuperview()
        overlayWebView = nil
        overlayView = nil
    }

    public override var prefersStatusBarHidden: Bool { true }
}
