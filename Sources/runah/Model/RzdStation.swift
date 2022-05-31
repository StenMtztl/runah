import Foundation

struct RzdStation: Decodable {
  private enum CodingKeys: String, CodingKey {
    case code = "id"
    case name = "title"
  }
  let code: String
  let name: String
}
