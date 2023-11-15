import 'package:test/test.dart';

import 'package:ensemble_llama/llama.dart';

void main() {
  group('main', () {
    late Llama llama;
    late Model model;
    late Context ctx;
    setUp(() async {
      llama = await Llama.create();
      model = await llama.loadModel(
          "/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf",
          params: ModelParams(gpuLayers: 1));
    });
    tearDown(() async {
      await llama.freeContext(ctx);
      await llama.freeModel(model);
      llama.dispose();
    });

    test('tokenize', () async {
      ctx = await llama.newContext(model, ContextParams(seed: 1));
      final tokens = await llama.tokenize(ctx, "peanut");
      expect(tokens.length, 4);
      expect(tokens[0].id, 1); // BOS
      expect(tokens[1].id, 1236);
      expect(tokens[2].id, 273);
      expect(tokens[3].id, 329);
    });

    test('happy path', () async {
      ctx = await llama.newContext(
          model,
          ContextParams(
            seed: 1,
            contextSizeTokens: 19,
            batchSizeTokens: 19,
          ));
      final tokStream = llama.generate(
          ctx,
          "It's the end of the world as we know it, and",
          SamplingParams(temperature: 0.0));
      final sbuf = StringBuffer();
      await for (final tok in tokStream) {
        sbuf.write(tok);
      }
      expect(sbuf.toString(), " I feel fine.");
    });

    test('happy path batch size 1', () async {
      ctx = await llama.newContext(
          model,
          ContextParams(
            seed: 1,
            contextSizeTokens: 19,
            batchSizeTokens: 1,
          ));
      final tokStream = llama.generate(
          ctx,
          "It's the end of the world as we know it, and",
          SamplingParams(temperature: 0.0));
      final sbuf = StringBuffer();
      await for (final tok in tokStream) {
        sbuf.write(tok);
      }
      expect(sbuf.toString(), " I feel fine.");
    });

    test('gen one token', () async {
      ctx = await llama.newContext(
          model,
          ContextParams(
            seed: 1,
            contextSizeTokens: 2, // Need +1 for BOS token
            batchSizeTokens: 1,
          ));

      final tokStream =
          llama.generate(ctx, "", SamplingParams(temperature: 0.0));
      expect((await tokStream.single).toString(), " hopefully");
    });

    test('repeat penalty', () async {
      ctx = await llama.newContext(model,
          ContextParams(seed: 1, contextSizeTokens: 32, batchSizeTokens: 32));
      final tokStream = llama.generate(
          ctx,
          "paint it black, paint it black, paint it black, paint it",
          SamplingParams(
            topK: 0,
            topP: 1.0,
            temperature: double.minPositive,
            repeatPenalty: 2.0,
          ));
      final tok = await tokStream.first;
      expect(tok.id, isNot(4628)); // "▁black"
      expect(tok.id, 13); // <0x0A> or "\n"
    });

    test('repeat penalty last N = -1', () async {
      ctx = await llama.newContext(model,
          ContextParams(seed: 1, contextSizeTokens: 32, batchSizeTokens: 32));
      final tokStream = llama.generate(
          ctx,
          " a a a a a a a",
          SamplingParams(
            topK: 0,
            topP: 1.0,
            temperature: double.minPositive,
            repeatPenalty: 1.0 + double.minPositive,
            repeatPenaltyLastN: -1,
          ));
      await for (final tok in tokStream) {
        expect(tok.id, 263); // 263 = ▁a
      }
    });
  });
}
