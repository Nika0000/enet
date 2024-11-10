import 'package:enet/src/bindings/lib_enet.dart';
import 'package:enet/src/enet_exception.dart';

class ENet {
  static final _instance = LibENet.instance;

  ENet.initialize() {
    int err = _instance.enet_initialize();

    if (err < 0) {
      throw ENetException("Failed to initialize.");
    }
  }

  ENet.deinitialize() {
    _instance.enet_deinitialize();
  }

  static int linkedVersion() {
    return _instance.enet_linked_version();
  }
}
