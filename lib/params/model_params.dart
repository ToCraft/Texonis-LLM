import 'package:ffi/ffi.dart' show StringUtf8Pointer, malloc;
import 'dart:ffi';
import '../texonis_llm_bindings_wrapper.dart';
import '../texonis_llm_bindings_generated.dart';

/// Enum representing how to split the model across multiple GPUs
enum LlamaSplitMode {
  none,
  layer,
  row,
}

class ModelParams {
  /// number of layers to store in VRAM
  int n_gpu_layers = 99;

  /// how to split the model across multiple GPUs
  LlamaSplitMode split_mode = LlamaSplitMode.none;

  /// the GPU that is used for the entire model when split_mode is LLAMA_SPLIT_MODE_NONE
  int main_gpu = 0;

  /// proportion of the model (layers or rows) to offload to each GPU, size: llama_max_devices()
  List<Float> tensor_split = [];

  /// comma separated list of RPC servers to use for offloading
  String rpc_servers = "";

  /// override key-value pairs of the model meta data
  Map<String, dynamic> kvOverrides = {};

  /// only load the vocabulary, no weights
    bool vocab_only = false;

  /// use mmap if possible
    bool use_mmap = true;

  /// force system to keep model in RAM
    bool use_mlock = false;

  /// validate model tensor data
    bool check_tensors = true;

  /// Constructs and returns a `llama_model_params` object with current settings
  llama_model_params get() {
    final modelParams = getDefaultModelParams();

    // Basic parameters
    modelParams.n_gpu_layers = n_gpu_layers;
    modelParams.main_gpu = main_gpu;
    modelParams.vocab_only = vocab_only;
    modelParams.use_mmap = use_mmap;
    modelParams.use_mlock = use_mlock;
    modelParams.check_tensors = check_tensors;

    Pointer<Float>? tensorSplitPtr;

    // Handle tensor_split
    if (tensor_split.isNotEmpty) {
      tensorSplitPtr = malloc<Float>(tensor_split.length);
      for (var i = 0; i < tensor_split.length; i++) {
        tensorSplitPtr[i] = tensor_split[i] as double;
      }
      modelParams.tensor_split = tensorSplitPtr;
    }

    Pointer<Char>? rpcServersPtr;

    // Handle rpc_servers
    if (rpc_servers.isNotEmpty) {
      rpcServersPtr = rpc_servers.toNativeUtf8().cast<Char>();
      modelParams.rpc_servers = rpcServersPtr;
    }

    // Complex pointers set to null
    modelParams.progress_callback = nullptr;
    modelParams.progress_callback_user_data = nullptr;
    modelParams.kv_overrides = nullptr;

    return modelParams;
  }
}