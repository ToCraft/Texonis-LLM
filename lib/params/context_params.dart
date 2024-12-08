import '../texonis_llm_bindings_wrapper.dart';
import '../texonis_llm_bindings_generated.dart';

final class ContextParams {
  /// text context, 0 = from model
  int n_ctx = 512;

  /// logical maximum batch size that can be submitted to llama_decode
  int n_batch = 2048;

  /// physical maximum batch size
  int n_ubatch = 512;

  /// max number of sequences (i.e. distinct states for recurrent models)
  int n_seq_max = 1;

  /// Number of threads to use for generation
  int nThreads = 8;

  /// Number of threads to use for batch processing
  int nThreadsBatch = 8;

  /// RoPE base frequency, 0 = from model
  double ropeFreqBase = 0.0;

  /// RoPE frequency scaling factor, 0 = from model
  double ropeFreqScale = 0.0;

  /// YaRN extrapolation mix factor, negative = from model
  double yarnExtFactor = -1.0;

  /// YaRN magnitude scaling factor
  double yarnAttnFactor = 1.0;

  /// YaRN low correction dim
  double yarnBetaFast = 32.0;

  /// YaRN high correction dim
  double yarnBetaSlow = 1.0;

  /// YaRN original context size
  int yarnOrigCtx = 0;

  /// Defragment the KV cache if holes/size > thold, < 0 disabled
  double defragThold = -1.0;

  /// The llama_decode() call computes all logits, not just the last one
  bool logitsAll = false;

  /// If true, extract embeddings (together with logits)
  bool embeddings = false;

  /// Whether to offload the KQV ops (including the KV cache) to GPU
  bool offloadKqv = true;

  /// Whether to use flash attention [EXPERIMENTAL]
  bool flashAttn = false;

  /// whether to measure performance timings
  bool no_perf = false;

  llama_context_params get() {
    final contextParams = getDefaultContextParams();

    contextParams.n_ctx = n_ctx;
    contextParams.n_batch = n_batch;
    contextParams.n_ubatch = n_ubatch;
    contextParams.n_seq_max = n_seq_max;
    contextParams.n_threads = nThreads;
    contextParams.n_threads_batch = nThreadsBatch;
    contextParams.rope_freq_base = ropeFreqBase;
    contextParams.rope_freq_scale = ropeFreqScale;
    contextParams.yarn_ext_factor = yarnExtFactor;
    contextParams.yarn_attn_factor = yarnAttnFactor;
    contextParams.yarn_beta_fast = yarnBetaFast;
    contextParams.yarn_beta_slow = yarnBetaSlow;
    contextParams.yarn_orig_ctx = yarnOrigCtx;
    contextParams.defrag_thold = defragThold;
    contextParams.logits_all = logitsAll;
    contextParams.embeddings = embeddings;
    contextParams.offload_kqv = offloadKqv;
    contextParams.flash_attn = flashAttn;
    contextParams.no_perf = no_perf;

    return contextParams;
  }
}