import Foundation

protocol Worker: Operation {
  associatedtype T: Job

  var job: T { get }
}
