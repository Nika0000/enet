import 'dart:ffi';
import 'dart:io';

import 'package:enet/src/bindings/enet_bindings.dart';

const String _libName = 'enet';

abstract class LibENet {
  static DynamicLibrary _load() {
    String name;
    switch (Platform.operatingSystem) {
      case 'windows':
        name = '$_libName.dll';
      case 'macos' || 'ios':
        name = '$_libName.framework/$_libName';
      case 'linux' || 'android':
        name = 'lib$_libName.so';
      default:
        throw UnsupportedError(
          'Unsupported operating system ${Platform.operatingSystem}',
        );
    }

    try {
      return DynamicLibrary.open(name);
    } catch (e) {
      rethrow;
    }
  }

  static final instance = EnetBindings(_load());
}
