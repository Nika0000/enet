import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  await build(
    args,
    (config, output) async {
      final packageName = config.packageName;

      final flags = <String>[];
      final defines = <String, String>{};

      if (config.buildMode.name == 'debug') {
        defines['ENET_DEBUG'] = '1';
      }

      if (config.targetOS == OS.windows) {
        flags.add('/W3'); // Equivalent to MSVC /W3 warning level
        defines['DART_SHARED_LIB'] = '1';
        defines['ENET_DLL'] = '1';
      } else if (config.targetOS == OS.linux) {
        flags.add('-Wall'); // Common flag for Linux GCC/Clang compilers
      }

      final cbuilder = CBuilder.library(
        name: packageName,
        assetName: 'lib/$packageName.dart',
        flags: flags,
        defines: defines,
        language: Language.c,
        sources: [
          'src/$packageName.c',
        ],
      );

      await cbuilder.run(
        config: config,
        output: output,
        logger: null,
      );
    },
  );
}
