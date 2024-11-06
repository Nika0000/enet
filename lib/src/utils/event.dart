import 'dart:ffi';

import 'package:enet/src/types.dart';
import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/core/packet.dart';
import 'package:enet/src/core/peer.dart';

final class ENetEvent {
  final int channelID;
  final ENetEventType type;
  final ENetPeer? peer;
  final int data;
  final ENetPacket? packet;

  ENetEvent(this.channelID, this.type, this.peer, this.data, this.packet);

  factory ENetEvent.parse(Pointer<bindings.ENetEvent> event) {
    final cType = ENetEventType.values.firstWhere((e) => e.value == event.ref.type);
    final cPacket = event.ref.packet == nullptr ? null : ENetPacket.parse(event.ref.packet);
    final cPeer = event.ref.peer == nullptr ? null : ENetPeer.parse(event.ref.peer);
    return ENetEvent(
      event.ref.channelID,
      cType,
      cPeer,
      event.ref.data,
      cPacket,
    );
  }
}
