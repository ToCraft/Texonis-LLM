
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart' show StringUtf8Pointer, malloc;
import 'package:texonis_llm/params/model_params.dart';

import 'texonis_llm_bindings_generated.dart';
import 'params/context_params.dart';

void init() => _bindings.llama_backend_init();
void deInit() => _bindings.llama_backend_free();


Pointer<llama_model> loadModel(String modelPath, llama_model_params modelParams) {
  Pointer<Char> modelPathPtr = modelPath.toNativeUtf8().cast<Char>();
  return _bindings.llama_load_model_from_file(modelPathPtr, modelParams);
}

Pointer<llama_context> loadContext(Pointer<llama_model> model, llama_context_params contextParams) {
  return _bindings.llama_new_context_with_model(model, contextParams);
}

llama_context_params getDefaultContextParams() {
  return _bindings.llama_context_default_params();
}

llama_model_params getDefaultModelParams() {
  return _bindings.llama_model_default_params();
}

llama_sampler_chain_params getDefaultSamplerChainParams() {
  return _bindings.llama_sampler_chain_default_params();
}

llama_batch prompt(Pointer<llama_model> model, String input, bool special) {
  try {
    final promptPtr = input.toNativeUtf8().cast<Char>();

    try {
      int nTokens = -_bindings.llama_tokenize(model, promptPtr, input.length, nullptr, 0, special, special);
      if (nTokens < 0) {
        throw LlmException("Couldn't parse tokens for prompt $input");
      }

      final tokens = malloc<llama_token>(nTokens);
      try {
        nTokens = _bindings.llama_tokenize(model, promptPtr, input.length, tokens, nTokens, special, special);
        if (nTokens < 0) {
          throw LlmException('Tokenization failed');
        }

        return _bindings.llama_batch_get_one(tokens, nTokens);
      } finally {
        malloc.free(tokens);
      }
    } finally {
      malloc.free(promptPtr);
    }
  } catch (e) {
    throw LlmException("Caught an exception while handling the prompt.", e);
  }
}

class Llama implements Iterator<String> {
  late final Pointer<llama_model> model;
  late final Pointer<llama_sampler> sampler;
  late final Pointer<llama_context> context;
  final bool special;
  late llama_batch? batch;
  late final Pointer<llama_token> tokenPtr;
  String value = "";


  Llama(String modelPath, ModelParams modelParams, ContextParams contextParams, this.special) {
    init();

    model = loadModel(modelPath, modelParams.get());
    context = loadContext(model, contextParams.get());
    sampler = _bindings.llama_sampler_chain_init(getDefaultSamplerChainParams());
    _bindings.llama_sampler_chain_add(sampler, _bindings.llama_sampler_init_greedy());
    tokenPtr = malloc<llama_token>();
  }

  void setInput(String input) {
    malloc.free(tokenPtr);

    if (input.isEmpty) {
      throw LlmException("Can't set an empty input!");
    }

    batch = prompt(model, input, special);
  }

  @override
  bool moveNext() {
    if (batch == null) {
      throw LlmException("Set an input first!");
    }

    if (_bindings.llama_decode(context, batch!) != 0) {
      throw LlmException("Couldn't evaluate!");
    }

    int token = _bindings.llama_sampler_sample(sampler, context, -1);

    if (_bindings.llama_token_eos(model) == token) {
      return false;
    } else {
      // get string from token
      final buf = malloc<Char>(256);
      int n = _bindings.llama_token_to_piece(model, token, buf, 256, 0, special);
      value = String.fromCharCodes(buf.cast<Uint8>().asTypedList(n));
      tokenPtr.value = token;
      batch = _bindings.llama_batch_get_one(tokenPtr, 1);
      return true;
    }
  }

  @override
  String get current => value;

  void dispose() {
    if (model != nullptr) {
      malloc.free(model);
    }
    if (sampler != nullptr) {
      malloc.free(sampler);
    }
    if (context != nullptr) {
      malloc.free(context);
    }
    if (tokenPtr != nullptr) {
      malloc.free(tokenPtr);
    }

    deInit();
  }
}

class LlmException implements Exception {
  final String message;
  final dynamic originalError;

  LlmException(this.message, [this.originalError]);

  @override
  String toString() =>
      'LlmException: $message${originalError != null ? ' $originalError' : ''}';
}

final DynamicLibrary _dylib = () {
  loadLib("ggml-base");
  loadLib("ggml-cpu");
  loadLib("ggml");
  return loadLib("llama");
}();

DynamicLibrary loadLib(String libName) {
  {
    if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.open('$libName.framework/$libName');
    }
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('lib$libName.so');
    }
    if (Platform.isWindows) {
      return DynamicLibrary.open('$libName.dll');
    }
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }
}

final TexonisLlmBindings _bindings = TexonisLlmBindings(_dylib);

