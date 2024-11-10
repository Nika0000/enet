import 'dart:convert';
import 'dart:io';

import 'package:enet/enet.dart';
import 'package:flutter/material.dart';

void main() async {
  ENet.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: const HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum ConnectionState {
  connecting,
  connected,
  disconnected,
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late TabController _tabcontroller;
  List<String> _messages = [];

  ConnectionState connectionState = ConnectionState.disconnected;
  final host = ENetHost.create(
    peerCount: 3,
    channelLimit: 3,
  );

  late ENetPeer peer;

  @override
  void initState() {
    _tabcontroller = TabController(length: 2, vsync: this);
    super.initState();
  }

  void addMessage(String message) {
    setState(() {
      _messages.insert(0, "[${DateTime.now()}] - $message");
    });
  }

  void sendMessage() {
    if (_messageController.text.isEmpty) return;
    final packet = ENetPacket.create(
      data: utf8.encode(_messageController.text.trim()),
      flags: ENetPacketFlag.sent,
    );

    addMessage("ME: ${_messageController.text}");
    peer.send(0, packet);
    print(host.peerCount);
    _messageController.clear();
    FocusScope.of(context).requestFocus();
  }

  void startClientService() async {
    setState(() {
      connectionState = ConnectionState.connecting;
    });

    addMessage("Connecting to peer...");

    peer = host.connect(ENetAddress(host: InternetAddress(_hostController.text.trim()), port: 7777), 1);
    ENetEvent event;

    bool isRuning = true;

    while (isRuning) {
      event = await host.service(timeout: 50);

      switch (event.type) {
        case ENetEventType.none:
          continue;
        case ENetEventType.connect:
          setState(() {
            connectionState = ConnectionState.connected;
          });
          addMessage("Connected!");
          break;
        case ENetEventType.disconnect:
          isRuning = false;
          setState(() {
            connectionState = ConnectionState.disconnected;
          });
          addMessage("Connection closed!");
          break;
        case ENetEventType.receive:
          if (event.packet != null) {
            final message = utf8.decode(event.packet!.data);
            addMessage("Remote: $message");
          }
          break;
        case ENetEventType.disconnectTimeout:
          addMessage("Connection timeouted");
          isRuning = false;
          setState(() {
            connectionState = ConnectionState.disconnected;
          });
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabcontroller,
          tabs: const [Tab(text: 'Client'), Tab(text: 'Server')],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabcontroller,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        label: Text('Remote Peer'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: switch (connectionState) {
                            ConnectionState.connected => Colors.red,
                            ConnectionState.disconnected => Colors.green,
                            ConnectionState.connecting => Colors.grey,
                          },
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          switch (connectionState) {
                            case ConnectionState.connecting:
                            case ConnectionState.connected:
                              peer.disconnect();
                              break;
                            case ConnectionState.disconnected:
                              startClientService();
                              break;
                          }
                        },
                        child: Text(
                          switch (connectionState) {
                            ConnectionState.connected => "Disconnect",
                            ConnectionState.disconnected => "Connect",
                            ConnectionState.connecting => "Connecting...",
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                // controller: _scrollController,
                                padding: const EdgeInsets.all(8.0),
                                reverse: true,
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Text(message));
                                },
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      enabled: connectionState == ConnectionState.connected,
                                      onSubmitted: (_) => sendMessage(),
                                      decoration: const InputDecoration(
                                        hintText: "Enter message",
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: connectionState == ConnectionState.connected
                                        ? () {
                                            sendMessage();
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Column()
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String user;
  final String message;

  ChatMessage({required this.user, required this.message});
}

class ChatBox extends StatefulWidget {
  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _addMessage(String messageText) {
    final message = ChatMessage(user: "User", message: messageText);
    setState(() {
      _messages.insert(0, message); // Insert at the start for a livestream feel
    });
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return ListTile(
                title: Text(message.user),
                subtitle: Text(message.message),
              );
            },
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Enter message",
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    _addMessage(_controller.text);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

/* 
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              print('Hosting enet server');

              final ENetHost host = ENetHost.create(
                address: ENetAddress(
                  host: InternetAddress.anyIPv4,
                  port: 7777,
                ),
                peerCount: 32,
                channelLimit: 1,
              );

              ENetEvent event;

              bool isRunning = true;
              while (isRunning) {
                event = await host.service(timeout: 500);

                if (event.type == ENetEventType.ENET_EVENT_TYPE_NONE) {
                  continue;
                }

                switch (event.type) {
                  case ENetEventType.ENET_EVENT_TYPE_CONNECT:
                    print('Peer connect event');
                  case ENetEventType.ENET_EVENT_TYPE_DISCONNECT:
                    isRunning = false;
                    print('Disconnected');
                  case ENetEventType.ENET_EVENT_TYPE_RECEIVE:
                    if (event.packet != null) {
                      String content = utf8.decode(event.packet!.data);
                      print("new message $content");
                    }
                    print('received empty message');
                  case ENetEventType.ENET_EVENT_TYPE_DISCONNECT_TIMEOUT:
                    print('peer disconnected due timeout');
                  default:
                    break;
                }
              }
            },
            child: Text('Host'),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              final ENetHost clientHost = ENetHost.create(
                peerCount: 1,
                channelLimit: 1,
              );

              final ENetPeer peer = clientHost.connect(
                ENetAddress(
                  host: InternetAddress('192.168.27.214'),
                  port: 7777,
                ),
                1,
              );

              bool isRunning = true;
              ENetEvent event;

              while (isRunning) {
                event = await clientHost.service(timeout: 500);
                final packet = ENetPacket.create(
                  data: utf8.encode("HI From peer ${DateTime.now()}"),
                  flags: ENetPacketFlag.ENET_PACKET_FLAG_SENT,
                );
                peer.send(
                  0,
                  packet,
                );
                if (event.type == ENetEventType.ENET_EVENT_TYPE_NONE) {
                  continue;
                }
              }
            },
            child: Text('Connect'),
          ),
        ],
      ),
    );
  }
}
 */
