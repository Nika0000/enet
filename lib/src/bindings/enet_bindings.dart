// ignore_for_file: non_constant_identifier_names, camel_case_types
// ignore_for_file: public_member_api_docs

import 'dart:ffi' as ffi;

const _assetId = 'package:enet/enet.dart';

// =======================================================================//
// !
// ! ENET Functions
// !
// =======================================================================//

/// Initializes ENet globally.
/// Must be called prior to using any functions in ENet.
///
/// returns 0 on success < 0 on failure
@ffi.Native<ffi.Int Function()>(
  symbol: 'enet_initialize',
  assetId: _assetId,
)
external int enet_initialize();

/// Shuts down ENet globally.
/// Should be called when a program that has initialized ENet exits.
@ffi.Native<ffi.Void Function()>(
  symbol: 'enet_deinitialize',
  assetId: _assetId,
)
external void enet_deinitialize();

/// Gives the linked version of the ENet library.
/// returns the version number
@ffi.Native<ffi.Uint32 Function()>(
  symbol: 'enet_linked_version',
  assetId: _assetId,
)
external int enet_linked_version();

/// Returns the monotonic time in milliseconds.
/// Its initial value is unspecified unless otherwise set.
@ffi.Native<ffi.Uint32 Function()>(
  symbol: 'enet_time_get',
  assetId: _assetId,
)
external int enet_time_get();

// =======================================================================//
// !
// ! ADDRESS Functions
// !
// =======================================================================//

/// Attempts to do a reverse lookup of the host field in the address parameter.
///
/// Sets the null-terminated name of the host in [hostName] on success
///
/// Returns 0 on success, < 0 on failure
@ffi.Native<
    ffi.Int Function(
      ffi.Pointer<ENetAddress>,
      ffi.Pointer<ffi.Char>,
      ffi.Size,
    )>(
  symbol: 'enet_address_get_host_new',
  assetId: _assetId,
)
external int enet_address_get_host_new(
  ffi.Pointer<ENetAddress> address,
  ffi.Pointer<ffi.Char> hostName,
  int nameLength,
);

/// Attempts to resolve the host named by the parameter hostName and sets
/// the host field in the address parameter if successful.
///
/// Sets the [address] of the given [hostName] in address on success
///
/// Returns 0 on success, < 0 on failure
@ffi.Native<ffi.Int Function(ffi.Pointer<ENetAddress>, ffi.Pointer<ffi.Char>)>(
  symbol: 'enet_address_set_host_old',
  assetId: _assetId,
)
external int enet_address_set_host(
  ffi.Pointer<ENetAddress> address,
  ffi.Pointer<ffi.Char> hostName,
);

/// Attempts to parse the printable form of the IP address in the parameter
/// [hostName] and sets the host field in the address parameter if successful.
/// Returns 0 on success, < 0 on failure
@ffi.Native<ffi.Int Function(ffi.Pointer<ENetAddress>, ffi.Pointer<ffi.Char>)>(
  symbol: 'enet_address_set_host_ip_old', // TODO: isolate | new
  assetId: _assetId,
)
external int enet_address_set_host_ip(
  ffi.Pointer<ENetAddress> address,
  ffi.Pointer<ffi.Char> hostName,
);

/// Gives the printable form of the IP address specified in the address
/// parameter.
/// Returns 0 on success, < 0 on failure
@ffi.Native<
    ffi.Int Function(
      ffi.Pointer<ENetAddress>,
      ffi.Pointer<ffi.Char>,
      ffi.Size,
    )>(
  symbol: 'enet_address_get_host_ip_new',
  assetId: _assetId,
)
external int enet_address_get_host_ip_new(
  ffi.Pointer<ENetAddress> address,
  ffi.Pointer<ffi.Char> hostName,
  int nameLength,
);

// =======================================================================//
// !
// ! HOST Functions
// !
// =======================================================================//

