import Foundation

protocol Target {
  var name: String { get }
  var stats: Stats { get }
  func attack()
}
