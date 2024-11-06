// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:ffi' as ffi;

class EnetBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  EnetBindings(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  EnetBindings.fromLookup(ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup)
      : _lookup = lookup;

  // =======================================================================//
  // !
  // ! Public API
  // !
  // =======================================================================//

  /// Initializes ENet globally.
  /// Must be called prior to using any functions in ENet.
  ///
  /// returns 0 on success < 0 on failure
  int enet_initialize() {
    return _enet_initialize();
  }

  /// Shuts down ENet globally.
  /// Should be called when a program that has initialized ENet exits.
  void enet_deinitialize() {
    return _enet_deinitialize();
  }

  /// Gives the linked version of the ENet library.
  /// returns the version number
  int enet_linked_version() {
    return _enet_linked_version();
  }

  /// Returns the monotonic time in milliseconds.
  /// Its initial value is unspecified unless otherwise set.
  int enet_time_get() {
    return _enet_time_get();
  }

  /* ENET socket functions below */
  /* ENET socket version end */

  /// Attempts to parse the printable form of the IP address in the parameter hostName
  /// and sets the host field in the address parameter if successful.
  /// @param address destination to store the parsed IP address
  /// @param hostName IP address to parse
  /// @retval 0 on success
  /// @retval < 0 on failure
  /// @returns the address of the given hostName in address on success
  int enet_address_set_host_ip(
    ffi.Pointer<ENetAddress> address,
    ffi.Pointer<ffi.Char> hostName,
  ) {
    return _enet_address_set_host_ip_old(
      address,
      hostName,
    );
  }

  /// Gives the printable form of the IP address specified in the address parameter.
  /// @param address    address printed
  /// @param hostName   destination for name, must not be NULL
  /// @param nameLength maximum length of hostName.
  /// @returns the null-terminated name of the host in hostName on success
  /// @retval 0 on success
  /// @retval < 0 on failure
  int enet_address_get_host_ip(
    ffi.Pointer<ENetAddress> address,
    ffi.Pointer<ffi.Char> hostName,
    int nameLength,
  ) {
    return _enet_address_get_host_ip_old(
      address,
      hostName,
      nameLength,
    );
  }

  /// Attempts to do a reverse lookup of the host field in the address parameter.
  /// @param address    address used for reverse lookup
  /// @param hostName   destination for name, must not be NULL
  /// @param nameLength maximum length of hostName.
  /// @returns the null-terminated name of the host in hostName on success
  /// @retval 0 on success
  /// @retval < 0 on failure
  int enet_address_get_host(
    ffi.Pointer<ENetAddress> address,
    ffi.Pointer<ffi.Char> hostName,
    int nameLength,
  ) {
    return _enet_address_get_host_old(
      address,
      hostName,
      nameLength,
    );
  }

  /// Attempts to resolve the host named by the parameter hostName and sets
  /// the host field in the address parameter if successful.
  /// @param address destination to store resolved address
  /// @param hostName host name to lookup
  /// @retval 0 on success
  /// @retval < 0 on failure
  /// @returns the address of the given hostName in address on success
  int enet_address_set_host(
    ffi.Pointer<ENetAddress> address,
    ffi.Pointer<ffi.Char> hostName,
  ) {
    return _enet_address_set_host_old(
      address,
      hostName,
    );
  }

  /* ENET HOST FUNCTIONS */

  /// Creates a host for communicating to peers.
  ///
  /// `address` the address at which other peers may connect to this host. If NULL, then no peers may connect to the host.
  /// `peerCount` the maximum number of peers that should be allocated for the host.
  /// `channelLimit` the maximum number of channels allowed; if 0, then this is equivalent to ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT
  /// `incomingBandwidth` downstream bandwidth of the host in bytes/second; if 0, ENet will assume unlimited bandwidth.
  /// `outgoingBandwidth` upstream bandwidth of the host in bytes/second; if 0, ENet will assume unlimited bandwidth.
  ///
  /// returns the host on success and null on failure
  ///
  /// remarks ENet will strategically drop packets on specific sides of a connection between hosts
  /// to ensure the host's bandwidth is not overwhelmed.  The bandwidth parameters also determine
  /// the window size of a connection which limits the amount of reliable packets that may be in transit
  /// at any given time.
  ffi.Pointer<ENetHost> enet_host_create(
    ffi.Pointer<ENetAddress> address,
    int peerCount,
    int channelLimit,
    int incomingBandwidth,
    int outgoingBandwidth,
  ) {
    return _enet_host_create(
      address,
      peerCount,
      channelLimit,
      incomingBandwidth,
      outgoingBandwidth,
    );
  }

  /// Initiates a connection to a foreign host.
  ///
  /// `host` host seeking the connection
  /// `address` destination for the connection
  /// `channelCount` number of channels to allocate
  /// `data` user data supplied to the receiving host
  ///
  /// returns a peer representing the foreign host on success, NULL on failure
  /// remarks The peer returned will have not completed the connection until enet_host_service()
  /// notifies of an ENET_EVENT_TYPE_CONNECT event for the peer.
  ffi.Pointer<ENetPeer> enet_host_connect(
    ffi.Pointer<ENetHost> host,
    ffi.Pointer<ENetAddress> address,
    int channelCount,
    int data,
  ) {
    return _enet_host_connect(
      host,
      address,
      channelCount,
      data,
    );
  }

  /// Waits for events on the host specified and shuttles packets between
  /// the host and its peers.
  ///
  /// `host` host to service
  /// `event` an event structure where event details will be placed if one occurs
  ///         if event == NULL then no events will be delivered
  /// `timeout` number of milliseconds that ENet should wait for events
  ///
  /// returns > 0  if an event occurred within the specified time limit
  /// returns 0 if no event occurred
  /// returns < 0 on failure
  /// remarks enet_host_service should be called fairly regularly for adequate performance
  /// ingoing host
  int enet_host_service(
    ffi.Pointer<ENetHost> host,
    ffi.Pointer<ENetEvent> event,
    int timeout,
  ) {
    return _enet_host_service(
      host,
      event,
      timeout,
    );
  }

  /// Sends any queued packets on the host specified to its designated peers.
  ///
  /// `host` host to flush
  /// remarks this function need only be used in circumstances where one wishes to send queued packets earlier than in a call to enet_host_service()
  /// ingroup host
  void enet_host_flush(
    ffi.Pointer<ENetHost> host,
  ) {
    return _enet_host_flush(
      host,
    );
  }

  /// Destroys the host and all resources associated with it.
  /// `host` pointer to the host to destroy
  void enet_host_destroy(
    ffi.Pointer<ENetHost> host,
  ) {
    return _enet_host_destroy(
      host,
    );
  }

  /// Adjusts the bandwidth limits of a host.
  /// `host` host to adjust
  /// `incommingBandwidth` new incoming bandwidth
  /// `outgoingBandwidth` new outgoing bandwidth
  ///
  /// the incoming and outgoing bandwidth parameters are identical in function
  /// to thos specified in enet_host_create().
  void enet_host_bandwidth_limit(
    ffi.Pointer<ENetHost> host,
    int incommingBandwidth,
    int outgoingBandwidth,
  ) {
    return _enet_host_bandwidth_limit(
      host,
      incommingBandwidth,
      outgoingBandwidth,
    );
  }

  void enet_host_bandwidth_throttle(
    ffi.Pointer<ENetHost> host,
  ) {
    return _enet_host_bandwidth_throttle(
      host,
    );
  }

  ///  Limits the maximum allowed channels of future incoming connections.
  /// `host` host to limit
  /// `channelLimit` the maximum number of channl
  void enet_host_channel_limit(
    ffi.Pointer<ENetHost> host,
    int channelLimit,
  ) {
    return _enet_host_channel_limit(
      host,
      channelLimit,
    );
  }

  /// Queues a packet to be sent to all peers associated with the host.
  ///
  /// `host` host on which to broadcast the packet
  /// `channelID` channel on which to broadcast
  /// `packet` packet to broadcast
  void enet_host_broadcast(
    ffi.Pointer<ENetHost> host,
    int channelID,
    ffi.Pointer<ENetPacket> packet,
  ) {
    return _enet_host_broadcast(
      host,
      channelID,
      packet,
    );
  }

  /* ENET PACKET FUNCTIONS */

  /// Creates a packet that may be sent to a peer.
  ///
  /// `data` initial contents of the packet's data; the packet's data will remain uninitialized if data is NULL.
  /// `dataLength` size of the data allocated for this packet
  /// `flags` flags for this packet as described for the ENetPacket structure.
  ///
  /// returns the packet on success, null on failure.
  ffi.Pointer<ENetPacket> enet_packet_create(
    ffi.Pointer<ffi.Void> data,
    int dataLength,
    int flags,
  ) {
    return _enet_packet_create(
      data,
      dataLength,
      flags,
    );
  }

  /// Queues a packet to be sent.
  ///
  /// `peer` destination for the packet
  /// `channelID` channel on which to send
  /// `packet` packet to send
  ///
  /// returns 0 on sucess
  /// returns < 0 on failure
  int enet_peer_send(
    ffi.Pointer<ENetPeer> peer,
    int channelID,
    ffi.Pointer<ENetPacket> packet,
  ) {
    return _enet_peer_send(
      peer,
      channelID,
      packet,
    );
  }

  /// Destroys the packet and deallocates its data.
  /// `packet` packet to be destroyed
  void enet_packet_destroy(
    ffi.Pointer<ENetPacket> packet,
  ) {
    return _enet_packet_destroy(
      packet,
    );
  }

  /// Attempts to resize the data in the packet to length specified in the
  /// `dataLength` parameter
  ///
  /// `packet` packet to resize
  /// `dataLength` new size for the packet data
  ///
  /// returns new packet pointer on success, null on failure.
  ffi.Pointer<ENetPacket> enet_packet_resize(
    ffi.Pointer<ENetPacket> packet,
    int dataLength,
  ) {
    return _enet_packet_resize(
      packet,
      dataLength,
    );
  }

  // =======================================================================//
  // !
  // ! Bindings API
  // !
  // =======================================================================//

  late final _enet_initializePtr = _lookup<ffi.NativeFunction<ffi.Int Function()>>('enet_initialize');
  late final _enet_initialize = _enet_initializePtr.asFunction<int Function()>();

  late final _enet_deinitializePtr = _lookup<ffi.NativeFunction<ffi.Void Function()>>('enet_deinitialize');
  late final _enet_deinitialize = _enet_deinitializePtr.asFunction<void Function()>();

  late final _enet_linked_versionPtr = _lookup<ffi.NativeFunction<ffi.Uint32 Function()>>('enet_linked_version');
  late final _enet_linked_version = _enet_linked_versionPtr.asFunction<int Function()>();

  late final _enet_time_getPtr = _lookup<ffi.NativeFunction<ffi.Uint32 Function()>>('enet_time_get');
  late final _enet_time_get = _enet_time_getPtr.asFunction<int Function()>();

  late final _enet_address_get_host_oldPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ENetAddress>, ffi.Pointer<ffi.Char>, ffi.Size)>>(
          'enet_address_get_host_old');
  late final _enet_address_get_host_old =
      _enet_address_get_host_oldPtr.asFunction<int Function(ffi.Pointer<ENetAddress>, ffi.Pointer<ffi.Char>, int)>();

  late final _enet_address_set_host_oldPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ENetAddress>, ffi.Pointer<ffi.Char>)>>(
          'enet_address_set_host_old');
  late final _enet_address_set_host_old =
      _enet_address_set_host_oldPtr.asFunction<int Function(ffi.Pointer<ENetAddress>, ffi.Pointer<ffi.Char>)>();

  /* ENET socket functions below */
  /* ENET socket version end */

  late final _enet_address_set_host_ip_oldPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ENetAddress>, ffi.Pointer<ffi.Char>)>>(
          'enet_address_set_host_ip_old');
  late final _enet_address_set_host_ip_old =
      _enet_address_set_host_ip_oldPtr.asFunction<int Function(ffi.Pointer<ENetAddress>, ffi.Pointer<ffi.Char>)>();

  late final _enet_address_get_host_ip_oldPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ENetAddress>, ffi.Pointer<ffi.Char>, ffi.Size)>>(
          'enet_address_get_host_ip_old');
  late final _enet_address_get_host_ip_old =
      _enet_address_get_host_ip_oldPtr.asFunction<int Function(ffi.Pointer<ENetAddress>, ffi.Pointer<ffi.Char>, int)>();

  late final _enet_host_createPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ENetHost> Function(
              ffi.Pointer<ENetAddress>, ffi.Size, ffi.Size, ffi.Uint32, ffi.Uint32)>>('enet_host_create');
  late final _enet_host_create =
      _enet_host_createPtr.asFunction<ffi.Pointer<ENetHost> Function(ffi.Pointer<ENetAddress>, int, int, int, int)>();

  late final _enet_host_connectPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ENetPeer> Function(
              ffi.Pointer<ENetHost>, ffi.Pointer<ENetAddress>, ffi.Size, ffi.Uint32)>>('enet_host_connect');
  late final _enet_host_connect = _enet_host_connectPtr
      .asFunction<ffi.Pointer<ENetPeer> Function(ffi.Pointer<ENetHost>, ffi.Pointer<ENetAddress>, int, int)>();

  late final _enet_host_servicePtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ENetHost>, ffi.Pointer<ENetEvent>, ffi.Uint32)>>(
          'enet_host_service');
  late final _enet_host_service =
      _enet_host_servicePtr.asFunction<int Function(ffi.Pointer<ENetHost>, ffi.Pointer<ENetEvent>, int)>();

  late final _enet_packet_createPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ENetPacket> Function(ffi.Pointer<ffi.Void>, ffi.Size, ffi.Uint32)>>(
          'enet_packet_create');
  late final _enet_packet_create =
      _enet_packet_createPtr.asFunction<ffi.Pointer<ENetPacket> Function(ffi.Pointer<ffi.Void>, int, int)>();

  late final _enet_host_destroyPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ENetHost>)>>('enet_host_destroy');
  late final _enet_host_destroy = _enet_host_destroyPtr.asFunction<void Function(ffi.Pointer<ENetHost>)>();

  late final _enet_peer_sendPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ENetPeer>, ffi.Uint8, ffi.Pointer<ENetPacket>)>>(
          'enet_peer_send');
  late final _enet_peer_send =
      _enet_peer_sendPtr.asFunction<int Function(ffi.Pointer<ENetPeer>, int, ffi.Pointer<ENetPacket>)>();

  late final _enet_host_flushPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ENetHost>)>>('enet_host_flush');
  late final _enet_host_flush = _enet_host_flushPtr.asFunction<void Function(ffi.Pointer<ENetHost>)>();

  late final _enet_packet_destroyPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ENetPacket>)>>('enet_packet_destroy');
  late final _enet_packet_destroy = _enet_packet_destroyPtr.asFunction<void Function(ffi.Pointer<ENetPacket>)>();

  late final _enet_host_broadcastPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ENetHost>, ffi.Uint8, ffi.Pointer<ENetPacket>)>>(
          'enet_host_broadcast');
  late final _enet_host_broadcast =
      _enet_host_broadcastPtr.asFunction<void Function(ffi.Pointer<ENetHost>, int, ffi.Pointer<ENetPacket>)>();

  late final _enet_host_bandwidth_limitPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ENetHost>, ffi.Uint32, ffi.Uint32)>>(
          'enet_host_bandwidth_limit');
  late final _enet_host_bandwidth_limit =
      _enet_host_bandwidth_limitPtr.asFunction<void Function(ffi.Pointer<ENetHost>, int, int)>();

  late final _enet_host_bandwidth_throttlePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ENetHost>)>>('enet_host_bandwidth_throttle');
  late final _enet_host_bandwidth_throttle =
      _enet_host_bandwidth_throttlePtr.asFunction<void Function(ffi.Pointer<ENetHost>)>();

  late final _enet_host_channel_limitPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ENetHost>, ffi.Size)>>('enet_host_channel_limit');
  late final _enet_host_channel_limit =
      _enet_host_channel_limitPtr.asFunction<void Function(ffi.Pointer<ENetHost>, int)>();

  late final _enet_packet_resizePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ENetPacket> Function(ffi.Pointer<ENetPacket>, ffi.Size)>>(
          'enet_packet_resize');
  late final _enet_packet_resize =
      _enet_packet_resizePtr.asFunction<ffi.Pointer<ENetPacket> Function(ffi.Pointer<ENetPacket>, int)>();
}

