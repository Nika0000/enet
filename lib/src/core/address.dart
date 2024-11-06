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

  ENetAddress() {
    _address = calloc<bindings.ENetAddress>();
    _finalizer.attach(this, _address.cast(), detach: this);
  }

  ENetAddress.parse(bindings.ENetAddress address) {
    _address = calloc<bindings.ENetAddress>();
    _finalizer.attach(this, _address.cast(), detach: this);
    _address.ref = address;
  }

  InternetAddress get host {
    Pointer<Char> cHost = calloc<Char>(ENET_MAX_HOST_NAME);

    try {
      int err = _instance.enet_address_get_host(_address, cHost, ENET_MAX_HOST_NAME);

      if (err < 0) {
        //TODO: add ENetException
      }
      return InternetAddress(cHost.cast<Utf8>().toDartString());
    } finally {
      calloc.free(cHost);
    }
  }

  set host(InternetAddress ip) {
    Pointer<Utf8> cValue = ip.address.toNativeUtf8();
    int err = _instance.enet_address_set_host(_address, cValue.cast<Char>());

    if (err < 0) {
      //TODO: add ENetException
    }
  }

  int get port => _address.ref.port;
  set port(int value) => _address.ref.port = value;

  Pointer<bindings.ENetAddress> get pointer => _address;
}