/// Creates a host for communicating to peers.
/// Returns the host on success and null on failure
@ffi.Native<
    ffi.Pointer<ENetHost> Function(
      ffi.Pointer<ENetAddress>,
      ffi.Size,
      ffi.Size,
      ffi.Uint32,
      ffi.Uint32,
    )>(
  symbol: 'enet_host_create',
  assetId: _assetId,
)
external ffi.Pointer<ENetHost> enet_host_create(
  ffi.Pointer<ENetAddress> address,
  int peerCount,
  int channelLimit,
  int incomingBandwidth,
  int outgoingBandwidth,
);

/// Initiates a connection to a foreign host.
///
/// returns a peer representing the foreign host on success, NULL on failure
/// The peer returned will have not completed the connection
/// until [enet_host_service]
///
/// notifies of an `ENET_EVENT_TYPE_CONNECT` event for the peer.
@ffi.Native<
    ffi.Pointer<ENetPeer> Function(
      ffi.Pointer<ENetHost>,
      ffi.Pointer<ENetAddress>,
      ffi.Size,
      ffi.Uint32,
    )>(
  symbol: 'enet_host_connect',
  assetId: _assetId,
)
external ffi.Pointer<ENetPeer> enet_host_connect(
  ffi.Pointer<ENetHost> host,
  ffi.Pointer<ENetAddress> address,
  int channelCount,
  int data,
);

/// Waits for events on the host specified and shuttles packets between
/// the host and its peers.
///
/// returns > 0  if an event occurred within the specified time limit
/// returns 0 if no event occurred
/// returns < 0 on failure
/// [enet_host_service] should be called fairly regularly for adequate
/// performance ingoing host.
///
/// Returns > 0 if an event occured within the specified time limit
/// 0 if no event occured, < 0 on failure
@ffi.Native<
    ffi.Int Function(
      ffi.Pointer<ENetHost>,
      ffi.Pointer<ENetEvent>,
      ffi.Uint32,
    )>(
  symbol: 'enet_host_service',
  assetId: _assetId,
)
external int enet_host_service(
  ffi.Pointer<ENetHost> host,
  ffi.Pointer<ENetEvent> event,
  int timeout,
);

/// Destroys the host and all resources associated with it.
/// [host] pointer to the host to destroy
@ffi.Native<ffi.Void Function(ffi.Pointer<ENetHost>)>(
  symbol: 'enet_host_destroy',
  assetId: _assetId,
)
external void enet_host_destroy(
  ffi.Pointer<ENetHost> host,
);

/// Adjusts the bandwidth limits of a host.
/// the incoming and outgoing bandwidth parameters are identical in function
/// to thos specified in [enet_host_create].
@ffi.Native<ffi.Void Function(ffi.Pointer<ENetHost>, ffi.Uint32, ffi.Uint32)>(
  symbol: 'enet_host_bandwidth_limit',
  assetId: _assetId,
)
external void enet_host_bandwidth_limit(
  ffi.Pointer<ENetHost> host,
  int incommingBandwidth,
  int outgoingBandwidth,
);

/// Sends any queued packets on the host specified to its designated peers.
/// this function need only be used in circumstances where one wishes to send
/// queued packets earlier than in a call to [enet_host_service] ingroup host
@ffi.Native<ffi.Void Function(ffi.Pointer<ENetHost>)>(
  symbol: 'enet_host_flush',
  assetId: _assetId,
)
external void enet_host_flush(
  ffi.Pointer<ENetHost> host,
);

// =======================================================================//
// !
// ! PACKET Functions
// !
// =======================================================================//

/// Creates a packet that may be sent to a peer.
/// returns the packet on success, null on failure.
@ffi.Native<
    ffi.Pointer<ENetPacket> Function(
      ffi.Pointer<ffi.Void>,
      ffi.Size,
      ffi.Uint32,
    )>(
  symbol: 'enet_packet_create',
  assetId: _assetId,
)
external ffi.Pointer<ENetPacket> enet_packet_create(
  ffi.Pointer<ffi.Void> data,
  int dataLength,
  int flags,
);

