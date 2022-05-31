import Foundation

class RzdWorker: Operation, Worker {
  private enum Errors: Error {
    case incorrectAPIResponse
  }

  private enum WorkStage {
    case idle
    case obtainedFirstStation(RzdStation)
    case obtainedSecondStation(RzdStation, RzdStation)
    case performedFirstSearchRequest(RzdStation, RzdStation, RzdRequestIdSearchResponse)
    case completed(RzdTimetablesSearchResponse)
    case error(Error)
  }

  private enum State: String {
    case isReady
    case isExecuting
    case isFinished
  }

  private var state: State = .isReady {
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
  private var stage: WorkStage = .idle
  var isSucceed: Bool {
    if case .completed = stage {
      return true
    } else {
      return false
    }
  }
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
  private let session: URLSession
  private let requestsGenerator: RzdRequestGenerator

  init(
    with job: RzdJob,
    session: URLSession,
    requestsGenerator: RzdRequestGenerator
  ) {
    self.job = job
    self.session = session
    self.requestsGenerator = requestsGenerator
  }

  override func start() {
    if isCancelled { return }
    state = .isExecuting
    proceedWithNextStage()
  }

  override func cancel() {
    task?.cancel()
    super.cancel()
  }

  @objc private func proceedWithNextStage() {
    switch stage {
    case .idle:
      obtainFirstStation()
    case .obtainedFirstStation(let firstStation):
      obtainSecondStation(firstStation: firstStation)
    case .obtainedSecondStation(let firstStation, let secondStation):
      performSearchRequest(firstStation: firstStation, secondStation: secondStation, previousResponse: nil)
    case .performedFirstSearchRequest(let firstStation, let seconsecondStationdRzdStation, let previousResponse):
      performSearchRequest(
        firstStation: firstStation,
        secondStation: seconsecondStationdRzdStation,
        previousResponse: previousResponse
      )
    case .completed(_):
      finish()
    case .error(_):
      finish()
    }
  }

  private func proceedWithNextStageWithRandomDelay() {
    DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval.random(in: 0...3)) {
      self.proceedWithNextStage()
    }
  }

  private func obtainFirstStation() {
    runSuggestionRequest { [weak self] result in
      switch result {
      case let .success(response):
        if let randomStation = response.stations.randomElement() {
          self?.stage = .obtainedFirstStation(randomStation)
        }
      case let .failure(error):
        self?.stage = .error(error)
      }
      self?.proceedWithNextStageWithRandomDelay()
    }
  }

  private func obtainSecondStation(firstStation: RzdStation) {
    runSuggestionRequest { [weak self] result in
      switch result {
      case let .success(response):
        if let randomStation = response.stations.randomElement() {
          self?.stage = .obtainedSecondStation(firstStation, randomStation)
        }
      case let .failure(error):
        self?.stage = .error(error)
      }
      self?.proceedWithNextStageWithRandomDelay()
    }
  }

  private func performSearchRequest(
    firstStation: RzdStation,
    secondStation: RzdStation,
    previousResponse: RzdRequestIdSearchResponse?
  ) {
    runSearchRequest(
      firstStation: firstStation,
      secondStation: secondStation,
      previousResponse: previousResponse
    ) { [weak self] result in
      switch result {
      case let .success(response):
        switch response {
        case let .requestId(requestIdResponse):
          self?.stage = .performedFirstSearchRequest(firstStation, secondStation, requestIdResponse)
        case let .timetables(timetablesResponse):
          self?.stage = .completed(timetablesResponse)
        }
      case let .failure(error):
        self?.stage = .error(error)
      }
      self?.proceedWithNextStageWithRandomDelay()
    }
  }

  private func finish() {
    state = .isFinished
  }

  private func runSuggestionRequest(completion: @escaping (Result<RzdSuggestionsResponse, Error>) -> Void) {
    let request = requestsGenerator.generateSuggestRequest(from: job)
    task = session.dataTask(
      with: request,
      type: RzdSuggestionsResponse.self,
      completionHandler: { [weak self] result in
        if case let .success(response) = result,
           !response.errorMessage.isEmpty {
          completion(.failure(response.errorMessage))
        } else {
          completion(result)
        }
        self?.task = nil
      }
    )
    task?.resume()
  }

  private func runSearchRequest(
    firstStation: RzdStation,
    secondStation: RzdStation,
    previousResponse: RzdRequestIdSearchResponse?,
    completion: @escaping (Result<RzdSearchResponse, Error>) -> Void
  ) {
    let request = requestsGenerator.generateSearchRequest(
      from: job,
      firstStation: firstStation,
      secondStation: secondStation,
      previousResponse: previousResponse
    )
    task = searchDataTask(with: request, completionHandler: { [weak self] result in
      completion(result)
      self?.task = nil
    })
    task?.resume()
  }

  private func searchDataTask(
    with request: URLRequest,
    completionHandler: @escaping (Result<RzdSearchResponse, Error>) -> Void
  ) -> URLSessionDataTask {
    return session.dataTask(with: request)
    { data, _, error in
      if let data = data {
        do {
          let response = try JSONDecoder().decode(RzdRequestIdSearchResponse.self, from: data)
          if response.errorMessage.isEmpty {
            completionHandler(.success(.requestId(response)))
          } else {
            completionHandler(.failure(response.errorMessage))
          }
        } catch {
          do {
            let response = try JSONDecoder().decode(RzdTimetablesSearchResponse.self, from: data)
            if response.errorMessage.isEmpty {
              completionHandler(.success(.timetables(response)))
            } else {
              completionHandler(.failure(response.errorMessage))
            }
          } catch {
            completionHandler(.failure(error))
          }
        }
      } else {
        completionHandler(.failure(error ?? URLSessionErrors.incorrectResponse))
      }
    }
  }
}

extension String: Error {
  var localizedDescription: String { self }
}
