import 'package:zef_di_abstractions/zef_di_abstractions.dart';
import 'package:zef_di_inglue/zef_di_inglue.dart';

import 'test_classes/implementations/index.dart';
import 'test_classes/interfaces/index.dart';

void main() {
  // Build the ServiceLocator
  ServiceLocatorBuilder().withAdapter(InglueServiceLocatorAdapter()).build();

  // Register the Singleton
  ServiceLocator.I.registerInstance(
    Dolphin(),
    interfaces: [Animal, Fish],
  );

  ServiceLocator.I.registerInstance(
    Dolphin(),
    interfaces: [Animal, Fish],
  );

  // Retrieve the Singleton
  final instance = ServiceLocator.I.getFirst<Dolphin>();

  // Retrieve the instance via the interface
  final interfaceInstance = ServiceLocator.I.getFirst<Animal>();

  // Do something with the instances
  print(instance.runtimeType); // Output: Dolphin
  print(interfaceInstance.runtimeType); // Output: Dolphin
}
