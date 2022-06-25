import Foundation

extension Collection {
  func unwrappedRandomElement() -> Element {
    guard let element = randomElement() else {
      fatalError("Can't get random element from \(self)")
    }
    return element
  }
}
