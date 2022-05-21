import Foundation
import ArgumentParser

struct Runah: ParsableCommand {
  @Argument(help: "How many concurrent jobs will be running simultaneously")
  var scale: Int = 1

  func run() throws {
    print("Kill RZD with \(scale) scale")
  }
}

Runah.main()