/// Destroys the packet and deallocates its data.
/// [packet] packet to be destroyed
@ffi.Native<ffi.Void Function(ffi.Pointer<ENetPacket>)>(
  symbol: 'enet_packet_destroy',
  assetId: _assetId,
)
external void enet_packet_destroy(
  ffi.Pointer<ENetPacket> packet,
);

/// Attempts to resize the data in the packet to length specified in the
/// returns new packet pointer on success, null on failure.
@ffi.Native<
    ffi.Pointer<ENetPacket> Function(
      ffi.Pointer<ENetPacket>,
      ffi.Size,
    )>(
  symbol: 'enet_packet_resize',
  assetId: _assetId,
)
external ffi.Pointer<ENetPacket> enet_packet_resize(
  ffi.Pointer<ENetPacket> packet,
  int dataLength,
);

// =======================================================================//
// !
// ! PEER Functions
// !
// =======================================================================//

/// Queues a packet to be sent.
/// returns 0 on sucess, < 0 on failure.
@ffi.Native<
    ffi.Int Function(
      ffi.Pointer<ENetPeer>,
      ffi.Uint8,
      ffi.Pointer<ENetPacket>,
    )>(
  symbol: 'enet_peer_send',
  assetId: _assetId,
)
external int enet_peer_send(
  ffi.Pointer<ENetPeer> peer,
  int channelID,
  ffi.Pointer<ENetPacket> packet,
);

/// Request a disconnection from a peer.
/// An `ENET_EVENT_DISCONNECT` event will be generated by [enet_host_service]
/// once the disconnection is complete.
@ffi.Native<ffi.Void Function(ffi.Pointer<ENetPeer>, ffi.Uint32)>(
  symbol: 'enet_peer_disconnect',
  assetId: _assetId,
)
external void enet_peer_disconnect(
  ffi.Pointer<ENetPeer> peer,
  int data,
);

/// Request a disconnection from a peer, but only after all queued outgoing
/// packets are sent.
/// An `ENET_EVENT_DISCONNECT` event will be generated by [enet_host_service]
/// once the disconnection is complete.
@ffi.Native<ffi.Void Function(ffi.Pointer<ENetPeer>, ffi.Uint32)>(
  symbol: 'enet_peer_disconnect_later',
  assetId: _assetId,
)
external void enet_peer_disconnect_later(
  ffi.Pointer<ENetPeer> peer,
  int data,
);

/// Force an immediate disconnection from a peer.
/// No `ENET_EVENT_DISCONNECT` event will be generated. The foreign peer is not
/// guaranteed to receive the disconnect notification, and is reset immediately
/// upon return from this function.
@ffi.Native<ffi.Void Function(ffi.Pointer<ENetPeer>, ffi.Uint32)>(
  symbol: 'enet_peer_disconnect_now',
  assetId: _assetId,
)
external void enet_peer_disconnect_now(
  ffi.Pointer<ENetPeer> peer,
  int data,
);

/// Sends a ping request to a peer.
/// ping requests factor into the mean round trip time as designated by the
/// roundTripTime field in the ENetPeer structure.  ENet automatically pings all
/// connected peers at regular intervals, however, this function may be called
/// to ensure more frequent ping requests.
@ffi.Native<ffi.Void Function(ffi.Pointer<ENetPeer>)>(
  symbol: 'enet_peer_ping',
  assetId: _assetId,
)
external void enet_peer_ping(ffi.Pointer<ENetPeer> peer);

/// Sets the interval at which pings will be sent to a peer.
///
/// Pings are used both to monitor the liveness of the connection and also to
/// dynamically adjust the throttle during periods of low traffic so that the
/// throttle has reasonable responsiveness during traffic spikes.
/// defaults to `ENET_PEER_PING_INTERVAL` if 0
@ffi.Native<ffi.Void Function(ffi.Pointer<ENetPeer>, ffi.Uint32)>(
  symbol: 'enet_peer_ping_interval',
  assetId: _assetId,
)
external void enet_peer_ping_interval(
  ffi.Pointer<ENetPeer> peer,
  int pingInterval,
);

