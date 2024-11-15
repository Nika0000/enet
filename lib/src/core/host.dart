import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:enet/enet.dart';
import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/enet_exception.dart';
import 'package:ffi/ffi.dart';

final class ENetHost implements Finalizable {
  late Pointer<bindings.ENetHost> _host;

  static final Finalizer<Pointer<bindings.ENetHost>> _finalizer = Finalizer((pointer) {
    bindings.enet_host_destroy(pointer);
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
    this.incomingBandwidth = 0,
    this.outgoingBandwidth = 0,
  }) {
    _host = bindings.enet_host_create(
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
    Pointer<bindings.ENetPeer> cPeer = bindings.enet_host_connect(
      _host,
      address.pointer,
      channelCount,
      data,
    );

    if (cPeer == nullptr) {
      throw ENetException(
        'Failed to connect to host ${address.host}.',
      );
    }

    return ENetPeer.parse(cPeer);
  }

  Future<ENetEvent> service({int timeout = 0}) async {
    Pointer<bindings.ENetEvent> cEvent = malloc<bindings.ENetEvent>();
    int res = 0;

    try {
      if (timeout > 0) {
        ReceivePort receivePort = ReceivePort();

        await Isolate.spawn(_serviceIsolated, [receivePort.sendPort, _host, cEvent, timeout]);
        res = await receivePort.first;
      } else {
        res = bindings.enet_host_service(_host, cEvent, timeout);
      }

      if (res < 0) {
        throw ENetException("Host service failed.");
      }

      return ENetEvent.parse(cEvent);
    } finally {
      malloc.free(cEvent);
    }
  }

  void destroy() => bindings.enet_host_destroy(_host);

  void flush() => bindings.enet_host_flush(_host);

  void broadcast(int channelID, ENetPacket packet) {
    packet.done();
    // bindings.enet_host_broadcast(_host, channelID, packet.pointer);
  }
}

void _serviceIsolated(List<dynamic> arg) async {
  final SendPort port = arg[0] as SendPort;
  final Pointer<bindings.ENetHost> host = arg[1] as Pointer<bindings.ENetHost>;
  final Pointer<bindings.ENetEvent> event = arg[2] as Pointer<bindings.ENetEvent>;
  final int timeout = arg[3] as int;

  final res = bindings.enet_host_service(host, event, timeout);
  port.send(res);
}
