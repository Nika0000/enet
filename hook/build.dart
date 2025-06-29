import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  const isDebugMode = bool.fromEnvironment('ENET_DEBUG');

  await build(args, (input, output) async {
    final packageName = input.packageName;
    final targetOS = input.config.code.targetOS;
    final linkMode = input.config.code.linkModePreference;

    final flags = <String>[];
    final defines = <String, String>{};

    if (isDebugMode) {
      defines['ENET_DEBUG'] = '1';

      // link log lib for android
      if (targetOS == OS.android) {
        flags.add('-llog');
      }
    }

    if (targetOS == OS.windows) {
      flags.add('/W3'); // Equivalent to MSVC /W3 warning level
      if (linkMode == LinkModePreference.dynamic) {
        defines['ENET_DLL'] = '0';
      } else {
        defines['ENET_DLL'] = '1';
      }
    } else if (targetOS == OS.linux) {
      flags.add('-Wall'); // Common flag for Linux GCC/Clang compilers
    }

    final cbuilder = CBuilder.library(
      name: packageName,
      assetName: '$packageName.dart',
      flags: flags,
      defines: defines,
      sources: ['src/$packageName.c'],
    );

    await cbuilder.run(input: input, output: output, logger: null);
  });
}
