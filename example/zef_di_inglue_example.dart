import 'package:zef_di_abstractions/zef_di_abstractions.dart';
import 'package:zef_di_inglue/zef_di_inglue.dart';

import 'test_classes/implementations/index.dart';
import 'test_classes/interfaces/index.dart';

void main() {
  // Build the ServiceLocator
  ServiceLocatorBuilder().withAdapter(InglueServiceLocatorAdapter()).build();

  // Register an instance
  ServiceLocator.I.registerInstance(
    Dolphin(),
    interfaces: [Animal, Fish],
  );

  // Register another instance
  ServiceLocator.I.registerInstance(
    Dolphin(),
    interfaces: [Animal, Fish],
  );

  // Register a factory
  ServiceLocator.I.registerFactory(
    (serviceLocator, namedArgs) => Whale(),
  );

  // Retrieve the Singleton
  final instance = ServiceLocator.I.resolve<Dolphin>();

  // Retrieve the instance via the interface
  final interfaceInstance = ServiceLocator.I.resolve<Animal>();

  // Do something with the instances
  print(instance.runtimeType); // Output: Dolphin
  print(interfaceInstance.runtimeType); // Output: Dolphin
}
