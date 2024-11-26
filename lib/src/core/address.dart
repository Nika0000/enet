import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/enet_exception.dart';
import 'package:enet/src/types.dart';
import 'package:ffi/ffi.dart';

/// {@template enet_address}
///
/// Represents a network address used within the ENet library.
///
/// - [host] An [InternetAddress] representing the hostname.
/// - [port] An integer representing the port number.
///
/// {@endtemplate}
final class ENetAddress implements Finalizable {
  /// {@macro enet_address}
  ENetAddress({InternetAddress? host, int? port}) {
    _address = calloc<bindings.ENetAddress>();

    if (host != null) {
      setHost(host);
    }

    if (port != null) {
      this.port = port;
    }

    _finalizer.attach(this, _address.cast(), detach: this);
  }

  /// Creates an [ENetAddress] instance by parsing an
  /// existing [bindings.ENetAddress]
  ///
  /// [address] - A [bindings.ENetAddress] representing the existing native ENet
  /// address to be parsed and copied into the new instance.
  ///
  /// **Note**:
  /// - The provided [address] is not retained but its values are copied.
  /// Modifying the original [address] will not affect the parsed instance.
  /// - The lifecycle of the allocated memory is managed automatically, ensuring
  /// proper cleanup when the instance is no longer in use.
  ENetAddress.parse(bindings.ENetAddress address) {
    _address = calloc<bindings.ENetAddress>();
    _finalizer.attach(this, _address.cast(), detach: this);
    _address.ref = address;
  }

  late final Pointer<bindings.ENetAddress> _address;

  static final _finalizer = NativeFinalizer(calloc.nativeFree);

  /// Retrives the resolved [InternetAddress] for the current ENet Address.
  ///
  /// This getter resolves both the hostname and IP address stored in the
  /// ENet address structure, performs a DNS lookup, and matches the resolved
  /// hostname to its IP counterpart. The resulting [InternetAddress] instance
  /// provides both the resolved hostname and IP.
  ///
  /// **Example**:
  /// ```dart
  /// final address = ENetAddress();
  /// try {
  ///   final hostAddress = await address.host;
  ///   print('Resolved address: ${hostAddress.address}');
  /// } catch (e) {
  ///   print('Failed to retrieve host: $e');
  /// }
  /// ```
  Future<InternetAddress> get host async {
    final cHost = calloc<Char>(ENET_MAX_HOST_NAME);
    final cIp = calloc<Char>(ENET_MAX_HOST_NAME);

    try {
      final host = bindings.enet_address_get_host_new(
        _address,
        cHost,
        ENET_MAX_HOST_NAME,
      );
      final ip = bindings.enet_address_get_host_ip_new(
        _address,
        cIp,
        ENET_MAX_HOST_NAME,
      );

      if (host < 0 || ip < 0) {
        throw const ENetException('Failed to get enet host or ip.');
      }

      final lookup = await InternetAddress.lookup(
        cHost.cast<Utf8>().toDartString(),
      );

      final address = lookup.singleWhere(
        (addr) => addr.address == cIp.cast<Utf8>().toDartString(),
      );

      return address;
    } finally {
      calloc
        ..free(cHost)
        ..free(cIp);
    }
  }

  /// Resolves the given hostname and assigns it to the `host` field
  /// of the ENet address.
  ///
  /// [hostName] - The instance representing the hostname to resolve.
  ///
  /// Note: This operation depends on the system's DNS resolution capabilities.
  ///
  /// **Example**:
  /// ```dart
  /// final address = ENetAddress();
  /// address.setHost(InternetAddress('example.com'));
  /// print('Host set successfully');
  /// ```
  void setHost(InternetAddress hostName) {
    final cValue = hostName.host.toNativeUtf8();
    final err = bindings.enet_address_set_host(_address, cValue.cast<Char>());

    if (err < 0) {
      throw const ENetException('Failed to set enet host.');
    }
  }

  /// Retrieves the port assigned to the ENet address.
  ///
  /// This property provides the current port number associated with the address
  ///
  /// **Example**:
  /// ```dart
  /// final currentPort = address.port;
  /// print('The current port is $currentPort');
  /// ```
  int get port => _address.ref.port;

  /// Updates the port for the ENet address.
  ///
  /// Use this property to assign a specific port number to the address.
  /// Make sure the port is within the valid range (0–65535).
  ///
  /// **Example**:
  /// ```dart
  /// address.port = 3000;
  /// print('Port updated to 3000');
  /// ```
  set port(int value) => _address.ref.port = value;

  /// Accesses the low-level pointer to the ENet address structure.
  ///
  /// This getter provides the underlying C pointer for advanced use cases where
  /// direct interaction with the ENet library is necessary.
  ///
  /// **Example**:
  /// ```dart
  /// final rawPointer = address.pointer;
  /// // Pass the pointer to a low-level ENet function.
  /// someNativeFunction(rawPointer);
  /// ```
  Pointer<bindings.ENetAddress> get pointer => _address;
}
