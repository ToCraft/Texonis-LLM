import 'package:flutter/material.dart';
import 'package:texonis_llm/texonis_llm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Texonis LLM",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "Example for Texonis LLM"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final enteredTextController = TextEditingController();
  final Llama llama = Llama(
    // TODO: Field to set the model path
    "/home/tocraft/Downloads/DistilGPT2-TinyStories.IQ3_M.gguf",
    ModelParams(),
    ContextParams(),
    true,
  );
  String output = "";
  bool isGenerating = false;  // Track generation status

  @override
  void dispose() {
    enteredTextController.dispose();
    super.dispose();
  }
  Future<void> generate() async {
    if (enteredTextController.text.isNotEmpty && !isGenerating) {
      setState(() {
        isGenerating = true;
        output = "Generating...";  // Show a message during generation
      });

      llama.setInput(enteredTextController.text);
      String generatedOutput = '';
      while (await llama.moveNext()) {
        generatedOutput += llama.current;
      }
      setState(() {
        output = generatedOutput;
        isGenerating = false;  // Mark the end of generation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorScheme.fromSeed(seedColor: Colors.red).primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter text',
                ),
                controller: enteredTextController,
              ),
            ),
            const Text("Press the button to generate"),
            SelectableText(
              output,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: generate,
        tooltip: 'Generate',
        child: const Icon(Icons.generating_tokens_outlined),
      ),
    );
  }
}
