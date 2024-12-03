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
    late Isolate isolate;
    late Pointer<bindings.ENetEvent> cEvent;
    var err = 0;

    try {
      final receivePort = ReceivePort();

      isolate = await Isolate.spawn(
        _serviceIsolated,
        [
          receivePort.sendPort,
          _host,
          timeout,
          false,
        ],
      );

      final res = await receivePort.first as List;

      err = res[0] as int;
      cEvent = Pointer<bindings.ENetEvent>.fromAddress(res[1] as int);

      if (err < 0) {
        receivePort.close();
        throw const ENetException('Host service failed.');
      }

      return ENetEvent.parse(cEvent);
    } finally {
      malloc.free(cEvent);
      isolate.kill(priority: Isolate.immediate);
    }
  }

  final Completer<void> _serviceCompleter = Completer<void>();
  bool _isServiceRunning = false;

  /// Starts the ENet host service in an isolated process, listening for events
  /// and shuttling packets between the host and its peers.
  ///
  /// [event] - A function that processes incoming ENet should wait for events
  /// [timeout] - The number of milliseconds ENet should wait for events
  ///             before timing out. Defaults to `0` (no timeout).
  ///
  /// **Note**:
  /// This method must not be called if the service is already running.
  /// Events received from the isolate are forwarded to the [event]
  /// for processing. The service runs in a background isolate, ensuring
  /// non-blocking performance.
  Future<void> startService(
    void Function(ENetEvent event) event, {
    int timeout = 0,
  }) async {
    if (_isServiceRunning) {
      throw const ENetException('ENet host service already running.');
    }

    _isServiceRunning = true;

    final receivePort = ReceivePort();
    late Isolate isolate;

    try {
      isolate = await Isolate.spawn(
        _serviceIsolated,
        [
          receivePort.sendPort,
          _host,
          timeout,
          true,
        ],
      );

      receivePort.listen((msg) {
        final res = msg as List;
        final err = res[0] as int;

        if (err < 0) {
          receivePort.close();
          _serviceCompleter.completeError(
            const ENetException('Host service failed.'),
          );
        }

        final cEvent = Pointer<bindings.ENetEvent>.fromAddress(res[1] as int);
        try {
          event.call(ENetEvent.parse(cEvent));
        } finally {
          malloc.free(cEvent);
        }
      });

      await _serviceCompleter.future;
    } finally {
      receivePort.close();
      isolate.kill(priority: Isolate.immediate);
      _isServiceRunning = false;
    }
  }

  /// Stops the ENet host service, signaling completion and
  /// cleaning up resources.
  ///
  /// **Note**:
  /// This method should be called to gracefully terminate the service
  /// and ensure all associated resources are released.
  void stopService() {
    _serviceCompleter.complete();
    _isServiceRunning = false;
  }

  /// Destroys the host and all resources associated with it.
  void destroy() {
    if (!_serviceCompleter.isCompleted) {
      _serviceCompleter.complete();
    }
    bindings.enet_host_destroy(_host);
  }

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
  final timeout = arg[2] as int;
  final loop = arg[3] as bool;

  if (loop) {
    while (true) {
      final cEvent = malloc<bindings.ENetEvent>();
      final res = bindings.enet_host_service(host, cEvent, timeout);
      port.send([res, cEvent.address]);
    }
  } else {
    final cEvent = malloc<bindings.ENetEvent>();
    final res = bindings.enet_host_service(host, cEvent, timeout);
    port.send([res, cEvent.address]);
  }
}
