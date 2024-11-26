import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/enet_exception.dart';

/// {@template enet}
///
/// Provides a high-level interface for initializing and interacting with the
/// ENet networking library.
///
/// This class handles the setup, teardown, and version querying of the
/// ENet library. It encapsulates essential methods for initializing and
/// deinitializing the library and retrieving its version.
///
/// **Example**:
/// ```dart
/// void main() {
///   // Initialize the ENet library.
///   var enet = ENet.initialize();
///
///   try {
///     // Use ENet functionalities...
///     int version = ENet.linkedVersion();
///     print("ENet version: $version");
///   } finally {
///     // Clean up when done.
///     enet.deinitialize();
///   }
/// }
/// ```
///
/// {@endtemplate}
class ENet {
  /// Initializes the ENet library.
  /// Must be called prior to using any functions in ENet.
  ENet.initialize() {
    final err = bindings.enet_initialize();

    if (err < 0) {
      throw const ENetException('Failed to initialize.');
    }
  }

  /// Deinitializes the ENet library.
  /// Should be called when a program that has initialized ENet exits.
  ///
  /// **Note**: Failing to call this method may result in resource leaks.
  ENet.deinitialize() {
    bindings.enet_deinitialize();
  }

  /// Returns the linked version of the ENet library.
  ///
  /// The returned value represents the version, typically in the
  /// format `0xAABBCC` whrere:
  ///   - `AA` is the major version.
  ///   - `BB` is the minor version.
  ///   - `CC` is the patch version.
  static int linkedVersion() {
    return bindings.enet_linked_version();
  }
}
