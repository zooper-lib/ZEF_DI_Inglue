import 'package:test/test.dart';
import 'package:zef_di_abstractions/zef_di_abstractions.dart';

import 'setup.dart';
import 'test_classes/implementations.dart';
import 'test_classes/services.dart';

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  group('Adapter Factory resolving', () {
    setUp(() {
      // Register all services
      final WalkService walkService = WalkService();
      ServiceLocator.I.registerInstance<WalkService>(
        walkService,
        interfaces: [MovementService],
        name: null,
        key: null,
        environment: null,
      );
    });

    test('Factory resolving', () {
      final walkService = ServiceLocator.I.resolve<MovementService>();
      expect(walkService is WalkService, true);
    });

    test('Resolve factory with parameters', () {
      ServiceLocator.I.registerFactory<ServiceWithParameters>(
        (locator, namedArgs) => ServiceWithParameters(
          locator.resolve<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      final serviceWithParameters =
          ServiceLocator.I.resolveOrNull<ServiceWithParameters>(
        namedArgs: {'passedParam': 'exampleValue'},
      );

      expect(serviceWithParameters, isNotNull);
    });

    test('Resolve factory with too many parameter - Expect resolve', () {
      ServiceLocator.I.registerFactory<ServiceWithParameters>(
        (locator, namedArgs) => ServiceWithParameters(
          locator.resolve<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      final serviceWithParameters =
          ServiceLocator.I.resolveOrNull<ServiceWithParameters>(
        namedArgs: {
          'passedParam': 'exampleValue',
          'tooMany': 'exampleValue',
        },
      );

      expect(serviceWithParameters, isNotNull);
    });

    test('Resolve factory with wrong parameters - Expect error', () {
      ServiceLocator.I.registerFactory<ServiceWithParameters>(
        (locator, namedArgs) => ServiceWithParameters(
          locator.resolve<WalkService>(),
          passedParam: namedArgs['passedParam'] as String,
        ),
      );

      expect(
          () => ServiceLocator.I.resolveOrNull<ServiceWithParameters>(
              namedArgs: {'wrongParameter': 'exampleValue'}),
          throwsA(isA<TypeError>()));
    });
  });
}
