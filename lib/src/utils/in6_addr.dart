import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'dart:io';

import 'package:enet/src/bindings/enet_bindings.dart' as bindings;

bindings.in6_addr ipToIn6Addr(InternetAddress ip) {
  final _in6_addr = calloc<bindings.in6_addr>();
  List<int> bytes = ip.rawAddress.toList();

  try {
    if (ip.type == InternetAddressType.IPv4) {
      for (int i = 0; i < 4; i++) {
        _in6_addr.ref.u.Byte[i] = bytes[i];
      }
    } else {
      for (int i = 0; i < 16; i++) {
        _in6_addr.ref.u.Byte[i] = bytes[i];
      }
    }
    return _in6_addr.ref;
  } finally {
    malloc.free(_in6_addr);
  }
}

InternetAddress in6AddrToIP(bindings.in6_addr addr) {
  List<int> bytes = [];

  for (int i = 0; i < 16; i++) {
    bytes.insert(i, addr.u.Byte[i]);
  }

  print(bytes);

  bool isIPv4 = bytes.getRange(4, 16).where((element) => element > 0).length == 0;

  if (isIPv4) {
    //remove empty bites
    bytes.removeRange(4, 16);
  }

  return InternetAddress.fromRawAddress(Uint8List.fromList(bytes));
}
