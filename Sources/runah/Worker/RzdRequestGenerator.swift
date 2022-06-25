import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct RzdRequestGenerator {
  private enum Constants {
    static var dayDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "dd.MM.yyyy"
      return formatter
    }()

    static let alphabet = Array("АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ")
    static let sha1HashLength = 20
  }

  func generateSuggestRequest(from job: RzdJob) -> URLRequest {
    var request = URLRequest(url: URL(string: "https://ekmp.rzd.ru/v1.0/search/suggest")!)
    request.httpBody = generateSuggestRequestBody(for: job)
    request.httpMethod = "POST"
    addDefaultHeaders(for: &request, from: job)
    return request
  }

  func generateSearchRequest(
    from job: RzdJob,
    firstStation: RzdStation,
    secondStation: RzdStation,
    previousResponse: RzdRequestIdSearchResponse?
  ) -> URLRequest {
    var request = URLRequest(url: URL(string: "https://ekmp.rzd.ru/v3.0/timetable/search")!)
    request.httpBody = generateSearchRequestBody(
      job: job,
      firstStation: firstStation,
      secondStation: secondStation,
      previousResponse: previousResponse
    )
    request.httpMethod = "POST"
    addDefaultHeaders(for: &request, from: job)
    return request
  }

  private func addDefaultHeaders(for request: inout URLRequest, from job: RzdJob) {
    request.setValue("\(job.rzdVersion) \(job.networkVersion) \(job.osVersion)", forHTTPHeaderField: "User-Agent")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("*/*", forHTTPHeaderField: "Accept")
    request.setValue("en-GB,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.setValue("ekmp.rzd.ru", forHTTPHeaderField: "Host")
  }

  private func generateSuggestRequestBody(for job: RzdJob) -> Data {
    let json = """
{"type":"STATION","platform":"\(job.platform.uppercased())","searchValue":"\(randomSuggestionString())","limit":50,"hashCode":"\(randomFakeSha1Hash())","protocolVersion":\(job.protocolVersion),"version":"\(job.appVersion)","deviceGuid":"\(job.deviceId)","language":"\(job.language)"}
"""
    guard let data = json.data(using: .utf8) else {
      fatalError("Error generating body for suggest request")
    }
    return data
  }

  private func generateSearchRequestBody(
    job: RzdJob,
    firstStation: RzdStation,
    secondStation: RzdStation,
    previousResponse: RzdRequestIdSearchResponse?
  ) -> Data {
    let json: String
    if let previousResponse = previousResponse {
      json = """
{"rid": "\(previousResponse.rid)","deviceGuid": "\(job.deviceId)","hashCode": "\(randomFakeSha1Hash())","language": "ru","platform": "\(job.platform.uppercased())","protocolVersion": \(job.protocolVersion),"version": "\(job.appVersion)"}
"""
    } else {
      json = """
{"addEkmpNotifications": true,"checkCurrentStation": true,"checkSeats": 0,"checkWatch": true,"code0": "\(firstStation.code)","code1": "\(secondStation.code)","deviceGuid": "\(job.deviceId)","dir": 0,"dt0": "\(randomDateStringInTheFuture())","hashCode": "\(randomFakeSha1Hash())","language": "ru","md": 0,"platform": "\(job.platform.uppercased())","protocolVersion": \(job.protocolVersion),"responseVersion": 2,"st0": "\(firstStation.name)","st1": "\(secondStation.name)","tfl": 3,"ti0": "0-24","timezone": "+0300","version": "\(job.appVersion)","withoutSeats": "y"}
"""
    }
    guard let data = json.data(using: .utf8) else {
      fatalError("Error generating body for first search request")
    }
    return data
  }

  private func randomDateStringInTheFuture() -> String {
    let daysCount = (0...10).unwrappedRandomElement()
    let dayInTheFuture = Date(timeIntervalSinceNow: TimeInterval(86400 * daysCount))
    return Constants.dayDateFormatter.string(from: dayInTheFuture)
  }

  private func randomFakeSha1Hash() -> String {
    return (0..<Constants.sha1HashLength)
      .map { _ in UInt8.random(in: UInt8.min...UInt8.max) }
      .map { String(format: "%02x", $0) }
      .joined()
  }

  private func randomSuggestionString() -> String {
    return "\(Constants.alphabet.unwrappedRandomElement())\(Constants.alphabet.unwrappedRandomElement())"
  }
}
