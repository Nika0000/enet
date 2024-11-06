import 'dart:ffi';

import 'package:enet/enet_dart.dart';
import 'package:enet/src/core/address.dart';
import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/bindings/lib_enet.dart';
import 'package:enet/src/core/packet.dart';
import 'package:enet/src/utils/event.dart';
import 'package:ffi/ffi.dart';

final _instance = LibENet.instance;

class ENetHost implements Finalizable {
  late Pointer<bindings.ENetHost> _host;

  static final Finalizer<Pointer<bindings.ENetHost>> _finalizer = Finalizer((pointer) {
    _instance.enet_host_destroy(pointer);
  });

  final ENetAddress? address;

  final int peerCount;

  final int channelLimit;

  final int incomingBandwidth;

  final int outgoingBandwidth;

  ENetHost.create({
    this.address,
    required this.peerCount,
    required this.channelLimit,
    required this.incomingBandwidth,
    required this.outgoingBandwidth,
  }) {
    _host = _instance.enet_host_create(
      address?.pointer ?? nullptr,
      peerCount,
      channelLimit,
      incomingBandwidth,
      outgoingBandwidth,
    );

    if (_host == nullptr) {
      throw Exception("Failed to create ENet Host.");
    }

    _finalizer.attach(this, _host.cast(), detach: this);
  }

  ENetPeer connect(ENetAddress address, int channelCount, {int data = 0}) {
    Pointer<bindings.ENetPeer> cPeer = _instance.enet_host_connect(
      _host,
      address.pointer,
      channelCount,
      data,
    );

    if (cPeer == nullptr) {
      throw Exception('ENet clouldn`t connect.');
    }

    // TODO: return ENet peer
    return ENetPeer.parse(cPeer);
  }

  ENetEvent? service({int timeout = 5000}) {
    Pointer<bindings.ENetEvent> cEvent = malloc<bindings.ENetEvent>();

    try {
      int err = _instance.enet_host_service(_host, cEvent, timeout);

      if (err == 0) {
        //there is no event to return
        return null;
      }
      if (err < 0) {
        throw Exception("ENet host service failure.");
      }
      // TODO: throw if error
      // TODO: return enet event
      return ENetEvent.parse(cEvent);
    } finally {
      // malloc.free(cEvent);
    }
  }

  void flush() => _instance.enet_host_flush(_host);

  void broadcast(int channelID, ENetPacket packet) {
    // TODO: Detach packet
    _instance.enet_host_broadcast(_host, channelID, packet.pointer);
  }
}
