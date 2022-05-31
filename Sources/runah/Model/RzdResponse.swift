import Foundation

enum RzdSearchResponse {
  case requestId(RzdRequestIdSearchResponse)
  case timetables(RzdTimetablesSearchResponse)
}

struct RzdRequestIdSearchResponse: Decodable {
  private struct Result: Decodable {
    let rid: String
  }

  let errorMessage: String
  let errorCode: Int
  private let result: Result?
  var rid: String { result?.rid ?? "" }
}

struct RzdTimetablesSearchResponse: Decodable {
  struct Timetable: Decodable {
  }

  private struct Result: Decodable {
    let timetables: [Timetable]
  }

  let errorMessage: String
  let errorCode: Int
  private let result: Result?
  var timetables: [Timetable] { result?.timetables ?? [] }
}

struct RzdSuggestionsResponse: Decodable {
  private struct Result: Decodable {
    let items: [RzdStation]
  }

  let errorCode: Int
  let errorMessage: String
  var stations: [RzdStation] { result?.items ?? [] }
  private let result: Result?
}