// =======================================================================//
// !
// ! typedefs
// !
// =======================================================================//

/// Callback that computes the checksum of the data held in buffers[0:bufferCount-1]
typedef ENetChecksumCallback = ffi.Pointer<ffi.NativeFunction<ENetChecksumCallbackFunction>>;
typedef ENetChecksumCallbackFunction = ffi.Uint32 Function(ffi.Pointer<ENetBuffer> buffers, ffi.Size bufferCount);

typedef ENetInterceptCallback = ffi.Pointer<ffi.NativeFunction<ENetInterceptCallbackFunction>>;
typedef ENetInterceptCallbackFunction = ffi.Int Function(ffi.Pointer<ENetHost> host, ffi.Pointer<ffi.Void> event);

typedef ENetPacketFreeCallback = ffi.Pointer<ffi.NativeFunction<ENetPacketFreeCallbackFunction>>;
typedef ENetPacketFreeCallbackFunction = ffi.Void Function(ffi.Pointer<ffi.Void>);

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

  /// < total UDP packets sent, user should reset to 0 as needed to prevent overflow
  @ffi.Uint32()
  external int totalSentPackets;

  /// < total data received, user should reset to 0 as needed to prevent overflow
  @ffi.Uint32()
  external int totalReceivedData;

  /// < total UDP packets received, user should reset to 0 as needed to prevent overflow
  @ffi.Uint32()
  external int totalReceivedPackets;

  /// < callback the user can set to intercept received raw UDP packets
  external ENetInterceptCallback intercept;

  @ffi.Size()
  external int connectedPeers;

  @ffi.Size()
  external int bandwidthLimitedPeers;

  /// < optional number of allowed peers from duplicate IPs, defaults to ENET_PROTOCOL_MAXIMUM_PEER_ID
  @ffi.Size()
  external int duplicatePeers;

  /// < the maximum allowable packet size that may be sent or received on a peer
  @ffi.Size()
  external int maximumPacketSize;

  /// < the maximum aggregate amount of buffer space a peer may use waiting for packets to be delivered
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

  /// < mean packet loss of reliable packets as a ratio with respect to the constant ENET_PEER_PACKET_LOSS_SCALE
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

  /// < mean round trip time (RTT), in milliseconds, between sending a reliable packet and receiving its acknowledgement
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

