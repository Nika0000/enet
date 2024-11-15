import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:enet/enet.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'package:enet/src/bindings/enet_bindings.dart' as bindings;

void main() {
  group('ENet Bindings Test', () {
    test('Initialize ENet', () {
      final result = bindings.enet_initialize();
      expect(result, equals(0), reason: 'ENet should initialize successfully.');
    });

    test('Get ENet Linked Version', () {
      final version = bindings.enet_linked_version();
      expect(version, greaterThan(0), reason: 'Linked version should be non-zero.');
    });

    test('Get ENet Time', () {
      final time = bindings.enet_time_get();
      expect(time, greaterThanOrEqualTo(0), reason: 'Time should be a non-negative integer.');
    });

    test('Deinitialize ENet', () {
      // Deinitializing ENet should not throw an exception.
      expect(() => bindings.enet_deinitialize(), returnsNormally, reason: 'ENet should deinitialize without error.');
    });
  });

  group('ENet Address Bindings Test', () {
    late ffi.Pointer<bindings.ENetAddress> address;
    late ffi.Pointer<ffi.Char> hostNameBuffer;
    const int bufferSize = 256;

    setUp(() {
      address = calloc<bindings.ENetAddress>();
      hostNameBuffer = calloc<ffi.Char>(bufferSize);
    });

    tearDown(() {
      // Free allocated memory.
      calloc.free(address);
      calloc.free(hostNameBuffer);
    });

    test('Get Host Name from Address', () {
      final result = bindings.enet_address_get_host_new(address, hostNameBuffer, bufferSize);
      expect(result, equals(0), reason: 'Should successfully get host name.');

      final hostName = hostNameBuffer.cast<Utf8>().toDartString();
      expect(hostName, isNotEmpty, reason: 'Host name should not be empty.');
    });

    test('Set Host Name to Address', () {
      final hostName = 'example.com';
      final hostNamePtr = hostName.toNativeUtf8();

      final result = bindings.enet_address_set_host(address, hostNamePtr.cast<ffi.Char>());
      expect(result, equals(0), reason: 'Should successfully set host name.');

      calloc.free(hostNamePtr);
    });

    test('Set Host IP to Address', () {
      final hostIP = '127.0.0.1';
      final hostIPPtr = hostIP.toNativeUtf8();

      //final result = bindings.enet_address_set_host_ip(address, hostIPPtr.cast<ffi.Char>());
     // expect(result, equals(0), reason: 'Should successfully set host IP.');

      calloc.free(hostIPPtr);
    });

    test('Get Host IP from Address', () {
      final result = bindings.enet_address_get_host_ip_new(address, hostNameBuffer, bufferSize);
      expect(result, equals(0), reason: 'Should successfully get host IP.');

      final hostIP = hostNameBuffer.cast<Utf8>().toDartString();
      expect(hostIP, isNotEmpty, reason: 'Host IP should not be empty.');
    });
  });

  group('ENet Host Bindings Test', () {
    late ffi.Pointer<bindings.ENetAddress> address;
    late ffi.Pointer<bindings.ENetHost> host;
    late ffi.Pointer<bindings.ENetEvent> event;

    setUp(() {
      // Allocate memory for address and event.
      address = calloc<bindings.ENetAddress>();
      event = calloc<bindings.ENetEvent>();
    });

    tearDown(() {
      // Free allocated memory.
      calloc.free(address);
      calloc.free(event);
    });

    test('Create Host', () {
      host = bindings.enet_host_create(address, 32, 2, 1024 * 1024, 1024 * 1024);
      expect(host, isNot(ffi.nullptr), reason: 'Host creation should succeed.');

      // Destroy host after test.
      bindings.enet_host_destroy(host);
    });

    test('Connect to Host', () {
      host = bindings.enet_host_create(ffi.nullptr, 32, 2, 1024 * 1024, 1024 * 1024);
      expect(host, isNot(ffi.nullptr), reason: 'Host creation should succeed.');

      // Setup a dummy address for testing.
      address.ref.port = 12345;
      // Set an example IP; adjust this to match your test setup.
      // Use a real IP or mock the function if necessary.
      final ip = '127.0.0.1'.toNativeUtf8();
      bindings.enet_address_set_host_ip(address, ip.cast<ffi.Char>());
      calloc.free(ip);

      final peer = bindings.enet_host_connect(host, address, 2, 0);
      expect(peer, isNot(ffi.nullptr), reason: 'Host connection should succeed.');

      // Destroy host after test.
      bindings.enet_host_destroy(host);
    });

    test('Host Service', () {
      host = bindings.enet_host_create(ffi.nullptr, 32, 2, 1024 * 1024, 1024 * 1024);
      expect(host, isNot(ffi.nullptr), reason: 'Host creation should succeed.');

      address.ref.port = 12345;
      final ip = '127.0.0.1'.toNativeUtf8();
      bindings.enet_address_set_host_ip(address, ip.cast<ffi.Char>());
      calloc.free(ip);

      final peer = bindings.enet_host_connect(host, address, 2, 0);
      expect(peer, isNot(ffi.nullptr), reason: 'Host connection should succeed.');

      // Simulate events by calling enet_host_service.
      int result = -1;
      do {
        result = bindings.enet_host_service(host, event, 100);
      } while (result < 0);

      // Allow valid results: no event (0) or successful event (> 0).
      expect(result, anyOf(equals(0), greaterThan(0)), reason: 'Service call should complete successfully.');

      // Step 5: Destroy host after test.
      bindings.enet_host_destroy(host);
    });

    test('Flush Host', () {
      host = bindings.enet_host_create(ffi.nullptr, 32, 2, 1024 * 1024, 1024 * 1024);
      expect(host, isNot(ffi.nullptr), reason: 'Host creation should succeed.');

      // Flush the host to ensure queued packets are sent.
      expect(() => bindings.enet_host_flush(host), returnsNormally, reason: 'Flushing host should not throw an error.');

      // Destroy host after test.
      bindings.enet_host_destroy(host);
    });

    test('Adjust Bandwidth Limit', () {
      host = bindings.enet_host_create(ffi.nullptr, 32, 2, 1024 * 1024, 1024 * 1024);
      expect(host, isNot(ffi.nullptr), reason: 'Host creation should succeed.');

      // Adjust bandwidth limits and expect no errors.
      expect(() => bindings.enet_host_bandwidth_limit(host, 512 * 1024, 512 * 1024), returnsNormally,
          reason: 'Adjusting bandwidth limits should not throw an error.');

      // Destroy host after test.
      bindings.enet_host_destroy(host);
    });
  });

  group('ENet Packet Bindings Test', () {
    late ffi.Pointer<bindings.ENetPacket> packet;

    tearDown(() {
      // Clean up allocated resources.
      if (packet != ffi.nullptr) {
        bindings.enet_packet_destroy(packet);
      }
    });

    test('Create Packet', () {
      // Allocate some data for the packet.
      final data = Uint8List.fromList([1, 2, 3, 4, 5]).buffer.asUint8List();
      final dataPointer = calloc.allocate<ffi.Uint8>(data.length);
      dataPointer.asTypedList(data.length).setAll(0, data);

      // Create the packet.
      packet = bindings.enet_packet_create(dataPointer.cast(), data.length, 0);
      expect(packet, isNot(ffi.nullptr), reason: 'Packet creation should succeed.');

      // Verify packet contents (if available in your implementation).
      calloc.free(dataPointer);
    });

    test('Resize Packet', () {
      // Create an initial packet.
      packet = bindings.enet_packet_create(ffi.nullptr, 10, 0);
      expect(packet, isNot(ffi.nullptr), reason: 'Packet creation should succeed.');

      // Resize the packet.
      final resizedPacket = bindings.enet_packet_resize(packet, 20);
      expect(resizedPacket, isNot(ffi.nullptr), reason: 'Packet resize should succeed.');

      // Update the pointer if resize succeeded.
      packet = resizedPacket;
    });

    test('Destroy Packet', () {
      // Create a packet to destroy.
      packet = bindings.enet_packet_create(ffi.nullptr, 10, 0);
      expect(packet, isNot(ffi.nullptr), reason: 'Packet creation should succeed.');

      // Destroy the packet and verify it doesn't throw errors.
      expect(() => bindings.enet_packet_destroy(packet), returnsNormally,
          reason: 'Destroying a packet should not throw errors.');

      // Reset pointer to nullptr to avoid double-free.
      packet = ffi.nullptr;
    });
  });

  group('ENet Peer Bindings Test', () {
    late ffi.Pointer<bindings.ENetHost> host;
    late ffi.Pointer<bindings.ENetPeer> peer;
    late ffi.Pointer<bindings.ENetPacket> packet;

    final address = calloc<bindings.ENetAddress>();
    final event = calloc<bindings.ENetEvent>();

    setUp(() {
      // Create host for testing.
      host = bindings.enet_host_create(ffi.nullptr, 32, 2, 1024 * 1024, 1024 * 1024);
      expect(host, isNot(ffi.nullptr), reason: 'Host creation should succeed.');

      // Set up peer address and connect.
      address.ref.port = 12345;
      final ip = '127.0.0.1'.toNativeUtf8();
      bindings.enet_address_set_host_ip(address, ip.cast<ffi.Char>());
      calloc.free(ip);

      peer = bindings.enet_host_connect(host, address, 2, 0);
      expect(peer, isNot(ffi.nullptr), reason: 'Host connection should succeed.');

      // Simulate connection completion.
      bindings.enet_host_service(host, event, 100);
    });

    tearDown(() {
      // Clean up allocated resources.
      if (peer != ffi.nullptr) {
        bindings.enet_peer_disconnect(peer, 0);
      }
      if (host != ffi.nullptr) {
        bindings.enet_host_destroy(host);
      }
      if (packet != ffi.nullptr) {
        bindings.enet_packet_destroy(packet);
      }
      calloc.free(address);
      calloc.free(event);
    });

    test('Send Packet to Peer', () {
      // Create a packet to send.
      final data = Uint8List.fromList([1, 2, 3, 4, 5]).buffer.asUint8List();
      final dataPointer = calloc.allocate<ffi.Uint8>(data.length);
      dataPointer.asTypedList(data.length).setAll(0, data);

      packet = bindings.enet_packet_create(dataPointer.cast(), data.length, 0);
      calloc.free(dataPointer);
      expect(packet, isNot(ffi.nullptr), reason: 'Packet creation should succeed.');

      //  final result = bindings.enet_peer_send(peer, 0, packet);
      //  expect(result, equals(0), reason: 'Packet sending should succeed.');
    });

    /*   test('Disconnect Peer', () {
      // Disconnect the peer.
      bindings.enet_peer_disconnect(peer, 0);

      //Wait for the disconnection to complete.
      final result = bindings.enet_host_service(host, event, 100);
      expect(result, greaterThanOrEqualTo(0), reason: 'Disconnection event should be handled.');
    }); */
  });

  group('ENet Dart Tests', () {
    setUp(() {
      // Initialize ENet before running tests.
      ENet.initialize();
    });

    tearDown(() {
      // Deinitialize ENet after tests complete.
      ENet.deinitialize();
    });

    test('Host starts successfully', () {
      final host = ENetHost.create(
        address: ENetAddress(host: InternetAddress.anyIPv4, port: 7777),
        peerCount: 1,
        channelLimit: 1,
      );

      //TODO dont return exception
      expect(host, isNotNull, reason: 'Host creation should not return null.');

      host.destroy();
    });

    test('Client connects and exchanges messages with Host', () async {
      // Set up the host
      final host = ENetHost.create(
        address: ENetAddress(host: InternetAddress.anyIPv4, port: 7777),
        peerCount: 1,
        channelLimit: 1,
      );
      expect(host, isNotNull, reason: 'Host creation should not return null.');

      // Set up the client
      final client = ENetHost.create(
        peerCount: 1,
        channelLimit: 1,
      );
      expect(client, isNotNull, reason: 'Client creation should not return null.');

      // Connect the client to the host
      final peer = client.connect(
        ENetAddress(host: InternetAddress.loopbackIPv4, port: 7777),
        1,
      );
      expect(peer, isNotNull, reason: 'Client should connect to the host.');

      bool hostConnected = false;
      bool clientConnected = false;

      String testMessage = 'Hello from client!';
      bool messageReceivedByHost = false;

      // Service events on both sides to establish connection and exchange messages
      for (int i = 0; i < 100; i++) {
        // Process host events
        final hostEvent = await host.service();
        if (hostEvent.type == ENetEventType.connect) {
          hostConnected = true;
        } else if (hostEvent.type == ENetEventType.receive) {
          final receivedData = utf8.decode(hostEvent.packet!.data);
          if (receivedData == testMessage) {
            messageReceivedByHost = true;
          }
        }

        // Process client events
        final clientEvent = await client.service();
        if (clientEvent.type == ENetEventType.connect) {
          clientConnected = true;

          // Send a message to the host
          final packet = ENetPacket.create(
            data: utf8.encode(testMessage),
            flags: ENetPacketFlag.sent,
          );

          peer.send(0, packet);
        }

        if (hostConnected && clientConnected && messageReceivedByHost) {
          break;
        }
      }

      // Verify connection and message exchange
      expect(hostConnected, isTrue, reason: 'Host should detect client connection.');
      expect(clientConnected, isTrue, reason: 'Client should detect connection to the host.');
      expect(
        messageReceivedByHost,
        isTrue,
        reason: 'Host should receive the message sent by the client.',
      );

      // Clean up
      host.destroy();
      client.destroy();
    });

    test('Host handles client disconnection gracefully', () async {
      // Set up the host
      final host = ENetHost.create(
        address: ENetAddress(host: InternetAddress.anyIPv4, port: 7777),
        peerCount: 1,
        channelLimit: 1,
      );
      expect(host, isNotNull, reason: 'Host creation should not return null.');

      // Set up the client
      final client = ENetHost.create(
        peerCount: 1,
        channelLimit: 1,
      );
      expect(client, isNotNull, reason: 'Client creation should not return null.');

      // Connect the client to the host
      final peer = client.connect(
        ENetAddress(host: InternetAddress.loopbackIPv4, port: 7777),
        1,
      );
      expect(peer, isNotNull, reason: 'Client should connect to the host.');

      bool disconnectDetected = false;

      // Wait and process events on the host side
      for (int i = 0; i < 100; i++) {
        client.service(timeout: 0);
        final hostEvent = await host.service();
        if (hostEvent.type == ENetEventType.connect) {
          peer.disconnect();
        }

        if (hostEvent.type == ENetEventType.disconnect) {
          disconnectDetected = true;
          break;
        }
      }

      // Verify that the host detected the disconnection
      expect(
        disconnectDetected,
        isTrue,
        reason: 'Host should detect when a client disconnects.',
      );

      // Clean up
      host.destroy();
      client.destroy();
    });
  });
}