/// Attempts to dequeue any incoming queued packet.
/// returns a pointer to the packet, or NULL if there are no available
/// incoming queued packets
@ffi.Native<ffi.Pointer<ENetPacket> Function(ffi.Pointer<ENetPeer>, ffi.Uint8)>(
  symbol: 'enet_peer_receive',
  assetId: _assetId,
)
external ffi.Pointer<ENetPacket> enet_peer_receive(
  ffi.Pointer<ENetPeer> peer,
  int channelID,
);

/// Forcefully disconnects a peer.
/// The foreign host represented by the peer is not notified of the
/// disconnection and will timeout on its connection to the local host.
@ffi.Native<ffi.Void Function(ffi.Pointer<ENetPeer>)>(
  symbol: 'enet_peer_reset',
  assetId: _assetId,
)
external void enet_peer_reset(
  ffi.Pointer<ENetPeer> peer,
);

/// Configures throttle parameter for a peer.
@ffi.Native<
    ffi.Void Function(
      ffi.Pointer<ENetPeer>,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
    )>()
external void enet_peer_throttle_configure(
  ffi.Pointer<ENetPeer> peer,
  int interval,
  int acceleration,
  int deceleration,
);

/// Sets the timeout parameters for a peer.
@ffi.Native<
    ffi.Void Function(
      ffi.Pointer<ENetPeer>,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
    )>()
external void enet_peer_timeout(
  ffi.Pointer<ENetPeer> peer,
  int timeoutLimit,
  int timeoutMaximum,
  int timeoutMinimum,
);

// =======================================================================//
// !
// ! typedefs
// !
// =======================================================================//

/// Callback that computes the checksum of the data held
/// in buffers[0:bufferCount-1]
typedef ENetChecksumCallback
    = ffi.Pointer<ffi.NativeFunction<ENetChecksumCallbackFunction>>;
typedef ENetChecksumCallbackFunction = ffi.Uint32 Function(
  ffi.Pointer<ENetBuffer> buffers,
  ffi.Size bufferCount,
);

typedef ENetInterceptCallback
    = ffi.Pointer<ffi.NativeFunction<ENetInterceptCallbackFunction>>;
typedef ENetInterceptCallbackFunction = ffi.Int Function(
  ffi.Pointer<ENetHost> host,
  ffi.Pointer<ffi.Void> event,
);

typedef ENetPacketFreeCallback
    = ffi.Pointer<ffi.NativeFunction<ENetPacketFreeCallbackFunction>>;
typedef ENetPacketFreeCallbackFunction = ffi.Void Function(
  ffi.Pointer<ffi.Void>,
);

// =======================================================================//
// !
// ! external
// !
// =======================================================================//
final class ENetAddress extends ffi.Struct {
  external in6_addr host;

  @ffi.Uint16()
  external int port;

  @ffi.Uint16()
  external int sin6_scope_id;
}

final class in6_addr extends ffi.Struct {
  external UnnamedUnion1 u;
}

final class UnnamedUnion1 extends ffi.Union {
  @ffi.Array.multi([16])
  external ffi.Array<ffi.UnsignedChar> Byte;

  @ffi.Array.multi([8])
  external ffi.Array<ffi.UnsignedChar> Word;
}

/// An ENet host for communicating with peers.
///
/// No fields should be modified unless otherwise stated.
///
/// @sa enet_host_create()
/// @sa enet_host_destroy()
/// @sa enet_host_connect()
/// @sa enet_host_service()
/// @sa enet_host_flush()
/// @sa enet_host_broadcast()
/// @sa enet_host_compress()
/// @sa enet_host_channel_limit()
/// @sa enet_host_bandwidth_limit()
/// @sa enet_host_bandwidth_throttle()
final class ENetHost extends ffi.Struct {
  @ffi.UnsignedLongLong()
  external int socket;

  /// < Internet address of the host
  external ENetAddress address;

  /// < downstream bandwidth of the host
  @ffi.Uint32()
  external int incomingBandwidth;

