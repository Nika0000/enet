import 'dart:core';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:enet/enet_dart.dart';
import 'package:ffi/ffi.dart';

import 'package:enet/src/bindings/lib_enet.dart';
import 'package:enet/src/bindings/enet_bindings.dart' as bindings;

final _instance = LibENet.instance;

class ENetPacket implements Finalizable {
  late Pointer<bindings.ENetPacket> _packet;

  final Uint8List data;
  final ENetPacketFlag flags;

  static final Finalizer<Pointer<bindings.ENetPacket>> _finalizer = Finalizer((pointer) {
    _instance.enet_packet_destroy(pointer);
  });

  ENetPacket._init(this.data, this.flags) {
    _packet = _createPacket();
    _finalizer.attach(this, _packet.cast(), detach: this);
  }

  factory ENetPacket.create({required Uint8List data, required ENetPacketFlag flags}) {
    return ENetPacket._init(data, flags);
  }

  ENetPacket.parse(Pointer<bindings.ENetPacket> packet)
      : _packet = packet,
        data = _extractDataFromPointer(packet),
        flags = ENetPacketFlag.values.singleWhere(
          (element) => element.value == packet.ref.flags,
        ) {
    _finalizer.attach(this, _packet.cast(), detach: this);
  }

  static Uint8List _extractDataFromPointer(Pointer<bindings.ENetPacket> packet) {
    return Uint8List.fromList(packet.ref.data.cast<Uint8>().asTypedList(packet.ref.dataLength));
  }

  void destroy() {
    _finalizer.detach(this);
    _instance.enet_packet_destroy(_packet);
  }

  Pointer<bindings.ENetPacket> _createPacket() {
    final Pointer<Uint8> _data = malloc<Uint8>(data.length);
    _data.asTypedList(data.length).setAll(0, data);
    try {
      var _packet = _instance.enet_packet_create(
        _data.cast(),
        data.length,
        flags.value,
      );

      if (_packet == nullptr) {
        throw Exception('Failed to create packet');
      }

      return _packet;
    } finally {
      malloc.free(_data);
    }
  }

  Pointer<bindings.ENetPacket> get pointer => _packet;
}
