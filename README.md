<div align="center" style="text-align: center;">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/c2796073-b7d2-4ba9-b990-75dc755fb675">
    <img alt="" src="https://github.com/user-attachments/assets/e911ce70-12c0-4151-b746-3ed692d275cc" width="40%">
  </picture>
</div>


<div align="center">
    ENet Dart provides reliable, low-latency UDP networking for Dart.<br>
    It reimagines the ENet library with Dart FFI for seamless real-time connectivity.
</div>

<br>

<div align="center">
    <img alt="Pub Version" src="https://img.shields.io/pub/v/enet">
    <img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/Nika0000/enet/build.yaml">
    <img alt="GitHub License" src="https://img.shields.io/github/license/NIka0000/enet">
</div>

<br>

<div align="center">
  
|      Windows       |       macOS        |       Linux        |      Android       |        iOS         | Web |
|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:---:|
| :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :x: |
  
</div>

##

> [!NOTE]
>
> This package uses the [zpl-c/enet]() library, which is a maintained fork of the original ENet library by [isalzman/enet](), ENet Dart relies on the functionalities provided by this C library to deliver reliable, low-latency UDP networking for Dart and Flutter applications.
>


### Description

ENet Dart is designed to make networking easier for Flutter and Dart developers. It integrates smoothly with state management solutions like `provider` and `Bloc`.

> [!WARNING]
>
>  Please note that ENet Dart is not a full binding of the original native library. Some ENet functionalities are still missing or not fully implemented. As a result, certain features from the native ENet library may not be available in this package. We’re continually working to extend the functionality, so expect more updates in the future.

### Features

| Feature                       | Description                                                                              |
|:------------------------------|:-----------------------------------------------------------------------------------------|
| Reliable UDP                  | Combines UDP speed with a reliability layer for consistent data transmission.            |
| Low Latency                   | Optimized for minimal delays, ideal for real-time applications.                          |
| Cross-Platform Support        | Fully supported on Windows, macOS, Linux, Android, and iOS.                              |
| Peer-to-Peer Communication    | Allows direct connections between clients for scalable networking.                       |
| Channel-Based Messaging       | Organize and prioritize messages across multiple channels for streamlined data handling. |
| Packet Reliability & Ordering | Supports both reliable and unreliable packets, with automatic reordering if needed.      |
| Flexible Event Handling       | Asynchronous handling of connection, disconnection, and message events.                  |

### Getting Started

> [!NOTE]
>
> To get started with ENet plugin, you must be on the `master` channel.
> Also you will need to opt-in to the `native-assets` experiment,
> Using the `--enable-experiment=native-assets` flag whenever you run any commands
> using the `$ dart` command line tool.
>
> To enable this globally in Flutter, run:
>
> ```sh
> flutter config --enable-native-assets
> ```

Add ENet to your `pubspec.yaml` file:

```yaml
dependencies:
  enet:
    git:
      url: https://github.com/Nika0000/enet_dart.git
      ref: features/native-assets
```

### Example Usage

#### Host Example

This example demonstrates how to create a host that listens for incoming peer connections on port `7777`. The host will handle connections, disconnections, and message reception events.

```dart
import 'dart:convert';
import 'dart:io';
import 'package:enet/enet.dart';

void main(List<String> arguments) async {
  // Initialize the ENet library, preparing it for use.
  ENet.initialize();

  // Create a host that listens on IPv4 any address (0.0.0.0) and port 7777.
  final host = ENetHost.create(
    address: ENetAddress(host: InternetAddress.anyIPv4, port: 7777),
    peerCount: 1, // Client only needs one peer connection.
    channelLimit: 1, // Communication limited to 1 channel.
  );

  ENetEvent event;

  // Handle SIGINT (Ctrl+C) to cleanly shut down the host.
  ProcessSignal.sigint.watch().listen((e) {
    ENet.deinitialize();
    exit(0);
  });

  print('ctrl+c to quit');

  // Event loop to process ENet events, with a timeout
  // of 50 milliseconds that ENet should wait for events.
  while (true) {
    event = await host.service(timeout: 50);

    // Skip to the next iteration if there's no event.
    if (event.type == ENetEventType.none) {
      continue;
    }

    // Handle events based on their type.
    switch (event.type) {
      case ENetEventType.connect:
        print('New peer connected.');
        break;
      case ENetEventType.disconnect:
        print('Peer disconnected.');
        break;
      case ENetEventType.receive:
        if (event.packet == null || event.packet!.data.isEmpty) {
          print('Received an empty message from the peer.');
        } else {
          final receivedMessage = utf8.decode(event.packet!.data);
          print('New message from the peer: $receivedMessage');
        }
        break;
      default:
        break;
    }
  }
}

```
#### Client Example

In this example, the client connects to the host and sends a message every second. The client listens for messages from the host and logs any received messages to the console.

```dart 
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:enet/enet.dart';

void main(List<String> arguments) async {
  // Initialize ENet for client operations.
  ENet.initialize();

  // Create a client host, configured to connect to a single peer.
  final host = ENetHost.create(
    peerCount: 1,           // Client only needs one peer connection.
    channelLimit: 1,        // Communication limited to 1 channel.
  );

  // Connect to the server at localhost (127.0.0.1) on port 7777.
  final peer = host.connect(
    ENetAddress(host: InternetAddress('127.0.0.1'), port: 7777), 
    1  // Specify a channel limit for this peer connection.
  );

  ENetEvent event;

  ProcessSignal.sigint.watch().listen((e) {
    ENet.deinitialize();
    exit(0);
  });

  print('ctrl+c to quit');

  bool isConnected = false;

  // Event loop to process ENet events, with a timeout 
  // of 50 milliseconds that ENet should wait for events.
  while (true) {
    event = await host.service(timeout: 50);

    // Skip to the next iteration if there's no event.
    if (event.type == ENetEventType.none) {
      continue;
    }

    // Handle the connection event and send messages every second.
    if (!isConnected && event.type == ENetEventType.connect) {
      print('Connection esablished!');

      isConnected = true;

      Timer.periodic(Duration(seconds: 1), (timer) async {
        // Create a packet containing the current time as a message.
        var packet = ENetPacket.create(
          data: utf8.encode("Time is ${DateTime.now()}"),
          flags: ENetPacketFlag.sent,
        );

        // Send the packet over channel 0 to the connected peer.
        peer.send(0, packet);
      });
    }
    
    // Handle other event types like disconnection and message reception.
    switch (event.type) {
      case ENetEventType.disconnect:
        isConnected = false;
        print('Disconnected from the Hest.');
        break;
      case ENetEventType.receive:
        if (event.packet == null || event.packet!.data.isEmpty) {
          print('Received an empty message from the host.');
        } else {
          final receivedMessage = utf8.decode(event.packet!.data);
          print('New message from the host: $receivedMessage');
        }
        break;
      default:
        break;
    }
  }
}
```

### Contribution 


Your contributions are welcome and greatly valued! If you have ideas, suggestions, or improvements, feel free to open an issue or submit a pull request. Every bit of help is appreciated, and your input can make a big difference. Just ensure your contributions fit with the project's goals and guidelines.

### License

This project is licensed under the MIT License. See the [LICENSE.md](./LICENSE) file for more information.
