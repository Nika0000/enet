import 'dart:ffi';

import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:enet/src/core/address.dart';
import 'package:enet/src/core/packet.dart';
import 'package:enet/src/enet_exception.dart';
import 'package:enet/src/types.dart';

/// {@template enet_peer}
/// An ENet peer which data packets may be sent or received from.
/// {@endtemplate}
class ENetPeer {
  /// Crates a [ENetPeer] instance by parsing an exitig [bindings.ENetPeer]
  ///
  /// [peer] - A [bindings.ENetPeer] representing the existing native ENet
  /// address to be parsed and copied into the new instance.
  ///
  /// **Note**:
  /// - The provided [peer] is not retained but its values are copied.
  /// Modifying the original [peer] will not affect the parsed instance.
  /// - The lifecycle of the allocated memory is managed automatically, ensuring
  /// proper cleanup when the instance is no longer in use.
  ENetPeer.parse(Pointer<bindings.ENetPeer> peer) : _peer = peer;

  late final Pointer<bindings.ENetPeer> _peer;

  /// {@macro enet_peer_state}
  ENetPeerState get state {
    return ENetPeerState.values.singleWhere(
      (value) => value.index == _peer.ref.state,
    );
  }

  /// Internet address of the peer.
  ENetAddress get address => ENetAddress.parse(_peer.ref.address);

  /// Number of channels allocated for communication with peer.
  int get channelCount => _peer.ref.channelCount;

  /// The unique connection ID for identifying this peer.
  int get connectID => _peer.ref.connectID;

  /// mean packet loss of reliable packets as a ratio with respect to the
  /// constant `ENET_PEER_PACKET_LOSS_SCALE`
  int get packetLoss => _peer.ref.packetLoss;

  /// mean round trip time (RTT), in milliseconds, between sending a reliable
  /// packet and receiving its acknowledgement
  int get roundTripTime => _peer.ref.roundTripTime;

  ///	Downstream bandwidth of the client in bytes/second
  int get incommingBandwidth => _peer.ref.incomingBandwidth;

  /// Upstream bandwidth of the client in bytes/second.
  int get outgoingBandwidth => _peer.ref.outgoingBandwidth;

  /// The interval, in milliseconds, between periodic pings to the peer.
  int get pingInterval => _peer.ref.pingInterval;

  /// The total number of packets sent to this peer.
  int get packetsSent => _peer.ref.packetsSent;

  /// The total number of packets lost during communication with this peer.
  int get packetsLost => _peer.ref.packetsLost;

  /// The current packet throttle for controlling outgoing packet rates.
  int get packetThrottle => _peer.ref.packetThrottle;

  /// The acceleration factor for packet throttling.
  int get packetThrottleAcceleration => _peer.ref.packetThrottleAcceleration;

  /// The deceleration factor for packet throttling.
  int get packetThrottleDeceleration => _peer.ref.packetThrottleDeceleration;

  /// The upper limit for packet throttling.
  int get packetThrottleLimit => _peer.ref.packetThrottleLimit;

  /// The maximum time, in milliseconds, before disconnecting the peer due
  /// to no activity.
  int get timeoutMaximum => _peer.ref.timeoutMaximum;

  /// The minimum time, in milliseconds, before considering the
  /// peer as disconnected.
  int get timeoutMinimum => _peer.ref.timeoutMinimum;

  /// The total amount of reliable data currently in transit to the peer.
  int get reliableDataInTransit => _peer.ref.reliableDataInTransit;

  /// The total amount of data waiting to be sent to the peer.
  int get totalWaitingData => _peer.ref.totalWaitingData;

  /// Request a disconnection from a peer.
  /// [data] - Data describing the disconnection.
  void disconnect({int data = 0}) {
    return bindings.enet_peer_disconnect(_peer, data);
  }

  /// Request a disconnection from a peer, but only after all queued
  /// outgoing packets are sent.
  /// [data] - Data describing the disconnection.
  void disconnectLater({int data = 0}) {
    return bindings.enet_peer_disconnect_later(_peer, data);
  }

  /// Force an immediate disconnection from a peer.
  /// [data] - Data describing the disconnection.
  void disconnectNow({int data = 0}) {
    return bindings.enet_peer_disconnect_now(_peer, data);
  }

  /// Sends a ping request to a peer.
  void ping() => bindings.enet_peer_ping(_peer);

  /// Sets the interval at which pings will be sent to a peer.
  ///
  /// Pings are used both to monitor the liveness of the connection and also to
  /// dynamically adjust the throttle during periods of low traffic so that the
  /// throttle has reasonable responsiveness during traffic spikes.
  ///
  /// [interval] - The interval at which to send pings.
  /// defaults to `ENET_PEER_PING_INTERVAL` if 0.
  set pingInterval(int interval) {
    return bindings.enet_peer_ping_interval(_peer, interval);
  }

