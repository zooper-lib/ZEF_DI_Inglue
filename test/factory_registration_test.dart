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

  group('Factory registration tests', () {
    setUp(() {
      // Register the services
      final WalkService walkService = WalkService();
      ServiceLocator.I.registerInstance(
        walkService,
        interfaces: [MovementService],
        name: null,
        key: null,
        environment: null,
      );

      final SwimService swimService = SwimService();
      ServiceLocator.I.registerInstance(
        swimService,
        interfaces: [MovementService],
        name: null,
        key: null,
        environment: null,
      );

      final FlightService flightService = FlightService();
      ServiceLocator.I.registerInstance(
        flightService,
        interfaces: [MovementService],
        name: null,
        key: null,
        environment: null,
      );

      final EatingService eatingService = EatingService();
      ServiceLocator.I.registerInstance(
        eatingService,
        interfaces: null,
        name: null,
        key: null,
        environment: null,
      );
    });

    test('Register a factory', () {
      ServiceLocator.I.registerFactory(
        (serviceLocator) => Eagle(
          serviceLocator.getFirst<FlightService>()!,
          serviceLocator.getFirst<EatingService>()!,
        ),
        interfaces: [Bird, Animal, Thing],
        name: null,
        key: null,
        environment: null,
      );

      final eagleList = ServiceLocator.I.getAll<Eagle>();

      expect(eagleList, isNotNull);
      expect(eagleList.length, 1);
    });

    test('Register a factory with not injected dependencies - Expect Warning', () {
      ServiceLocator.I.registerFactory<InvalidThing>(
        (serviceLocator) => serviceLocator.getFirst()!,
        interfaces: [Thing],
        name: null,
        key: null,
        environment: null,
      );
    });
  });
}
