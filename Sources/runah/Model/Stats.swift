import Foundation

protocol Stats {
  var successAttempts: Int { get }
  var errors: Int { get }
  mutating func increaseSuccess()
  mutating func increaseErrors()
}

struct ThreadSafeStats: Stats {
  private struct Values {
    var successAttempts: Int
    var errors: Int
  }

  private var _values = Values(successAttempts: 0, errors: 0)
  private var threadSafeValues: Values {
    get {
      lock.lock()
      defer { lock.unlock() }
      return _values
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      _values = newValue
    }
  }

  private let lock = NSLock()

  var successAttempts: Int {
    threadSafeValues.successAttempts
  }
  var errors: Int {
    threadSafeValues.errors
  }

  mutating func increaseSuccess() {
    threadSafeValues.successAttempts += 1
  }

  mutating func increaseErrors() {
    threadSafeValues.errors += 1
  }
}
