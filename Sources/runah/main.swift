import Foundation
import ArgumentParser

final class Runah: ParsableCommand {
  private enum CodingKeys: CodingKey {
    case scale
  }

  @Argument(help: "How many concurrent jobs will be running simultaneously, default value is 1")
  var scale: Int = 1

  private var operationQueue = OperationQueue()

  func run() throws {
    assert(scale > 0, "Scale must be greater than 0")
    operationQueue.maxConcurrentOperationCount = scale
    startRzdJobs(scale: scale)
  }

  private func startRzdJobs(scale: Int) {
    for _ in 0...scale {
      addRzdJob()
    }
  }

  private func addRzdJob() {
    let rzdWorker = RzdWorker(with: RzdJob())
    rzdWorker.completionBlock = {
      // on completion of every job we create new to keep it infinite
      DispatchQueue.global().async {
        self.addRzdJob()
      }
    }
    operationQueue.addOperation(rzdWorker)
  }
}

Runah.main()
dispatchMain()