  /// < upstream bandwidth of the host
  @ffi.Uint32()
  external int outgoingBandwidth;

  @ffi.Uint32()
  external int bandwidthThrottleEpoch;

  @ffi.Uint32()
  external int mtu;

  @ffi.Uint32()
  external int randomSeed;

  @ffi.Int()
  external int recalculateBandwidthLimits;

  /// < array of peers allocated for this host
  external ffi.Pointer<ENetPeer> peers;

  /// < number of peers allocated for this host
  @ffi.Size()
  external int peerCount;

  /// < maximum number of channels allowed for connected peers
  @ffi.Size()
  external int channelLimit;

  @ffi.Uint32()
  external int serviceTime;

  external ENetList dispatchQueue;

  @ffi.Int()
  external int continueSending;

  @ffi.Size()
  external int packetSize;

  @ffi.Uint16()
  external int headerFlags;

  @ffi.Array.multi([32])
  external ffi.Array<ENetProtocol> commands;

  @ffi.Size()
  external int commandCount;

  @ffi.Array.multi([65])
  external ffi.Array<ENetBuffer> buffers;

  @ffi.Size()
  external int bufferCount;

  /// < callback the user can set to enable packet checksums for this host
  external ENetChecksumCallback checksum;

  external ENetCompressor compressor;

  @ffi.Array.multi([2, 4096])
  external ffi.Array<ffi.Array<ffi.Uint8>> packetData;

  external ENetAddress receivedAddress;

  external ffi.Pointer<ffi.Uint8> receivedData;

  @ffi.Size()
  external int receivedDataLength;

  /// < total data sent, user should reset to 0 as needed to prevent overflow
  @ffi.Uint32()
  external int totalSentData;

  /// < total UDP packets sent, user should reset to 0 as needed
  /// to prevent overflow
  @ffi.Uint32()
  external int totalSentPackets;

  /// < total data received, user should reset to 0 as needed
  /// to prevent overflow
  @ffi.Uint32()
  external int totalReceivedData;

  /// < total UDP packets received, user should reset to 0 as needed
  /// to prevent overflow
  @ffi.Uint32()
  external int totalReceivedPackets;

  /// < callback the user can set to intercept received raw UDP packets
  external ENetInterceptCallback intercept;

  @ffi.Size()
  external int connectedPeers;

  @ffi.Size()
  external int bandwidthLimitedPeers;

  /// < optional number of allowed peers from duplicate IPs
  /// defaults to `ENET_PROTOCOL_MAXIMUM_PEER_ID`
  @ffi.Size()
  external int duplicatePeers;

  /// < the maximum allowable packet size that may be sent or received on a peer
  @ffi.Size()
  external int maximumPacketSize;

  /// < the maximum aggregate amount of buffer space a peer may use waiting
  /// for packets to be delivered
  @ffi.Size()
  external int maximumWaitingData;
}

final class ENetPeer extends ffi.Struct {
  external ENetListNode dispatchList;

  external ffi.Pointer<ENetHost> host;

  @ffi.Uint16()
  external int outgoingPeerID;

  @ffi.Uint16()
  external int incomingPeerID;

  @ffi.Uint32()
  external int connectID;

  @ffi.Uint8()
  external int outgoingSessionID;

  @ffi.Uint8()
  external int incomingSessionID;

  /// < Internet address of the peer
  external ENetAddress address;

  /// < Application private data, may be freely modified
  external ffi.Pointer<ffi.Void> data;

  @ffi.Int32()
  external int state;

  external ffi.Pointer<ENetChannel> channels;

  /// < Number of channels allocated for communication with peer
  @ffi.Size()
  external int channelCount;

  /// < Downstream bandwidth of the client in bytes/second
  @ffi.Uint32()
  external int incomingBandwidth;

  /// < Upstream bandwidth of the client in bytes/second
  @ffi.Uint32()
  external int outgoingBandwidth;

  @ffi.Uint32()
  external int incomingBandwidthThrottleEpoch;

  @ffi.Uint32()
  external int outgoingBandwidthThrottleEpoch;

