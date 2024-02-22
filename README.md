# zef_di_inglue

This package offers an implementation for the `ServiceLocatorAdapter` from package [zef_di_abstractions](https://pub.dev/packages/zef_di_abstractions).

## Getting Started

To get started with `zef_di_inglue`, add it to your project's dependency list:

```yaml
dependencies:
  zef_di_inglue: ^latest_version
```

## Usage

1. Set up the adapter

Check the readme of [zef_di_abstractions](https://pub.dev/packages/zef_di_abstractions) to get started. In the setup process you will need to add an adapter for the `ServiceLocator`, and thats where this package comes in play:

```dart
void main() {
  ServiceLocatorBuilder()
    .withAdapter(InglueServiceLocatorAdapter()) // This is your adapter which handles the service registration
    .build();

  // Your application logic here
}
```

2. Register the services

Now you can continue to register the services. Again, see the readme of [zef_di_abstractions](https://pub.dev/packages/zef_di_abstractions)

## Contributing

Contributions are welcome! Please read our contributing guidelines and code of conduct before submitting pull requests or issues. Also every annotation or idea to improve is warmly appreciated.
