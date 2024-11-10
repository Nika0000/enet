import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:enet/src/types.dart';
import 'package:enet/src/bindings/lib_enet.dart';
import 'package:enet/src/bindings/enet_bindings.dart' as bindings;
import 'package:ffi/ffi.dart';

final _instance = LibENet.instance;

final class ENetAddress implements Finalizable {
  late final Pointer<bindings.ENetAddress> _address;

  static final _finalizer = NativeFinalizer(calloc.nativeFree);

  ENetAddress({InternetAddress? host, int? port}) {
    _address = calloc<bindings.ENetAddress>();

    if (host != null) {
      setHost(host);
    }

    port != null ? this.port = port : null;

    _finalizer.attach(this, _address.cast(), detach: this);
  }

  ENetAddress.parse(bindings.ENetAddress address) {
    _address = calloc<bindings.ENetAddress>();
    _finalizer.attach(this, _address.cast(), detach: this);
    _address.ref = address;
  }

  Future<InternetAddress> get host async {
    Pointer<Char> cHost = calloc<Char>(ENET_MAX_HOST_NAME);
    Pointer<Char> cIp = calloc<Char>(ENET_MAX_HOST_NAME);

    try {
      int host = _instance.enet_address_get_host(_address, cHost, ENET_MAX_HOST_NAME);
      int ip = _instance.enet_address_get_host_ip(_address, cIp, ENET_MAX_HOST_NAME);

      if (host < 0 && ip < 0) {
        //TODO: add ENetException
      }

      final lookup = await InternetAddress.lookup(cHost.cast<Utf8>().toDartString());

      final address = lookup.singleWhere(
        (addr) => addr.address == cIp.cast<Utf8>().toDartString(),
      );

      return address;
    } finally {
      calloc.free(cHost);
      calloc.free(cIp);
    }
  }

  void setHost(InternetAddress ip) {
    Pointer<Utf8> cValue = ip.host.toNativeUtf8();
    int err = _instance.enet_address_set_host(_address, cValue.cast<Char>());

    if (err < 0) {
      //TODO: add ENetException
    }
  }

  int get port => _address.ref.port;
  set port(int value) => _address.ref.port = value;

  Pointer<bindings.ENetAddress> get pointer => _address;
}
