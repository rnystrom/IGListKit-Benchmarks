import Foundation

/// Perform diff between old and new collections
///
/// - Parameters:
///   - old: Old collection
///   - new: New collection
///   - reduceMove: Reduce move from insertions and deletions
/// - Returns: A set of changes
public func diff<T: Hashable>(
  old: Array<T>,
  new: Array<T>,
  algorithm: DiffAware = Heckel()) -> [Change<T>] {

  if let changes = algorithm.preprocess(old: old, new: new) {
    return changes
  }

  return algorithm.diff(old: old, new: new)
}
