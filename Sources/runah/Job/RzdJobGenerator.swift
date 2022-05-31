import Foundation

struct RzdJobGenerator {
  func generateRandomJob() -> RzdJob {
    let platform = Platform.allCases.unwrappedRandomElement()
    return RzdJob(
      platform: platform.rawValue,
      appVersion: randomAppVersion(for: platform),
      protocolVersion: randomProtocolVersion(),
      osVersion: randomOSVersion(for: platform),
      networkVersion: randomNetworkVersion(for: platform),
      rzdVersion: randomRzdVersion(),
      deviceId: randomDeviceId(),
      language: randomLanguage()
    )
  }

  private func randomDeviceId() -> String {
    return UUID().uuidString.replacingOccurrences(of: "-", with: "")
  }

  private func randomOSVersion(for platform: Platform) -> String {
    switch platform {
    case .iOS:
      return Self.iOSPlatformVersions.unwrappedRandomElement()
    }
  }

  private func randomNetworkVersion(for platform: Platform) -> String {
    switch platform {
    case .iOS:
      return Self.iOSNetworkVersions.unwrappedRandomElement()
    }
  }


  private func randomAppVersion(for platform: Platform) -> String {
    switch platform {
    case .iOS:
      return Self.iOSAppVersions.unwrappedRandomElement()
    }
  }

  private func randomProtocolVersion() -> String {
    return Self.protocolVersions.unwrappedRandomElement()
  }

  private func randomRzdVersion() -> String {
    return Self.rzdVersion.unwrappedRandomElement()
  }

  private func randomLanguage() -> String {
    return Self.languages.unwrappedRandomElement()
  }

  private static let languages = [
    "ru"
  ]

  private static let rzdVersion = [
    "RZD/2034"
  ]

  private static let protocolVersions = [
    "42"
  ]

  private static let iOSAppVersions = [
    "1.42.1(2034)",
    "1.42(2012)",
    "1.41.2(2006)",
    "1.41.1(2003)"
  ]

  private static let iOSNetworkVersions = [
    "CFNetwork/1206"
  ]

  private static let iOSPlatformVersions = [
    "Darwin/20.1.0",
    "Darwin/20.2.0",
    "Darwin/20.3.0",
    "Darwin/20.4.0",
    "Darwin/20.5.0",
    "Darwin/20.6.0",
    "Darwin/21.0.0",
    "Darwin/21.1.0",
    "Darwin/21.2.0",
    "Darwin/21.3.0",
    "Darwin/21.4.0",
    "Darwin/21.5.0"
  ]
}

private enum Platform: String, CaseIterable {
  case iOS = "iOS"
}
