import Foundation

extension Array {
  func executeIfPresent(_ closure: ([Element]) -> Void) {
    if !isEmpty {
      closure(self)
    }
  }
}
