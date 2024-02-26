import 'package:test/test.dart';
import 'package:zef_di_abstractions/zef_di_abstractions.dart';

import 'setup.dart';
import 'test_classes/interfaces.dart';
import 'test_classes/implementations.dart';

void main() {
  setUpAll(() {
    initializeServiceLocator();
  });

  tearDown(() {
    ServiceLocator.I.unregisterAll();
  });

  group('Adapter Singleton registrations', () {
    test('No registratin found', () {
      final result = ServiceLocator.I.resolveAll();

      expect(result, isEmpty);
    });

    test('Register a Singleton', () {
      final instance = Marble();

      ServiceLocator.I.registerInstance(
        instance,
        interfaces: null,
        name: null,
        key: null,
        environment: null,
      );

      //* We are doing these checks only once here, and not in the other tests
      expect(ServiceLocator.I.resolveAll(), isNotNull);
      expect(ServiceLocator.I.resolveAll<Marble>(), isNotNull);

      expect(ServiceLocator.I.resolveAll<Marble>().length, 1);
    });

    test('Register a Singleton with Interface', () {
      final instance = Marble();

      ServiceLocator.I.registerInstance(
        instance,
        interfaces: [Stone, Thing],
        name: null,
        key: null,
        environment: null,
      );

      expect(ServiceLocator.I.resolveAll<Marble>().length, 1);
      expect(ServiceLocator.I.resolveAll<Stone>().length, 1);
      expect(ServiceLocator.I.resolveAll<Thing>().length, 1);
    });

    test('Register same Singletons multiple times - Expect two instances', () {
      final instance1 = Marble();
      final instance2 = Marble();

      ServiceLocator.I.registerInstance(
        instance1,
        interfaces: [Stone, Thing],
        name: null,
        key: null,
        environment: null,
      );

      ServiceLocator.I.registerInstance(
        instance2,
        interfaces: [Stone, Thing],
        name: null,
        key: null,
        environment: null,
      );

      expect(ServiceLocator.I.resolveAll<Marble>().length, 2);
    });

    test('Register multiple Singletons', () {
      final marble = Marble();
      final granite = Granite();

      ServiceLocator.I.registerInstance(
        marble,
        interfaces: [Stone, Thing],
        name: null,
        key: null,
        environment: null,
      );

      ServiceLocator.I.registerInstance(
        granite,
        interfaces: [Stone, Thing],
        name: null,
        key: null,
        environment: null,
      );

      expect(ServiceLocator.I.resolveAll<Marble>().length, 1);
      expect(ServiceLocator.I.resolveAll<Granite>().length, 1);
      expect(ServiceLocator.I.resolveAll<Stone>().length, 2);
      expect(ServiceLocator.I.resolveAll<Thing>().length, 2);
    });

    test('Register named Singletons', () {
      final marble = Marble();
      final granite = Granite();

      ServiceLocator.I.registerInstance(
        marble,
        interfaces: [Stone, Thing],
        name: 'marble',
        key: null,
        environment: null,
      );

      ServiceLocator.I.registerInstance(
        granite,
        interfaces: [Stone, Thing],
        name: 'granite',
        key: null,
        environment: null,
      );

      final marbleList = ServiceLocator.I.resolveAll<Marble>(name: 'marble');
      final graniteList = ServiceLocator.I.resolveAll<Granite>(name: 'granite');

      expect(marbleList.length, 1);
      expect(graniteList.length, 1);
    });

    test('Register named Singletons with same name - Expect two instances', () {
      final marble1 = Marble();
      final marble2 = Marble();

      ServiceLocator.I.registerInstance(
        marble1,
        interfaces: [Stone, Thing],
        name: 'marble',
        key: null,
        environment: null,
      );

      ServiceLocator.I.registerInstance(
        marble2,
        interfaces: [Stone, Thing],
        name: 'marble',
        key: null,
        environment: null,
      );

      expect(ServiceLocator.I.resolveAll<Marble>(), isNotNull);
      expect(ServiceLocator.I.resolveAll<Marble>().length, 2);
    });

    test(
        'Register named Singletons with different names - Expect multiple instances',
        () {
      final marble1 = Marble();
      final marble2 = Marble();

      ServiceLocator.I.registerInstance(
        marble1,
        interfaces: [Stone, Thing],
        name: 'marble1',
        key: null,
        environment: null,
      );

      ServiceLocator.I.registerInstance(
        marble2,
        interfaces: [Stone, Thing],
        name: 'marble2',
        key: null,
        environment: null,
      );

      expect(ServiceLocator.I.resolveAll<Marble>(), isNotNull);
      expect(ServiceLocator.I.resolveAll<Marble>().length, isNot(1));
    });
  });
}
