import Foundation
import ArgumentParser

final class Runah: ParsableCommand {
  private enum CodingKeys: CodingKey {
    case scale
    case statsInterval
  }

  @Argument(help: "How many concurrent jobs will be running simultaneously, default value is 1")
  var scale: Int = 20

  @Argument(help: "Print statistics interval (in seconds), default value is 10")
  var statsInterval: Int = 10

  private var operationQueue = OperationQueue()
  private let rzdJobGenerator = RzdJobGenerator()
  private let rzdRequestsGenerator = RzdRequestGenerator()
  private var rzdStats = Stats(successAttempts: 0, errors: 0)
  private let timerQueue = DispatchQueue(label: "timerQueue", qos: .utility)
  private var timer: Timer?

  func run() throws {
    assert(scale > 0, "Scale must be greater than 0")
    operationQueue.maxConcurrentOperationCount = scale
    startRzdJobs(scale: scale)
    startPrintStatsTimer()
  }

  private func startPrintStatsTimer() {
    DispatchQueue.global().async {
      let timer = Timer(
        timeInterval: TimeInterval(self.statsInterval),
        target: self,
        selector: #selector(self.printStats),
        userInfo: nil,
        repeats: true
      )
      RunLoop.current.add(timer, forMode: .common)
      RunLoop.current.run()
      self.timer = timer
    }
  }

  private func startRzdJobs(scale: Int) {
    for _ in 0...scale {
      addRzdJob()
    }
  }

  private func addRzdJob() {
    let rzdWorker = RzdWorker(
      with: rzdJobGenerator.generateRandomJob(),
      session: URLSession.shared,
      requestsGenerator: rzdRequestsGenerator
    )
    rzdWorker.completionBlock = {
      if rzdWorker.isSucceed == true {
        self.rzdStats.successAttempts += 1
      } else {
        self.rzdStats.errors += 1
      }
      // on completion of every job we create a new one to keep it infinite
      self.addRzdJob()
      // set completion block to nil to break cycle memory reference
      rzdWorker.completionBlock = nil
    }
    operationQueue.addOperation(rzdWorker)
  }

  @objc private func printStats() {
    print(
      String(
        format: "%@%@succeed:%10d             failed:%10d", "RZD",
        String(repeating: " ", count: 14),
        rzdStats.successAttempts,
        rzdStats.errors
      )
    )
  }
}

Runah.main()
dispatchMain()
