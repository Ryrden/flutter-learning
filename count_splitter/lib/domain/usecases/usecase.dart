/// Base class for all use cases
/// Follows Single Responsibility Principle - each use case handles one business operation
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Use case that doesn't require parameters
abstract class UseCaseNoParams<T> {
  Future<T> call();
}

/// Parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();
}