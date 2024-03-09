import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zef_di_abstractions/zef_di_abstractions.dart';
import 'package:zef_helpers_lazy/zef_helpers_lazy.dart';

import 'setup.dart';
import 'test_classes/implementations.dart';
import 'test_classes/services.dart';

class MockWalkService extends Mock implements WalkService {}

class MockEatingService extends Mock implements EatingService {}

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  tearDown(() {
    ServiceLocator.I.unregisterAll();
  });

  group('Combined Registrations |', () {
    test(
        'Singleton, Factory, and Lazy | Mix Registration Types | Should Resolve Correctly',
        () {
      // Arrange - Singleton
      final singletonService = Marble();
      ServiceLocator.I.registerInstance(singletonService);

      // Arrange - Factory
      ServiceLocator.I.registerFactory<WalkService>(
        (locator, namedArgs) => WalkService(),
      );

      // Arrange - Lazy
      final lazyService = Lazy<EatingService>(factory: () => EatingService());
      ServiceLocator.I.registerLazy<EatingService>(lazyService);

      // Act & Assert - Singleton
      final resolvedSingleton = ServiceLocator.I.resolve<Marble>();
      expect(resolvedSingleton, isNotNull);
      expect(resolvedSingleton, isA<Marble>());

      // Act & Assert - Factory
      final resolvedFactoryService = ServiceLocator.I.resolve<WalkService>();
      expect(resolvedFactoryService, isNotNull);
      expect(resolvedFactoryService, isA<WalkService>());

      // Act & Assert - Lazy
      final resolvedLazyService = ServiceLocator.I.resolve<EatingService>();
      expect(resolvedLazyService, isNotNull);
      expect(resolvedLazyService, isA<EatingService>());
    });

    test('Singleton and Lazy | Register Both | Should Resolve First Registered',
        () {
      // Arrange - Singleton
      final singletonService = Granite();
      ServiceLocator.I.registerInstance(singletonService);

      // Arrange - Lazy
      final lazyService = Lazy<Granite>(factory: () => Granite());
      ServiceLocator.I.registerLazy<Granite>(lazyService);

      // Act
      final resolvedService = ServiceLocator.I.resolve<Granite>();

      // Assert
      expect(resolvedService, isNotNull);
      expect(resolvedService, isA<Granite>());
      // Ensure the resolved instance is the singleton, not the lazy-initialized one
      expect(identical(resolvedService, singletonService), isTrue);
    });

    test(
        'Factory and Lazy | Combine for Dynamic Resolution | Should Resolve Both Correctly',
        () {
      // Arrange - Factory
      ServiceLocator.I.registerFactory<FlightService>(
        (locator, namedArgs) => FlightService(),
      );

      // Arrange - Lazy
      final lazyService = Lazy<SwimService>(factory: () => SwimService());
      ServiceLocator.I.registerLazy<SwimService>(lazyService);

      // Act & Assert - Factory
      final resolvedFactoryService = ServiceLocator.I.resolve<FlightService>();
      expect(resolvedFactoryService, isNotNull);
      expect(resolvedFactoryService, isA<FlightService>());

      // Act & Assert - Lazy
      final resolvedLazyService = ServiceLocator.I.resolve<SwimService>();
      expect(resolvedLazyService, isNotNull);
      expect(resolvedLazyService, isA<SwimService>());
    });
  });

  group('Recursive Service Resolution |', () {
    test(
        'Resolve Service with Dependencies | Different Registration Types | Should Invoke Dependency Methods',
        () {
      // Arrange - Mocked services
      final mockWalkService = MockWalkService();
      final mockEatingService = MockEatingService();

      // Arrange - Register mocked services
      ServiceLocator.I.registerInstance<MovementService>(mockWalkService);
      ServiceLocator.I.registerLazy<EatingService>(
          Lazy<EatingService>(factory: () => mockEatingService));

      // Arrange - Factory for Chicken that depends on both MovementService and EatingService
      ServiceLocator.I.registerFactory<Chicken>(
        (locator, namedArgs) => Chicken(
          locator.resolve<MovementService>(),
          locator.resolve<EatingService>(),
        ),
      );

      // Act
      final chicken = ServiceLocator.I.resolve<Chicken>();
      chicken.doSomething();
      chicken.doSomethingElse();

      // Assert
      verify(mockWalkService.move()).called(1);
      verify(mockEatingService.eat()).called(1);
    });
  });
}
