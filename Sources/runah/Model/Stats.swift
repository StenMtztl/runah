import Foundation

struct Stats {
  private (set) var successAttempts: Int = 0
  private (set) var errors: Int = 0

  mutating func increaseSuccess() {
    successAttempts += 1
  }

  mutating func increaseErrors() {
    errors += 1
  }
}
