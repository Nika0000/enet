// ignore_for_file: constant_identifier_names

import 'dart:io';

/// The maximum length for an ENet host name (including the null-terminator).
/// This value is typically used to define the maximum allowed size for the host
/// name in ENet operations.
const int ENET_MAX_HOST_NAME = 257;

/// The time interval (in milliseconds) used for packet throttling on a peer.
/// This value determines the rate at which the peer can send packets, and
/// is used as part of the throttling mechanism to manage traffic.
const int ENET_PEER_PACKET_THROTTLE_INTERVAL = 500;

/// The acceleration factor for packet throttling on a peer.
/// This value controls how quickly the throttle interval decreases when the
/// peer is sending packets at a high rate.
const int ENET_PEER_PACKET_THROTTLE_ACCELERATION = 2;

/// The deceleration factor for packet throttling on a peer.
/// This value controls how quickly the throttle interval increases when the
/// peer is sending packets at a low rate or if packet congestion occurs.
const int ENET_PEER_PACKET_THROTTLE_DECELERATION = 2;

/// The timeout limit for a peer's connection, expressed in milliseconds.
/// This is typically used to determine how long to wait before considering
/// the peer to have timed out. A value of `32` may indicate no timeout limit.
const int ENET_PEER_TIMEOUT_LIMIT = 32;

/// The minimum allowed timeout for a peer's connection, expressed in
/// milliseconds. This value is used to set the minimum threshold for timeouts.
/// A value of `5000` may indicate that no minimum timeout is enforced.
const int ENET_PEER_TIMEOUT_MINIMUM = 5000;

/// The maximum allowed timeout for a peer's connection, expressed in
/// milliseconds. This value is used to set the maximum threshold for timeouts.
/// A value of `30000` may indicate that no maximum timeout is enforced.
const int ENET_PEER_TIMEOUT_MAXIMUM = 30000;

/// An ENet event type, as specified in `ENetEvent`.
enum ENetEventType {
  /// No event occurred within the specified time limit
  none(0),

  /// A connection request initiated by enet_host_connect has completed.
  /// The peer field contains the peer which successfully connected.
  connect(1),

  /// A peer has disconnected.
  /// This event is generated on a successful completion of a disconnect
  /// initiated by `peer.disconnect()`, if a peer has timed out, or if a
  /// connection request intialized by `host.connect()` has timed out.
  disconnect(2),

  ///	a packet has been received from a peer.
  receive(3),

  /// a peer is disconnected because the host didn't receive the acknowledgment
  /// packet within certain maximum time out. The reason could be because of bad
  /// network connection or  host crashed.
  disconnectTimeout(4);

  const ENetEventType(this.value);

  /// The integer representation of the packet flag.
  final int value;
}

/// Packet flag bit constants.
///
/// The host must be specified in network byte-order, and the port must be in
/// host byte-order. The [InternetAddress.anyIPv4] may be used to specify the
/// default server host.
enum ENetPacketFlag {
  /// No special behavior.
  none(0),

  /// packet must be received by the target peer and resend attempts should be
  /// made until the packet is delivered
  reliable(1),

  /// packet will not be sequenced with other packets not supported for
  /// reliable packets
  unsequenced(2),

  /// packet will not allocate data, and user must supply it instead
  noAllocate(4),

  /// packet will be fragmented using unreliable (instead of reliable) sends
  /// if it exceeds the MTU
  unreliableFragment(8),

  /// whether the packet has been sent from all queues it has been entered into
  sent(256);

  const ENetPacketFlag(this.value);

  /// The integer representation of the packet flag.
  final int value;
}

/// {@template enet_peer_state}
///
/// Tracks the connection lifecycle of a peer.
///
/// {@endtemplate}
enum ENetPeerState {
  /// The peer is not connected to any host.
  disconnected(0),

  /// The peer is attempting to establish a connection.
  connecting(1),

  /// The peer is acknowledging a connection request.
  acknowledgingConnect(2),

  /// The peer`s connection is pending completion.
  connectionPending(3),

  /// The peer`s connection has been successfully established.
  connectionSucceeded(4),

  /// The peer is fully connected and ready for communication.
  connected(5),

  /// The peer is scheduled to disconnect afther finishing queued operations.
  disconnectLater(6),

  /// The peer is actively in the process of disconnecting.
  disconnecting(7),

  /// The peer is acknowleding a disconnect request.
  acknowledgingDisconnect(8),

  /// The peer is a "zombie" state, meaning it is disconnected but not yet fully
  /// cleaned up.
  zombie(9);

  const ENetPeerState(this.value);

  /// The integer representation of the peer state.
  final int value;
}
