/// Dependency injection container
/// Follows Dependency Inversion Principle - manages all dependencies
class GetIt {
  static final GetIt _instance = GetIt._internal();
  factory GetIt() => _instance;
  GetIt._internal();

  static GetIt get instance => _instance;

  final Map<Type, dynamic> _services = {};
  final Map<Type, dynamic Function()> _factories = {};

  /// Register a singleton instance
  void registerSingleton<T extends Object>(T instance) {
    _services[T] = instance;
  }

  /// Register a factory function
  void registerFactory<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Register a lazy singleton
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _factories[T] = () {
      final instance = factory();
      _services[T] = instance;
      _factories.remove(T);
      return instance;
    };
  }

  /// Get an instance of type T
  T get<T extends Object>() {
    // Check if we have a singleton instance
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }

    // Check if we have a factory
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }

    throw Exception('Service of type $T is not registered');
  }

  /// Check if a service is registered
  bool isRegistered<T extends Object>() {
    return _services.containsKey(T) || _factories.containsKey(T);
  }

  /// Reset all services (useful for testing)
  void reset() {
    _services.clear();
    _factories.clear();
  }
}

/// Global instance getter
GetIt get getIt => GetIt.instance;