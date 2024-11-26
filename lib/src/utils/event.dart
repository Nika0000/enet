import 'dart:ffi';

import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/core/host.dart';
import 'package:enet/src/core/packet.dart';
import 'package:enet/src/core/peer.dart';
import 'package:enet/src/types.dart';

/// {@template enet_event}
/// An ENet event as returned by [ENetHost.service].
/// {@endtemplate}
final class ENetEvent {
  /// {@macro enet_event}
  ENetEvent(this.channelID, this.type, this.peer, this.data, this.packet);

  /// Creates an [ENetEvent] instance by parsing an
  /// existing [bindings.ENetEvent]
  ///
  /// [event] - A [bindings.ENetEvent] representing the existing native ENet
  /// address to be parsed and copied into the new instance.
  ///
  /// **Note**:
  /// - The provided [event] is not retained but its values are copied.
  /// Modifying the original [event] will not affect the parsed instance.
  /// - The lifecycle of the allocated memory is managed automatically, ensuring
  /// proper cleanup when the instance is no longer in use.
  factory ENetEvent.parse(Pointer<bindings.ENetEvent> event) {
    final cType = ENetEventType.values.firstWhere(
      (e) => e.value == event.ref.type,
    );
    final cPacket = event.ref.packet == nullptr
        ? null
        : ENetPacket.parse(
            event.ref.packet,
          );
    final cPeer = event.ref.peer == nullptr
        ? null
        : ENetPeer.parse(
            event.ref.peer,
          );
    return ENetEvent(
      event.ref.channelID,
      cType,
      cPeer,
      event.ref.data,
      cPacket,
    );
  }

  /// channel on the peer that generated the event, if appropriate
  final int channelID;

  /// {@macro enet_event_type}
  final ENetEventType type;

  /// peer that generated a connect, disconnect or receive event
  final ENetPeer? peer;

  /// data associated with the event, if appropriate
  final int data;

  /// packet associated with the event, if appropriate
  final ENetPacket? packet;
}
