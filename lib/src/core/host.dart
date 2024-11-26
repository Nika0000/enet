import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:enet/enet.dart';
import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/enet_exception.dart';
import 'package:ffi/ffi.dart';

/// {@template enet_host}
/// Enet host to service.
/// {@endtemplate}
final class ENetHost implements Finalizable {
  /// Creates a host for communicating to peers.
  ///
  /// **NOTE**:
  /// ENet will strategically drop packets on specific sides of a connection
  /// between hosts to ensure the host's bandwidth is not overwhelmed.
  /// The bandwidth parameters also determine the window size of a connection
  /// which limits the amount of reliable packets that may be in transit
  /// at any given time.
  ENetHost.create({
    required this.peerCount,
    required this.channelLimit,
    this.address,
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
      throw Exception('Failed to create ENet Host.');
    }

    _finalizer.attach(this, _host.cast(), detach: this);
  }

  late Pointer<bindings.ENetHost> _host;

  static final Finalizer<Pointer<bindings.ENetHost>> _finalizer = Finalizer(
    bindings.enet_host_destroy,
  );

  /// the address at which other peers may connect to this host.
  ///
  /// If null, then no peers may connect to the host.
  final ENetAddress? address;

  /// The maximum number of peers that should be allocated for the host.
  final int peerCount;

  /// The maximum number of channels allowed.
  ///
  /// if 0, then this is equivalent to `ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT`
  final int channelLimit;

  /// Downstream bandwidth of the host in bytes/second.
  ///
  /// if 0, ENet will assume unlimited bandwidth.
  final int incomingBandwidth;

  /// Upstream bandwidth of the host in bytes/second.
  ///
  /// if 0, ENet will assume unlimited bandwidth.
  final int outgoingBandwidth;

  /// Initiates a connection to a foreign host.
  ///
  /// [data] - The user data supplied to the receiving host.
  ///
  /// **Note**: The peer returned will have not completed the connection until
  /// [service] notifies of an [ENetEventType.connect] event for the peer.
  ENetPeer connect(ENetAddress address, int channelCount, {int data = 0}) {
    final cPeer = bindings.enet_host_connect(
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

  /// Waits for events on the host specified and shuttles packets between
  /// the host and its peers.
  ///
  /// [timeout] - numer of millisecounds that ENet should wait for event.
  ///
  /// **Note**:
  /// [service] should be called fairly reguraly for adequate performance.
  Future<ENetEvent> service({int timeout = 0}) async {
    final cEvent = malloc<bindings.ENetEvent>();
    var res = 0;

    try {
      if (timeout > 0) {
        final receivePort = ReceivePort();

        await Isolate.spawn(_serviceIsolated, [
          receivePort.sendPort,
          _host,
          cEvent,
          timeout,
        ]);

        res = await receivePort.first as int;
      } else {
        res = bindings.enet_host_service(_host, cEvent, timeout);
      }

      if (res < 0) {
        throw const ENetException('Host service failed.');
      }

      return ENetEvent.parse(cEvent);
    } finally {
      malloc.free(cEvent);
    }
  }

  /// Destroys the host and all resources associated with it.
  void destroy() => bindings.enet_host_destroy(_host);

  /// Sends any queued packets on the host specified to its designated peers.
  void flush() => bindings.enet_host_flush(_host);

  /// Queues a packet to be sent to all peers associated with the host.
  void broadcast(int channelID, ENetPacket packet) {
    packet.done();
    // bindings.enet_host_broadcast(_host, channelID, packet.pointer);
  }
}

Future<void> _serviceIsolated(List<dynamic> arg) async {
  final port = arg[0] as SendPort;
  final host = arg[1] as Pointer<bindings.ENetHost>;
  final event = arg[2] as Pointer<bindings.ENetEvent>;
  final timeout = arg[3] as int;

  final res = bindings.enet_host_service(host, event, timeout);
  port.send(res);
}