  /// Attempts to dequeue any  ing queued packet.
  ///
  /// [channelID] - Holds the channel ID of the channel the packet was
  /// received on success
  ENetPacket? receive(int channelID) {
    final packet = bindings.enet_peer_receive(_peer, channelID);

    if (packet == nullptr) {
      return null;
    }

    return ENetPacket.parse(packet);
  }

  /// Forcefully disconnects a peer.
  void reset() => bindings.enet_peer_reset(_peer);

  /// Queues a packet to be sent.
  ///
  /// - [channelID] Channel on which to send.
  /// - [packet] Packet to send.
  ///
  /// On success, ENet will assume ownership of the packet, and so
  /// [ENetPacket.destroy] should not be called on it thereafter.
  /// On failure, the caller still must destroy the packet on its own as ENet
  /// has not queued the packet. The caller can also check the packet's
  /// referenceCount field after sending to check if ENet queued the packet
  /// and thus incremented the referenceCount.
  void send(int channelID, ENetPacket packet) {
    packet.done();
    final err = bindings.enet_peer_send(_peer, channelID, packet.pointer);

    if (err < 0) {
      throw const ENetException('Failed to send packet.');
    }
  }

  /// Configures throttle parameter for a peer.
  ///
  /// - [interval] Interval, in milliseconds, over which to measure lowest
  ///              mean RTT.
  /// - [acceleration] rate at which to increase the throttle probability as
  ///                  mean RTT declines.
  /// - [deceleration] rate at which to decrease the throttle probability as
  ///                  mean RTT increases
  ///
  /// Unreliable packets are dropped by ENet in response to the varying
  /// conditions of the Internet connection to the peer. The throttle represents
  /// a probability that an unreliable packet should not be dropped and thus
  /// sent by ENet to the peer. The lowest mean round trip time from the sending
  /// of a reliable packet to the receipt of its acknowledgement is measured
  /// over an amount of time specified by the interval parameter in milliseconds
  /// If a measured round trip time happens to be significantly less than the
  /// mean round trip time measured over the interval, then the throttle
  /// probability is increased to allow more traffic by an amount specified in
  /// the acceleration parameter, which is a ratio to the
  /// `ENET_PEER_PACKET_THROTTLE_SCALE` constant.
  /// If a measured round trip time happens to be significantly greater than
  /// the mean round trip time measured over the interval, then the throttle
  /// probability is decreased to limit traffic by an amount specified in the
  /// deceleration parameter, which is a ratio to the
  /// `ENET_PEER_PACKET_THROTTLE_SCALE` constant.
  /// When the throttle has a value of `ENET_PEER_PACKET_THROTTLE_SCALE`, no
  /// unreliable packets are dropped by ENet, and so 100% of all unreliable
  /// packets will be sent. When the throttle has a value of 0, all unreliable
  /// packets are dropped by ENet, and so 0% of all unreliable packets will
  /// be sent. Intermediate values for the throttle represent intermediate
  /// probabilities between 0% and 100% of unreliable packets being sent.
  /// The bandwidth limits of the local and foreign hosts are taken into account
  /// to determine a sensible limit for the throttle probability above which it
  /// should not raise even in the best of conditions.
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

  /// Sets the timeout parameters for a peer.
  ///
  /// - [timeoutLimit] The timeout limit.
  ///                  defaults to ENET_PEER_TIMEOUT_LIMIT if 0.
  /// - [timeoutMinimum] The timeout minimum.
  ///                    defaults to ENET_PEER_TIMEOUT_MINIMUM if 0.
  /// - [timeoutMaximum] The timeout maximum.
  ///                    defaults to ENET_PEER_TIMEOUT_MAXIMUM if 0.
  ///
  /// The timeout parameter control how and when a peer will timeout from a
  /// failure to acknowledge reliable traffic. Timeout values use an exponential
  /// backoff mechanism, where if a reliable packet is not acknowledge within
  /// some multiple of the average RTT plus a variance tolerance, the timeout
  /// will be doubled until it reaches a set limit. If the timeout is thus at
  /// this limit and reliable packets have been sent but not acknowledged within
  /// a certain minimum time period, the peer will be disconnected.
  /// Alternatively, if reliable packets have been sent but not acknowledged for
  /// a certain maximum time period, the peer will be disconnected regardless
  /// of the current timeout limit value.
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
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _peer.address;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    return other is ENetPeer && other.hashCode == hashCode;
  }
}
