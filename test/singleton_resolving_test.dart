import 'package:test/test.dart';
import 'package:zef_di_abstractions/zef_di_abstractions.dart';

import 'setup.dart';
import 'test_classes/implementations.dart';
import 'test_classes/interfaces.dart';
import 'test_classes/services.dart';

void main() {
  setUpAll(() {
    initializeServiceLocator();

    // Register all services
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

    // Register each animal once except for the Spider
    ServiceLocator.I.registerInstance(
      Chicken(walkService, eatingService),
      interfaces: [Bird, Animal],
      name: null,
      key: null,
      environment: null,
    );

    ServiceLocator.I.registerInstance(
      Dolphin(swimService, eatingService),
      interfaces: [Animal, Fish],
      name: null,
      key: null,
      environment: null,
    );

    ServiceLocator.I.registerInstance(
      Eagle(flightService, eatingService),
      interfaces: [Bird, Animal],
      name: null,
      key: null,
      environment: null,
    );

    ServiceLocator.I.registerInstance(
      Shark(swimService, eatingService),
      interfaces: [Animal, Fish],
      name: null,
      key: null,
      environment: null,
    );

    //* NOTE: We dont register the Spider

    ServiceLocator.I.registerInstance(
      Whale(swimService, eatingService),
      interfaces: [Animal, Fish],
      name: null,
      key: null,
      environment: null,
    );
  });

  group('Adapter Singleton resolving', () {
    test('Resolve instance - Expect StateError', () {
      expect(
          () => ServiceLocator.I.resolve<Spider>(), throwsA(isA<StateError>()));
    });

    test('Resolve instance - Expect null', () {
      final instance = ServiceLocator.I.resolveOrNull<Spider>();

      expect(instance, isNull);
    });

    test('Resolve instance - Expect Chicken', () {
      final instance = ServiceLocator.I.resolve<Chicken>();

      expect(instance, isA<Chicken>());
    });

    test('Resolve multipe instances', () {
      final animalInstances = ServiceLocator.I.resolveAll<Animal>();
      final fishInstances = ServiceLocator.I.resolveAll<Fish>();

      expect(animalInstances, isA<List<Animal>>());
      expect(animalInstances.length, 5);

      expect(fishInstances, isA<List<Fish>>());
      expect(fishInstances.length, 3);
    });
  });
}
