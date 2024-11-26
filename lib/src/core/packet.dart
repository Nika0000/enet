import 'dart:core';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:enet/enet.dart';
import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:ffi/ffi.dart';

/// {@template enet_packet}
/// An [ENetPacket] that may be sent to or received from a peer.
/// {@endtemplate}
class ENetPacket implements Finalizable {
  /// Crates a [ENetPacket] instance by parsing an exitig [bindings.ENetAddress]
  ///
  /// [packet] - A [bindings.ENetAddress] representing the existing native ENet
  /// address to be parsed and copied into the new instance.
  ///
  /// **Note**:
  /// - The provided [packet] is not retained but its values are copied.
  /// Modifying the original [packet] will not affect the parsed instance.
  /// - The lifecycle of the allocated memory is managed automatically, ensuring
  /// proper cleanup when the instance is no longer in use.
  ENetPacket.parse(Pointer<bindings.ENetPacket> packet)
      : _packet = packet,
        data = _extractDataFromPointer(packet),
        flags = ENetPacketFlag.values.singleWhere(
          (e) => e.value == packet.ref.flags,
          orElse: () => ENetPacketFlag.none,
        ) {
    _finalizer.attach(this, _packet.cast(), detach: this);
  }

  /// Creates a packet that may be sent to a peer.
  ///
  /// - [data] Initial contents of the packet`s data.
  /// - [flags] The flags for this packet as described for the [ENetPacketFlag].
  factory ENetPacket.create({
    required Uint8List data,
    ENetPacketFlag flags = ENetPacketFlag.none,
  }) {
    return ENetPacket._init(data, flags);
  }

  ENetPacket._init(this.data, this.flags) {
    _packet = _createPacket();
    _finalizer.attach(this, _packet.cast(), detach: this);
  }
  late Pointer<bindings.ENetPacket> _packet;

  /// Initial contents of the packet`s data.
  final Uint8List data;

  /// The flags for this packet as described for the [ENetPacketFlag].
  final ENetPacketFlag flags;

  static final Finalizer<Pointer<bindings.ENetPacket>> _finalizer = Finalizer(
    bindings.enet_packet_destroy,
  );

  static Uint8List _extractDataFromPointer(
    Pointer<bindings.ENetPacket> packet,
  ) {
    return Uint8List.fromList(
      packet.ref.data.cast<Uint8>().asTypedList(packet.ref.dataLength),
    );
  }

  /// Destroys the packet and deallocates its data.
  void destroy() {
    _finalizer.detach(this);
    bindings.enet_packet_destroy(_packet);
  }

  Pointer<bindings.ENetPacket> _createPacket() {
    final cData = malloc<Uint8>(data.length);
    cData.asTypedList(data.length).setAll(0, data);
    try {
      _packet = bindings.enet_packet_create(
        cData.cast(),
        data.length,
        flags.value,
      );

      if (_packet == nullptr) {
        throw Exception('Failed to create packet');
      }

      return _packet;
    } finally {
      malloc.free(cData);
    }
  }

  /// Detachs from the finalizer
  void done() => _finalizer.detach(this);

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
  Pointer<bindings.ENetPacket> get pointer => _packet;
}
