import Foundation

final class ThreadSafeManager {
    static let shared = ThreadSafeManager()

    private var values: [String: Any] {
        var valuesCopy: [String: Any]!

        concurrentQueue.sync {
            valuesCopy = self.unsafeValues
        }

        return valuesCopy
    }

    private var unsafeValues: [String: Any] = [String: Any]()
    private let concurrentQueue = DispatchQueue(label: "com.martinprusa.threadSafeManagerQueue", attributes: .concurrent)

    func add(value: String, identifier: String) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            self.unsafeValues[identifier] = value
        }
    }

    func removeValue(identifier: String) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            self.unsafeValues.removeValue(forKey: identifier)
        }
    }

    func valuesCount() -> Int {
        return self.values.count
    }
}