  @ffi.Uint32()
  external int incomingDataTotal;

  @ffi.Uint64()
  external int totalDataReceived;

  @ffi.Uint32()
  external int outgoingDataTotal;

  @ffi.Uint64()
  external int totalDataSent;

  @ffi.Uint32()
  external int lastSendTime;

  @ffi.Uint32()
  external int lastReceiveTime;

  @ffi.Uint32()
  external int nextTimeout;

  @ffi.Uint32()
  external int earliestTimeout;

  @ffi.Uint32()
  external int packetLossEpoch;

  @ffi.Uint32()
  external int packetsSent;

  /// < total number of packets sent during a session
  @ffi.Uint64()
  external int totalPacketsSent;

  @ffi.Uint32()
  external int packetsLost;

  /// < total number of packets lost during a session
  @ffi.Uint32()
  external int totalPacketsLost;

  /// < mean packet loss of reliable packets as a ratio with respect to the
  /// constant `ENET_PEER_PACKET_LOSS_SCALE`
  @ffi.Uint32()
  external int packetLoss;

  @ffi.Uint32()
  external int packetLossVariance;

  @ffi.Uint32()
  external int packetThrottle;

  @ffi.Uint32()
  external int packetThrottleLimit;

  @ffi.Uint32()
  external int packetThrottleCounter;

  @ffi.Uint32()
  external int packetThrottleEpoch;

  @ffi.Uint32()
  external int packetThrottleAcceleration;

  @ffi.Uint32()
  external int packetThrottleDeceleration;

  @ffi.Uint32()
  external int packetThrottleInterval;

  @ffi.Uint32()
  external int pingInterval;

  @ffi.Uint32()
  external int timeoutLimit;

  @ffi.Uint32()
  external int timeoutMinimum;

  @ffi.Uint32()
  external int timeoutMaximum;

  @ffi.Uint32()
  external int lastRoundTripTime;

  @ffi.Uint32()
  external int lowestRoundTripTime;

  @ffi.Uint32()
  external int lastRoundTripTimeVariance;

  @ffi.Uint32()
  external int highestRoundTripTimeVariance;

  /// < mean round trip time (RTT), in milliseconds, between sending a reliable
  /// packet and receiving its acknowledgement
  @ffi.Uint32()
  external int roundTripTime;

  @ffi.Uint32()
  external int roundTripTimeVariance;

  @ffi.Uint32()
  external int mtu;

  @ffi.Uint32()
  external int windowSize;

  @ffi.Uint32()
  external int reliableDataInTransit;

  @ffi.Uint16()
  external int outgoingReliableSequenceNumber;

  external ENetList acknowledgements;

  external ENetList sentReliableCommands;

  external ENetList sentUnreliableCommands;

  external ENetList outgoingReliableCommands;

  external ENetList outgoingUnreliableCommands;

  external ENetList dispatchedCommands;

  @ffi.Int()
  external int needsDispatch;

  @ffi.Uint16()
  external int incomingUnsequencedGroup;

  @ffi.Uint16()
  external int outgoingUnsequencedGroup;

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Uint32> unsequencedWindow;

  @ffi.Uint32()
  external int eventData;

  @ffi.Size()
  external int totalWaitingData;
}

final class ENetList extends ffi.Struct {
  external ENetListNode sentinel;
}

final class ENetListNode extends ffi.Struct {
  external ffi.Pointer<ENetListNode> next;

  external ffi.Pointer<ENetListNode> previous;
}

final class ENetChannel extends ffi.Struct {
  @ffi.Uint16()
  external int outgoingReliableSequenceNumber;

  @ffi.Uint16()
  external int outgoingUnreliableSequenceNumber;

  @ffi.Uint16()
  external int usedReliableWindows;

  @ffi.Array.multi([16])
  external ffi.Array<ffi.Uint16> reliableWindows;

  @ffi.Uint16()
  external int incomingReliableSequenceNumber;

  @ffi.Uint16()
  external int incomingUnreliableSequenceNumber;

