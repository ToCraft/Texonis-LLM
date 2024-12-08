import 'package:flutter/material.dart';
import 'package:texonis_llm/texonis_llm.dart';
import 'dart:io';

void main() async {
  String modelPath = "/home/tocraft/Downloads/DistilGPT2-TinyStories.IQ3_M.gguf";
  Llama llama = Llama(modelPath, ModelParams(), ContextParams(), false, "A long time ago ");

  llama.stream().listen((response) {
    stdout.write(response);
  });

  //runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int sumResult = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'sum(1, 2) = $sumResult',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall
              ],
            ),
          ),
        ),
      ),
    );
  }
}
