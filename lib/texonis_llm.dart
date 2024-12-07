
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart' show StringUtf8Pointer;

import 'texonis_llm_bindings_generated.dart';

void init() => _bindings.llama_backend_init();

Pointer<llama_model> loadModel(String modelPath, llama_model_params modelParams) {
  Pointer<Char> modelPathPtr = modelPath.toNativeUtf8().cast<Char>();
  return _bindings.llama_load_model_from_file(modelPathPtr, modelParams);
}

class Llama {
  late Pointer<llama_model> model;
}

const String _libName = 'texonis_llm';
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final TexonisLlmBindings _bindings = TexonisLlmBindings(_dylib);

