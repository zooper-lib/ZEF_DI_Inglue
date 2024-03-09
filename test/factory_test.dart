import 'package:test/test.dart';
import 'package:zef_di_abstractions/zef_di_abstractions.dart';

import 'setup.dart';
import 'test_classes/implementations.dart';
import 'test_classes/interfaces.dart';
import 'test_classes/services.dart';

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  tearDown(() {
    ServiceLocator.I.unregisterAll();
  });

  group('Factory Registration |', () {
    test('Register Factory | Eagle | Should Resolve Eagle Instance', () {
      // Arrange
      ServiceLocator.I.registerInstance<FlightService>(FlightService(),
          interfaces: [MovementService]);
      ServiceLocator.I.registerInstance<EatingService>(EatingService());

      // Act
      ServiceLocator.I.registerFactory<Eagle>(
        (serviceLocator, namedArgs) => Eagle(
          serviceLocator.resolve<FlightService>(),
          serviceLocator.resolve<EatingService>(),
        ),
        interfaces: [Bird, Animal, Thing],
      );

      final eagleInstances = ServiceLocator.I.resolveAll<Eagle>();

      // Assert
      expect(eagleInstances, isNotNull);
      expect(eagleInstances.length, 1);
    });

    test('Register Factory | InvalidThing | Should Warn About Injection', () {
      // Arrange
      ServiceLocator.I.registerFactory<InvalidThing>(
        (serviceLocator, namedArgs) {
          throw Exception('Dependency Injection failed for InvalidThing.');
        },
        interfaces: [Thing],
      );

      // Act & Assert
      expect(
        () => ServiceLocator.I.resolve<InvalidThing>(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Factory Resolution |', () {
    test('Resolve Factory | MovementService | Should Resolve WalkService', () {
      // Arrange
      ServiceLocator.I.registerInstance<WalkService>(WalkService(),
          interfaces: [MovementService]);

      // Act
      final walkService = ServiceLocator.I.resolve<MovementService>();

      // Assert
      expect(walkService, isA<WalkService>());
    });

    test(
        'Resolve Factory With Parameters | ServiceWithParameters | Should Resolve Correctly',
        () {
      // Arrange
      ServiceLocator.I.registerInstance<WalkService>(WalkService(),
          interfaces: [MovementService]);
      ServiceLocator.I.registerFactory<ServiceWithParameters>(
        (locator, namedArgs) => ServiceWithParameters(
          locator.resolve<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      // Act
      final serviceWithParameters =
          ServiceLocator.I.resolve<ServiceWithParameters>(
        namedArgs: {'passedParam': 'exampleValue'},
      );

      // Assert
      expect(serviceWithParameters, isNotNull);
      expect(serviceWithParameters.passedParam, equals('exampleValue'));
    });

    test(
        'Resolve Factory With Excess Parameters | ServiceWithParameters | Should Still Resolve',
        () {
      // Arrange
      ServiceLocator.I.registerInstance<WalkService>(WalkService(),
          interfaces: [MovementService]);
      ServiceLocator.I.registerFactory<ServiceWithParameters>(
        (locator, namedArgs) => ServiceWithParameters(
          locator.resolve<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      // Act & Assert
      expect(
        () => ServiceLocator.I.resolve<ServiceWithParameters>(
          namedArgs: {'passedParam': 'exampleValue', 'tooMany': 'extraValue'},
        ),
        returnsNormally,
      );
    });

    test(
        'Resolve Factory With Incorrect Parameters | ServiceWithParameters | Should Throw TypeError',
        () {
      // Arrange
      ServiceLocator.I.registerInstance<WalkService>(WalkService(),
          interfaces: [MovementService]);
      ServiceLocator.I.registerFactory<ServiceWithParameters>(
        (locator, namedArgs) => ServiceWithParameters(
          locator.resolve<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      // Act & Assert
      expect(
        () => ServiceLocator.I.resolve<ServiceWithParameters>(
          namedArgs: {'wrongParameter': 'exampleValue'},
        ),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
