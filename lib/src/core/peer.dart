import 'dart:ffi';

import 'package:enet/src/bindings/lib_enet.dart';
import 'package:enet/src/bindings/enet_bindings.dart' as bindings;

final _instance = LibENet.instance;

class ENetPeer {
  late final Pointer<bindings.ENetPeer> _peer;

  ENetPeer.parse(Pointer<bindings.ENetPeer> peer) : _peer = peer {}

  void disconnect({int data = 0}) {}
}