/// An ENet packet compressor for compressing UDP packets before socket sends or receives.
final class ENetCompressor extends ffi.Struct {
  /// Context data for the compressor. Must be non-NULL.
  external ffi.Pointer<ffi.Void> context;

  /// Compresses from inBuffers[0:inBufferCount-1], containing inLimit bytes, to outData, outputting at most outLimit bytes. Should return 0 on failure.
  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Size Function(ffi.Pointer<ffi.Void> context, ffi.Pointer<ENetBuffer> inBuffers, ffi.Size inBufferCount,
              ffi.Size inLimit, ffi.Pointer<ffi.Uint8> outData, ffi.Size outLimit)>> compress;

  /// Decompresses from inData, containing inLimit bytes, to outData, outputting at most outLimit bytes. Should return 0 on failure.
  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Size Function(ffi.Pointer<ffi.Void> context, ffi.Pointer<ffi.Uint8> inData, ffi.Size inLimit,
              ffi.Pointer<ffi.Uint8> outData, ffi.Size outLimit)>> decompress;

  /// Destroys the context when compression is disabled or the host is destroyed. May be NULL.
  external ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void> context)>> destroy;
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

/// An ENet event as returned by enet_host_service().
///
/// @sa enet_host_service
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
///
/// An ENet data packet that may be sent to or received from a peer. The shown
/// fields should only be read and never modified. The data field contains the
/// allocated data for the packet. The dataLength fields specifies the length
/// of the allocated data.  The flags field is either 0 (specifying no flags),
/// or a bitwise-or of any combination of the following flags:
///
/// ENET_PACKET_FLAG_RELIABLE - packet must be received by the target peer and resend attempts should be made until the packet is delivered
/// ENET_PACKET_FLAG_UNSEQUENCED - packet will not be sequenced with other packets (not supported for reliable packets)
/// ENET_PACKET_FLAG_NO_ALLOCATE - packet will not allocate data, and user must supply it instead
/// ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT - packet will be fragmented using unreliable (instead of reliable) sends if it exceeds the MTU
/// ENET_PACKET_FLAG_SENT - whether the packet has been sent from all queues it has been entered into
/// @sa ENetPacketFlag
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