  external ENetList incomingReliableCommands;

  external ENetList incomingUnreliableCommands;
}

final class ENetProtocol extends ffi.Union {
  external ENetProtocolCommandHeader header;

  external ENetProtocolAcknowledge acknowledge;

  external ENetProtocolConnect connect;

  external ENetProtocolVerifyConnect verifyConnect;

  external ENetProtocolDisconnect disconnect;

  external ENetProtocolPing ping;

  external ENetProtocolSendReliable sendReliable;

  external ENetProtocolSendUnreliable sendUnreliable;

  external ENetProtocolSendUnsequenced sendUnsequenced;

  external ENetProtocolSendFragment sendFragment;

  external ENetProtocolBandwidthLimit bandwidthLimit;

  external ENetProtocolThrottleConfigure throttleConfigure;
}

final class ENetBuffer extends ffi.Struct {
  @ffi.Size()
  external int dataLength;

  external ffi.Pointer<ffi.Void> data;
}

/// An ENet packet compressor for compressing UDP packets before
/// socket sends or receives.
final class ENetCompressor extends ffi.Struct {
  /// Context data for the compressor. Must be non-NULL.
  external ffi.Pointer<ffi.Void> context;

  /// Compresses from inBuffers[0:inBufferCount-1], containing inLimit bytes,
  /// to outData, outputting at most outLimit bytes. Should return 0 on failure.
  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Size Function(
            ffi.Pointer<ffi.Void> context,
            ffi.Pointer<ENetBuffer> inBuffers,
            ffi.Size inBufferCount,
            ffi.Size inLimit,
            ffi.Pointer<ffi.Uint8> outData,
            ffi.Size outLimit,
          )>> compress;

  /// Decompresses from inData, containing inLimit bytes, to outData,
  /// outputting at most outLimit bytes. Should return 0 on failure.
  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Size Function(
            ffi.Pointer<ffi.Void> context,
            ffi.Pointer<ffi.Uint8> inData,
            ffi.Size inLimit,
            ffi.Pointer<ffi.Uint8> outData,
            ffi.Size outLimit,
          )>> decompress;

  /// Destroys the context when compression is disabled or the host is destroyed
  /// May be NULL.
  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Void Function(
            ffi.Pointer<ffi.Void> context,
          )>> destroy;
}

// ENet Protocol

@ffi.Packed(1)
final class ENetProtocolCommandHeader extends ffi.Struct {
  @ffi.Uint8()
  external int command;

  @ffi.Uint8()
  external int channelID;

  @ffi.Uint16()
  external int reliableSequenceNumber;
}

@ffi.Packed(1)
final class ENetProtocolAcknowledge extends ffi.Struct {
  external ENetProtocolCommandHeader header;

  @ffi.Uint16()
  external int receivedReliableSequenceNumber;

  @ffi.Uint16()
  external int receivedSentTime;
}

@ffi.Packed(1)
final class ENetProtocolConnect extends ffi.Struct {
  external ENetProtocolCommandHeader header;

  @ffi.Uint16()
  external int outgoingPeerID;

  @ffi.Uint8()
  external int incomingSessionID;

  @ffi.Uint8()
  external int outgoingSessionID;

  @ffi.Uint32()
  external int mtu;

  @ffi.Uint32()
  external int windowSize;

  @ffi.Uint32()
  external int channelCount;

  @ffi.Uint32()
  external int incomingBandwidth;

  @ffi.Uint32()
  external int outgoingBandwidth;

  @ffi.Uint32()
  external int packetThrottleInterval;

  @ffi.Uint32()
  external int packetThrottleAcceleration;

  @ffi.Uint32()
  external int packetThrottleDeceleration;

  @ffi.Uint32()
  external int connectID;

  @ffi.Uint32()
  external int data;
}

@ffi.Packed(1)
final class ENetProtocolVerifyConnect extends ffi.Struct {
  external ENetProtocolCommandHeader header;

  @ffi.Uint16()
  external int outgoingPeerID;

