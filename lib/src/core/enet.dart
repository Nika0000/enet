import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/enet_exception.dart';

class ENet {
  ENet.initialize() {
    int err = bindings.enet_initialize();

    if (err < 0) {
      throw ENetException("Failed to initialize.");
    }
  }

  ENet.deinitialize() {
    bindings.enet_deinitialize();
  }

  static int linkedVersion() {
    return bindings.enet_linked_version();
  }
}
