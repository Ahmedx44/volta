import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main() async {
  final packageRoot = Platform.script.resolve(('../'));
  final generate = JniGenerator(
    input: Input(
      classes: ['android.os.BatteryManager', 'android.content.Context','android.content.Intent',
        'android.content.IntentFilter',
        'android.content.BroadcastReceiver',],
      androidSdk: AndroidSdk(addGradleDeps: true, androidExample: packageRoot),
    ),
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/android_battery.g.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
  );

  await generate.generate();
}
