// You have generated a new plugin project without specifying the `--platforms`
// flag. An FFI plugin project that supports no platforms is generated.
// To add platforms, run `flutter create -t plugin_ffi --platforms <platforms> .`
// in this directory. You can also find a detailed instruction on how to
// add platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'package:enet/src/bindings/enet_bindings.dart' as binding;
import 'package:enet/src/bindings/lib_enet.dart';

import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

final _instance = LibENet.instance;

class ENet {
  ENet._() {
    _instance.enet_initialize();
  }

  factory ENet.initialize() {
    return ENet._();
  }

  void create(
      //  ENetAddress address,
      ) {
    var client = _instance.enet_host_create(ffi.nullptr, 1, 2, 0, 0);

    if (client == null) {
      print('Error will trying to create enet host');
    }

    final enetAddress = calloc<binding.ENetAddress>();
    final enetEvent = calloc<binding.ENetEvent>();
    var enetPeer = calloc<binding.ENetPeer>();

    _instance.enet_address_set_host(enetAddress, "192.168.171.214".toNativeUtf8().cast<ffi.Char>());
    enetAddress.ref.port = 7777;

    var peer = _instance.enet_host_connect(client, enetAddress, 2, 0);

    if (peer == null) {
      print('no available peers for initiating an enet connection');
    }

    if (_instance.enet_host_service(client, enetEvent, 10000) > 0 && enetEvent.ref.type == 1) {
      print("Connection to server succeeded.\n");
    } else {
      print("Connection to server failed.\n");
    }

    bool isRunning = true;

    while (isRunning) {
      print(_instance.enet_host_service(client, enetEvent, 0));
      while (_instance.enet_host_service(client, enetEvent, 0) > 0) {
        switch (enetEvent.ref.type) {
          case 3:
            print('received message from peer:');
            break;
          case 1:
            print('connected to peer');
            break;
          case 2:
            print('disconnect from peer.');
            break;
          default:
            break;
        }
      }
      String message = "hellp from peer";
      var packet = _instance.enet_packet_create(message.toNativeUtf8().cast<ffi.Void>(), message.length, 1);
      _instance.enet_peer_send(peer, 0, packet);
      _instance.enet_host_flush(client);

      isRunning = false;
    }

    /*   if (_instance.enet_initialize() != 0) {
      print('An error occured while initializing enet');
    }

    ffi.Pointer<binding.ENetAddress> address = calloc<binding.ENetAddress>();
    var client = _instance.enet_host_create(address, 1, 2, 0, 0);

    if (client?.ref == null) {
      print('An error occured while trying to create an enet client host');
    }

    print(client?.ref.randomSeed);

    ffi.Pointer<binding.ENetEvent> event = calloc<binding.ENetEvent>();
    ffi.Pointer<binding.ENetPeer>? peer;

    ffi.Pointer<ffi.Char> ipAddress = stringToCString("192.168.171.214");
    _instance.enet_address_set_host_old(address, ipAddress);

    address.ref.port = 7777;

    peer = _instance.enet_host_connect(client!, address, 2, 0);

    print(peer?.ref.connectID);

    if (peer?.ref == null) {
      print('no available peers for initating an enet connection');
    }

    if (_instance.enet_host_service(client, event, 5000) > 0) {
      print("enet evenet received");
    }

    print("event${event.ref.type}");

    var res = _instance.enet_host_service(client, event, 5000);

    print('host res: $res'); */

/*     print(address.getHost());
    print(address.port);
    ffi.Pointer<binding.ENetHost> hostPtr = _instance.enet_host_create(address._addressPtr, 1, 2, 0, 0, 0);

    binding.ENetHost host = hostPtr.ref;

    ffi.Pointer<binding.ENetEvent> event = calloc<binding.ENetEvent>();

    final ffi.Pointer<binding.ENetAddress> _addressPtr = calloc<binding.ENetAddress>();

    _addressPtr.ref.port = 7777;

    ffi.Pointer<ffi.Char> ipAddress = stringToCString("127.0.0.1");

    _instance.enet_address_set_ip(_addressPtr, ipAddress);
    _instance.enet_host_connect(hostPtr, _addressPtr, 2, 9);

    Timer.periodic(Duration(seconds: 1), (timer) {
      print(host.address.port);
      print(host.peers.ref.incomingPeerID);
    }); */
  }

  int linkedVersion() {
    return _instance.enet_linked_version();
  }

  void deinitialize() {
    _instance.enet_deinitialize();
  }
}
