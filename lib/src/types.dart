// ignore_for_file: constant_identifier_names

// General enums

const ENET_MAX_HOST_NAME = 257;

/// An ENet event type, as specified in [ENetEvent].
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

  final int value;

  const ENetEventType(this.value);
}

/// Packet flag bit constants.
///
/// The host must be specified in network byte-order, and the port must be in
/// host byte-order. The `InternetAddress.anyIPv4` may be used to specify the
/// default server host.
enum ENetPacketFlag {
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

  final int value;

  const ENetPacketFlag(this.value);
}

enum ENetPeerState {
  disconnected(0),
  connecting(1),
  acknowledgingConnect(2),
  connectionPending(3),
  connectionSucceeded(4),
  connected(5),
  disconnectLater(6),
  disconnecting(7),
  acknowledgingDisconnect(8),
  zombie(9);

  final int value;

  const ENetPeerState(this.value);
}

enum ENetProtocolCommand {
  none(0),
  acknowledge(1),
  connect(2),
  verifyConnect(3),
  disconnect(4),
  ping(5),
  sendReliable(6),
  sendUnreliable(7),
  sendFragment(8),
  sendUnsequenced(9),
  bandwidthLimit(10),
  throttleConfigure(11),
  sendUnreliableFragment(12),
  count(13),
  mask(15);

  final int value;

  const ENetProtocolCommand(this.value);
}

enum ENetProtocolFlag {
  ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE(128),
  ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED(64),
  ENET_PROTOCOL_HEADER_FLAG_COMPRESSED(16384),
  ENET_PROTOCOL_HEADER_FLAG_SENT_TIME(32768),
  ENET_PROTOCOL_HEADER_FLAG_MASK(49152),
  ENET_PROTOCOL_HEADER_SESSION_MASK(12288),
  ENET_PROTOCOL_HEADER_SESSION_SHIFT(12);

  final int value;

  const ENetProtocolFlag(this.value);
}

enum ENetSocketWait {
  none(0),
  send(1 << 0),
  receive(1 << 1),
  interrupt(1 << 2);

  final int value;

  const ENetSocketWait(this.value);
}

enum ENetSocketType {
  stream(1),
  datagram(2);

  final int value;

  const ENetSocketType(this.value);
}

enum ENetSocketShutdown {
  read(0),
  write(1),
  readWrite(2);

  final int value;

  const ENetSocketShutdown(this.value);
}

enum ENetSocketOption {
  nonblock(1),
  broadcast(2),
  rcvbuf(3),
  sndbuf(4),
  reuseaddr(5),
  rcvtimeo(6),
  sndtimeo(7),
  error(8),
  nodelay(9),
  ipv6V6Only(10);

  final int value;

  const ENetSocketOption(this.value);
}
