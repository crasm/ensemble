import 'package:test/test.dart';

import 'package:ensemble_llama/llama.dart';

// We can't use double.minPositive because that number gets rounded to zero when
// converted to Float32. We also can't actually use the min float value (for
// Temperature) because dividing by such a small number can still become Inf,
// leading to garbage output.
const tinyFloat = 5.35e-38;

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
      ctx = await llama.newContext(model, params: ContextParams(seed: 1));
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
          params: ContextParams(
            seed: 1,
            contextSizeTokens: 19,
            batchSizeTokens: 19,
          ));
      final tokStream = llama.generate(
          ctx,
          "It's the end of the world as we know it, and");
      final sbuf = StringBuffer();
      await for (final tok in tokStream) {
        sbuf.write(tok);
      }
      expect(sbuf.toString(), " I feel fine.");
    });

    test('happy path batch size 1', () async {
      ctx = await llama.newContext(
          model,
          params: ContextParams(
            seed: 1,
            contextSizeTokens: 19,
            batchSizeTokens: 1,
          ));
      final tokStream = llama.generate(
          ctx,
          "It's the end of the world as we know it, and");
      final sbuf = StringBuffer();
      await for (final tok in tokStream) {
        sbuf.write(tok);
      }
      expect(sbuf.toString(), " I feel fine.");
    });

    test('gen one token', () async {
      ctx = await llama.newContext(
          model,
          params: ContextParams(
            seed: 1,
            contextSizeTokens: 2, // Need +1 for BOS token
            batchSizeTokens: 1,
          ));

      final tokStream =
          llama.generate(ctx, "");
      expect((await tokStream.single).toString(), " hopefully");
    });

    test('repeat penalty', () async {
      ctx = await llama.newContext(model,
          params: ContextParams(
              seed: 1, contextSizeTokens: 32, batchSizeTokens: 32));
      final tokStream = llama.generate(
          ctx,
          "paint it black, paint it black, paint it black, paint it",
          samplers: [
            RepetitionPenalty(lastN: 64, penalty: 2.0),
            Temperature(tinyFloat),
          ]);
      final tok = await tokStream.first;
      expect(tok.id, isNot(4628)); // "▁black"
      expect(tok.id, 13); // <0x0A> or "\n"
    });

    test('temperature non-greedy', () async {
      ctx = await llama.newContext(model,
          params: ContextParams(
              seed: 1, contextSizeTokens: 10, batchSizeTokens: 10));
      final tokStream = llama.generate(ctx, " a a a a a a a", samplers: [
        RepetitionPenalty(lastN: 64, penalty: 1.1),
        Temperature(tinyFloat),
      ]);
      await for (final tok in tokStream) {
        expect(tok, Token.fromId(ctx, 263)); // 263 = ▁a
      }
    });

    test('repeat penalty last N = -1', () async {
      ctx = await llama.newContext(model,
          params: ContextParams(
              seed: 1, contextSizeTokens: 9, batchSizeTokens: 9));
      final tokStream = llama.generate(
          ctx,
          "a a a a a a a",
          samplers: [
        RepetitionPenalty(lastN: -1, penalty: 1.0 + double.minPositive),
        Temperature(tinyFloat),
      ]);
      await for (final tok in tokStream) {
        expect(tok, Token.fromId(ctx, 263)); // 263 = ▁a
      }
    });
  });

  // TODO: write tests for sampling order
}
