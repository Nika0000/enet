import 'dart:ffi';

import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/core/address.dart';
import 'package:enet/src/core/packet.dart';
import 'package:enet/src/enet_exception.dart';
import 'package:enet/src/types.dart';

class ENetPeer {
  late final Pointer<bindings.ENetPeer> _peer;

  ENetPeer.parse(Pointer<bindings.ENetPeer> peer) : _peer = peer;
  ENetPeerState get state {
    return ENetPeerState.values.singleWhere(
      (value) => value.index == _peer.ref.state,
    );
  }

  ENetAddress get address => ENetAddress.parse(_peer.ref.address);

  int get channelCount => _peer.ref.channelCount;

  int get connectID => _peer.ref.connectID;

  int get packetLoss => _peer.ref.packetLoss;

  int get packetLossEpoch => _peer.ref.packetLossEpoch;

  int get packetLossVariance => _peer.ref.packetLossVariance;

  int get packetsLoss => _peer.ref.packetsLost;

  int get packetsSent => _peer.ref.packetsSent;

  int get packetThrottle => _peer.ref.packetThrottle;

  int get packetThrottleAcceleration => _peer.ref.packetThrottleAcceleration;

  int get packetThrottleCounter => _peer.ref.packetThrottleCounter;

  int get packetThrottleDeceleration => _peer.ref.packetThrottleDeceleration;

  int get packetThrottleEpoch => _peer.ref.packetThrottleEpoch;

  int get packetThrottleInterval => _peer.ref.packetThrottleInterval;

  int get packetThrottleLimit => _peer.ref.packetThrottleLimit;

  int get pingInterval => _peer.ref.pingInterval;

  int get reliableDataInTransit => _peer.ref.reliableDataInTransit;

  int get roundTripTime => _peer.ref.roundTripTime;

  int get roundTripTimeVariance => _peer.ref.roundTripTimeVariance;

  int get timeoutLimit => _peer.ref.timeoutLimit;

  int get timeoutMaximum => _peer.ref.timeoutMaximum;

  int get timeoutMinimum => _peer.ref.timeoutMinimum;

  int get totalWaitingData => _peer.ref.totalWaitingData;

  void disconnect({int data = 0}) {
    return bindings.enet_peer_disconnect(_peer, data);
  }

  void disconnectLater({int data = 0}) {
    return bindings.enet_peer_disconnect_later(_peer, data);
  }

  void disconnectNow({int data = 0}) {
    return bindings.enet_peer_disconnect_now(_peer, data);
  }

  void ping() => bindings.enet_peer_ping(_peer);

  void set pingInterval(int interval) {
    return bindings.enet_peer_ping_interval(_peer, interval);
  }

  ENetPacket? receive(int channelID) {
    var packet = bindings.enet_peer_receive(_peer, channelID);

    if (packet == nullptr) {
      return null;
    }

    return ENetPacket.parse(packet);
  }

  void reset() => bindings.enet_peer_reset(_peer);

  void send(int channelID, ENetPacket packet) {
    packet.done();
    int err = bindings.enet_peer_send(_peer, channelID, packet.pointer);

    if (err < 0) {
      throw ENetException('Failed to send packet.');
    }
  }

  void throttleConfigure({
    int interval = ENET_PEER_PACKET_THROTTLE_INTERVAL,
    int acceleration = ENET_PEER_PACKET_THROTTLE_ACCELERATION,
    int deceleration = ENET_PEER_PACKET_THROTTLE_DECELERATION,
  }) {
    return bindings.enet_peer_throttle_configure(
      _peer,
      interval,
      acceleration,
      deceleration,
    );
  }

  void timeout({
    int timeoutLimit = ENET_PEER_TIMEOUT_LIMIT,
    int timeoutMinimum = ENET_PEER_TIMEOUT_MINIMUM,
    int timeoutMaximum = ENET_PEER_TIMEOUT_MAXIMUM,
  }) {
    return bindings.enet_peer_timeout(
      _peer,
      timeoutLimit,
      timeoutMinimum,
      timeoutMaximum,
    );
  }

  @override
  int get hashCode => _peer.address;

  @override
  bool operator ==(Object other) {
    return (other is ENetPeer && other.hashCode == hashCode);
  }
}
