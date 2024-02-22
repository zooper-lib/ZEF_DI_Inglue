import 'package:any_of/any_of.dart';
import 'package:zef_di_abstractions/zef_di_abstractions.dart';
import 'package:zef_di_inglue/src/registration.dart';

class InglueServiceLocatorAdapter implements ServiceLocatorAdapter {
  final Map<Type, List<Registration>> _registrations = {};

  @override
  Triplet<Success, Conflict, InternalError> registerInstance<T extends Object>(
    T instance, {
    required List<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
  }) {
    // Check if there is already a registration
    if (_isInstanceRegistered(T, name: name, key: key, environment: environment)) {
      return Triplet.second(Conflict('Registration already exists for type $T. Skipping registration.'));
    }

    // Create a registration
    var registration = SingletonRegistration<T>(
      instance: instance,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
    );

    // Register the instance
    _registrations[T] ??= [];
    _registrations[T]!.add(registration);

    return Triplet.first(Success());
  }

  @override
  Triplet<Success, Conflict, InternalError> registerFactory<T extends Object>(
    T Function(ServiceLocator serviceLocator) factory, {
    required List<Type>? interfaces,
    required String? name,
    required dynamic key,
    required String? environment,
  }) {
    if (_isInstanceRegistered(T, name: name, key: key, environment: environment)) {
      return Triplet.second(Conflict('Registration already exists for type $T. Skipping registration.'));
    }

    // Create a registration
    var registration = FactoryRegistration<T>(
      factory: factory,
      interfaces: interfaces,
      name: name,
      key: key,
      environment: environment,
    );

    // Register the instance
    _registrations[T] ??= [];
    _registrations[T]!.add(registration);

    return Triplet.first(Success());
  }

  @override
  Triplet<T, NotFound, InternalError> getFirst<T extends Object>({
    required String? name,
    required key,
    required String? environment,
  }) {
    // Get all instances
    var allInstancesResponse = getAll<T>(
      name: name,
      key: key,
      environment: environment,
    );

    // If there are no instances, return a NotFound
    if (allInstancesResponse.isSecond) {
      return Triplet.second(allInstancesResponse.second);
    }

    // Return the first instance
    return Triplet.first(allInstancesResponse.first.first);
  }

  @override
  Triplet<List<T>, NotFound, InternalError> getAll<T extends Object>({
    required String? name,
    required key,
    required String? environment,
  }) {
    // Filter by the types
    var matchedRegistrations = _registrations.entries.expand((entry) {
      // Check if the registration key (the concrete class) is T
      bool isConcreteMatch = entry.key == T;

      // Filter registrations where T is an interface or the concrete class itself
      return entry.value.where((registration) {
        return isConcreteMatch || (registration.interfaces?.contains(T) ?? false);
      });
    }).toList();

    // Filter by the name
    if (name != null) {
      matchedRegistrations = matchedRegistrations.where((registration) {
        return registration.name == name;
      }).toList();
    }

    // Filter by the key
    matchedRegistrations = matchedRegistrations.where((registration) {
      return registration.key == key;
    }).toList();

    // Filter by the environment
    if (environment != null) {
      matchedRegistrations = matchedRegistrations.where((registration) {
        return registration.environment == environment;
      }).toList();
    }

    // Check if there are any registrations
    if (matchedRegistrations.isEmpty) {
      return Triplet.second(NotFound('No registration found for type $T.'));
    }

    // Resolve the instances
    var resolvedInstances = matchedRegistrations.map((registration) {
      return registration.resolve(ServiceLocator.I) as T;
    }).toList();

    return Triplet.first(resolvedInstances);
  }

  @override
  Doublet<Success, InternalError> overrideInstance<T extends Object>(
    T instance, {
    required String? name,
    required key,
    required String? environment,
  }) {
    var registration = _registrations.entries.where((element) => element.key == T).firstOrNull?.value.firstOrNull;

    // If there is no registration, return an error
    if (registration == null) {
      return Doublet.second(InternalError('No registration found for type $T'));
    }

    // Construct the new registration
    var newRegistration = Registration<T>.from(registration, Doublet.first(instance));

    // Remove the old registration
    _registrations[T]?.remove(registration);

    // Add the new registration
    _registrations[T]?.add(newRegistration);

    return Doublet.first(Success());
  }

  @override
  Doublet<Success, InternalError> overrideFactory<T extends Object>(
    T Function(ServiceLocator serviceLocator) factory, {
    required String? name,
    required key,
    required String? environment,
  }) {
    var registration = _registrations.entries.where((element) => element.key == T).firstOrNull?.value.firstOrNull;

    // If there is no registration, return an error
    if (registration == null) {
      return Doublet.second(InternalError('No registration found for type $T'));
    }

    // Construct the new registration
    var newRegistration = Registration<T>.from(registration, Doublet.second(factory));

    // Remove the old registration
    _registrations[T]?.remove(registration);

    // Add the new registration
    _registrations[T]?.add(newRegistration);

    return Doublet.first(Success());
  }

  @override
  Triplet<Success, NotFound, InternalError> unregister<T extends Object>({
    required String? name,
    required key,
    required String? environment,
  }) {
    _registrations[T]?.removeWhere((registration) {
      return registration.name == name && registration.key == key && registration.environment == environment;
    });

    return Triplet.first(Success());
  }

  @override
  Doublet<Success, InternalError> unregisterAll() {
    _registrations.clear();

    return Doublet.first(Success());
  }

  bool _isInstanceRegistered(
    Type type, {
    required String? name,
    required key,
    required String? environment,
  }) {
    var allRegistrations = _registrations[type] ?? [];

    // Check if there are any registrations
    if (allRegistrations.isEmpty) {
      return false;
    }

    // Filter by the name
    if (name != null) {
      allRegistrations = allRegistrations.where((registration) {
        return registration.name == name;
      }).toList();
    }

    // Filter by the key
    allRegistrations = allRegistrations.where((registration) {
      return registration.key == key;
    }).toList();

    // Filter by the environment
    if (environment != null) {
      allRegistrations = allRegistrations.where((registration) {
        return registration.environment == environment;
      }).toList();
    }

    return allRegistrations.isNotEmpty;
  }
}
