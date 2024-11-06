// ignore_for_file: constant_identifier_names

// General enums

const ENET_MAX_HOST_NAME = 257;

enum ENetEventType {
  /// no event occurred within the specified time limit
  ENET_EVENT_TYPE_NONE(0),

  /// a connection request initiated by enet_host_connect has completed.
  /// The peer field contains the peer which successfully connected.
  ENET_EVENT_TYPE_CONNECT(1),

  /// a peer has disconnected.  This event is generated on a successful
  /// completion of a disconnect initiated by enet_peer_disconnect, if
  /// a peer has timed out.  The peer field contains the peer
  /// which disconnected. The data field contains user supplied data
  /// describing the disconnection, or 0, if none is available.
  ENET_EVENT_TYPE_DISCONNECT(2),

  /// a packet has been received from a peer.  The peer field specifies the
  /// peer which sent the packet.  The channelID field specifies the channel
  /// number upon which the packet was received.  The packet field contains
  /// the packet that was received; this packet must be destroyed with
  /// enet_packet_destroy after use.
  ENET_EVENT_TYPE_RECEIVE(3),

  /// a peer is disconnected because the host didn't receive the acknowledgment
  /// packet within certain maximum time out. The reason could be because of bad
  /// network connection or  host crashed.
  ENET_EVENT_TYPE_DISCONNECT_TIMEOUT(4);

  final int value;

  const ENetEventType(this.value);
}

/// Packet flag bit constants.
///
/// The host must be specified in network byte-order, and the port must be in
/// host byte-order. The constant ENET_HOST_ANY may be used to specify the
/// default server host.
///
/// @sa ENetPacket
enum ENetPacketFlag {
  /// packet must be received by the target peer and resend attempts should be made until the packet is delivered
  ENET_PACKET_FLAG_RELIABLE(1),

  /// packet will not be sequenced with other packets not supported for reliable packets
  ENET_PACKET_FLAG_UNSEQUENCED(2),

  /// packet will not allocate data, and user must supply it instead
  ENET_PACKET_FLAG_NO_ALLOCATE(4),

  /// packet will be fragmented using unreliable (instead of reliable) sends if it exceeds the MTU
  ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT(8),

  ///  whether the packet has been sent from all queues it has been entered into
  ENET_PACKET_FLAG_SENT(256);

  final int value;

  const ENetPacketFlag(this.value);
}

enum ENetPeerState {
  ENET_PEER_STATE_DISCONNECTED(0),
  ENET_PEER_STATE_CONNECTING(1),
  ENET_PEER_STATE_ACKNOWLEDGING_CONNECT(2),
  ENET_PEER_STATE_CONNECTION_PENDING(3),
  ENET_PEER_STATE_CONNECTION_SUCCEEDED(4),
  ENET_PEER_STATE_CONNECTED(5),
  ENET_PEER_STATE_DISCONNECT_LATER(6),
  ENET_PEER_STATE_DISCONNECTING(7),
  ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT(8),
  ENET_PEER_STATE_ZOMBIE(9);

  final int value;

  const ENetPeerState(this.value);
}

enum ENetProtocolCommand {
  ENET_PROTOCOL_COMMAND_NONE(0),
  ENET_PROTOCOL_COMMAND_ACKNOWLEDGE(1),
  ENET_PROTOCOL_COMMAND_CONNECT(2),
  ENET_PROTOCOL_COMMAND_VERIFY_CONNECT(3),
  ENET_PROTOCOL_COMMAND_DISCONNECT(4),
  ENET_PROTOCOL_COMMAND_PING(5),
  ENET_PROTOCOL_COMMAND_SEND_RELIABLE(6),
  ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE(7),
  ENET_PROTOCOL_COMMAND_SEND_FRAGMENT(8),
  ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED(9),
  ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT(10),
  ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE(11),
  ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT(12),
  ENET_PROTOCOL_COMMAND_COUNT(13),
  ENET_PROTOCOL_COMMAND_MASK(15);

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
  ENET_SOCKET_WAIT_NONE(0),
  ENET_SOCKET_WAIT_SEND(1 << 0),
  ENET_SOCKET_WAIT_RECEIVE(1 << 1),
  ENET_SOCKET_WAIT_INTERRUPT(1 << 2);

  final int value;

  const ENetSocketWait(this.value);
}

enum ENetSocketType {
  ENET_SOCKET_TYPE_STREAM(1),
  ENET_SOCKET_TYPE_DATAGRAM(2);

  final int value;

  const ENetSocketType(this.value);
}

enum ENetSocketShutdown {
  ENET_SOCKET_SHUTDOWN_READ(0),
  ENET_SOCKET_SHUTDOWN_WRITE(1),
  ENET_SOCKET_SHUTDOWN_READ_WRITE(2);

  final int value;

  const ENetSocketShutdown(this.value);
}

enum ENetSocketOption {
  ENET_SOCKOPT_NONBLOCK(1),
  ENET_SOCKOPT_BROADCAST(2),
  ENET_SOCKOPT_RCVBUF(3),
  ENET_SOCKOPT_SNDBUF(4),
  ENET_SOCKOPT_REUSEADDR(5),
  ENET_SOCKOPT_RCVTIMEO(6),
  ENET_SOCKOPT_SNDTIMEO(7),
  ENET_SOCKOPT_ERROR(8),
  ENET_SOCKOPT_NODELAY(9),
  ENET_SOCKOPT_IPV6_V6ONLY(10);

  final int value;

  const ENetSocketOption(this.value);
}
