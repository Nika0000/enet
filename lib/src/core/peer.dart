import 'dart:ffi';

import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/core/packet.dart';
import 'package:enet/src/enet_exception.dart';

class ENetPeer {
  late final Pointer<bindings.ENetPeer> _peer;

  ENetPeer.parse(Pointer<bindings.ENetPeer> peer) : _peer = peer {}

  void send(int channelID, ENetPacket packet) {
    packet.done();
    int err = bindings.enet_peer_send(_peer, channelID, packet.pointer);

    if (err < 0) {
      throw ENetException('Failed to send packet.');
    }
  }

  void disconnect({int data = 0}) {
    bindings.enet_peer_disconnect(_peer, data);
  }
}
