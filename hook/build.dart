import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(
    args,
    (config, output) async {
      final packageName = config.packageName;

      final logger = Logger('')
        ..level = Level.ALL
        ..onRecord.listen(
          (record) => print(record.message),
        );

      if (!config.dryRun) {
        logger.info(
          'Building ENet for ${config.targetOS} '
          'in mode ${config.buildMode.name}',
        );
      }

      final flags = <String>[];
      final defines = <String, String>{};

      if (!config.dryRun && config.buildMode == BuildMode.debug) {
        defines['ENET_DEBUG'] = '1';
      }

      if (config.targetOS == OS.windows) {
        flags.add('/W3'); // Equivalent to MSVC /W3 warning level
        defines['ENET_DLL'] = '0';
      } else if (config.targetOS == OS.linux) {
        flags.add('-Wall'); // Common flag for Linux GCC/Clang compilers
      }

      final cbuilder = CBuilder.library(
        name: packageName,
        assetName: '$packageName.dart',
        flags: flags,
        defines: defines,
        sources: [
          'src/$packageName.c',
        ],
      );

      await cbuilder.run(
        config: config,
        output: output,
        logger: logger,
      );
    },
  );
}