  @ffi.Uint8()
  external int incomingSessionID;

  @ffi.Uint8()
  external int outgoingSessionID;

  @ffi.Uint32()
  external int mtu;

  @ffi.Uint32()
  external int windowSize;

  @ffi.Uint32()
  external int channelCount;

  @ffi.Uint32()
  external int incomingBandwidth;

  @ffi.Uint32()
  external int outgoingBandwidth;

  @ffi.Uint32()
  external int packetThrottleInterval;

  @ffi.Uint32()
  external int packetThrottleAcceleration;

  @ffi.Uint32()
  external int packetThrottleDeceleration;

  @ffi.Uint32()
  external int connectID;
}

@ffi.Packed(1)
final class ENetProtocolDisconnect extends ffi.Struct {
  external ENetProtocolCommandHeader header;

  @ffi.Uint32()
  external int data;
}

final class ENetProtocolPing extends ffi.Struct {
  external ENetProtocolCommandHeader header;
}

@ffi.Packed(1)
final class ENetProtocolSendReliable extends ffi.Struct {
  external ENetProtocolCommandHeader header;

  @ffi.Uint16()
  external int dataLength;
}

@ffi.Packed(1)
final class ENetProtocolSendUnreliable extends ffi.Struct {
  external ENetProtocolCommandHeader header;

  @ffi.Uint16()
  external int unreliableSequenceNumber;

  @ffi.Uint16()
  external int dataLength;
}

@ffi.Packed(1)
final class ENetProtocolSendUnsequenced extends ffi.Struct {
  external ENetProtocolCommandHeader header;

  @ffi.Uint16()
  external int unsequencedGroup;

  @ffi.Uint16()
  external int dataLength;
}

@ffi.Packed(1)
final class ENetProtocolSendFragment extends ffi.Struct {
  external ENetProtocolCommandHeader header;

  @ffi.Uint16()
  external int startSequenceNumber;

  @ffi.Uint16()
  external int dataLength;

  @ffi.Uint32()
  external int fragmentCount;

  @ffi.Uint32()
  external int fragmentNumber;

  @ffi.Uint32()
  external int totalLength;

  @ffi.Uint32()
  external int fragmentOffset;
}

@ffi.Packed(1)
final class ENetProtocolBandwidthLimit extends ffi.Struct {
  external ENetProtocolCommandHeader header;

  @ffi.Uint32()
  external int incomingBandwidth;

  @ffi.Uint32()
  external int outgoingBandwidth;
}

@ffi.Packed(1)
final class ENetProtocolThrottleConfigure extends ffi.Struct {
  external ENetProtocolCommandHeader header;

  @ffi.Uint32()
  external int packetThrottleInterval;

  @ffi.Uint32()
  external int packetThrottleAcceleration;

  @ffi.Uint32()
  external int packetThrottleDeceleration;
}

// End enet protocol

/// An ENet event as returned by [enet_host_service].
final class ENetEvent extends ffi.Struct {
  /// < type of the event
  @ffi.Int32()
  external int type;

  /// < peer that generated a connect, disconnect or receive event
  external ffi.Pointer<ENetPeer> peer;

  /// < channel on the peer that generated the event, if appropriate
  @ffi.Uint8()
  external int channelID;

  /// < data associated with the event, if appropriate
  @ffi.Uint32()
  external int data;

  /// < packet associated with the event, if appropriate
  external ffi.Pointer<ENetPacket> packet;
}

/// ENet packet structure.
final class ENetPacket extends ffi.Struct {
  /// < internal use only
  @ffi.Size()
  external int referenceCount;

  /// < bitwise-or of ENetPacketFlag constants
  @ffi.Uint32()
  external int flags;

  /// < allocated data for packet
  external ffi.Pointer<ffi.Uint8> data;

  /// < length of data
  @ffi.Size()
  external int dataLength;

  /// < function to be called when the packet is no longer in use
  external ENetPacketFreeCallback freeCallback;

  /// < application private data, may be freely modified
  external ffi.Pointer<ffi.Void> userData;
}
