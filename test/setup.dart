import 'package:zef_di_abstractions/zef_di_abstractions.dart';
import 'package:zef_di_inglue/zef_di_inglue.dart';

void initializeServiceLocator() {
  ServiceLocatorBuilder().withAdapter(InglueServiceLocatorAdapter()).build();
}
