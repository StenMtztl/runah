import Foundation

class RzdWorker: Operation, Worker {
  enum State: String {
    case isReady
    case isExecuting
    case isFinished
  }

  var state: State = .isReady {
    willSet(newValue) {
      willChangeValue(forKey: state.rawValue)
      willChangeValue(forKey: newValue.rawValue)
    }
    didSet {
      didChangeValue(forKey: oldValue.rawValue)
      didChangeValue(forKey: state.rawValue)
    }
  }

  let job: RzdJob
  var isSucceed: Bool = false
  override var isAsynchronous: Bool { return true }
  override var isExecuting: Bool { state == .isExecuting }
  override var isFinished: Bool {
    if isCancelled, state != .isExecuting {
      return true
    } else {
      return state == .isFinished
    }
  }
  private var task: URLSessionTask?

  required init(with job: RzdJob) {
    self.job = job
  }

  override func start() {
    if isCancelled { return }
    state = .isExecuting
    var request = URLRequest(url: URL(string: "https://ekmp.rzd.ru/v3.0/timetable/search")!)
    task = URLSession.shared.dataTask(with: request)
    { [weak self] data, response, error in
      if let data = data,
         let result = String(data: data, encoding: .utf8) {
        self?.isSucceed = true
      } else if let error = error {
        self?.isSucceed = false
      }
      self?.task = nil
      self?.state = .isFinished
    }
    task?.resume()
  }

  override func cancel() {
    task?.cancel()
    super.cancel()
  }


}
