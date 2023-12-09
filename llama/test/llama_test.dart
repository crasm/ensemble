import 'dart:io';

import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'package:ensemble_llama/llama.dart';

// We can't use double.minPositive because that number gets rounded to zero when
// converted to Float32. We also can't actually use the min float value (for
// Temperature) because dividing by such a small number can still become Inf,
// leading to garbage output.
const tinyFloat = 5.35e-38;

void main() {
  final startTime = DateTime.now();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((e) {
    final diff = e.time.difference(startTime);
    stderr.writeln(
      '${e.level.name.padRight(7)}: '
      '${diff.inMilliseconds.toString().padLeft(6, '0')}: '
      '${e.message}',
    );
  });

  group('main', () {
    final llama = Llama();
    // ignore: discarded_futures
    final model = llama.initModel(
        '/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf',
        params: ModelParams(gpuLayers: 1));
    Context ctx;

    test('tokenize', () async {
      ctx = await llama.initContext(await model, params: ContextParams(seed: 1));
      final tokens = await ctx.add('peanut');
      expect(tokens.length, 4);
      expect(tokens[0].id, 1); // BOS
      expect(tokens[1].id, 1236);
      expect(tokens[2].id, 273);
      expect(tokens[3].id, 329);
    });

    test('happy path', () async {
      ctx = await llama.initContext(
        await model,
        params: ContextParams(
          seed: 1,
          contextSizeTokens: 19,
          batchSizeTokens: 19,
        ),
      );
      await ctx.add("It's the end of the world as we know it, and");
      await ctx.ingest();
      final tokStream = ctx.generate();
      final sbuf = StringBuffer();
      await for (final tok in tokStream) {
        sbuf.write(tok.text);
      }
      expect(sbuf.toString(), ' I feel fine.');
    });

    test('happy path batch size 1', () async {
      ctx = await llama.initContext(
        await model,
        params: ContextParams(
          seed: 1,
          contextSizeTokens: 19,
          batchSizeTokens: 1,
        ),
      );
      await ctx.add("It's the end of the world as we know it, and");
      await ctx.ingest();
      final tokStream = ctx.generate();
      final sbuf = StringBuffer();
      await for (final tok in tokStream) {
        sbuf.write(tok.text);
      }
      expect(sbuf.toString(), ' I feel fine.');
    });

    test('gen one token', () async {
      ctx = await llama.initContext(
        await model,
        params: ContextParams(
          seed: 1,
          contextSizeTokens: 2, // Need +1 for BOS token
          batchSizeTokens: 1,
        ),
      );

      await ctx.add('');
      await ctx.ingest();
      final tokStream = ctx.generate();
      expect((await tokStream.single).text, ' hopefully');
    });

    test('repeat penalty', () async {
      ctx = await llama.initContext(await model,
          params: ContextParams(seed: 1, contextSizeTokens: 32, batchSizeTokens: 32));
      await ctx.add('paint it black, paint it black, paint it black, paint it');
      await ctx.ingest();
      final tokStream = ctx.generate(samplers: [
        const RepetitionPenalty(lastN: 64, penalty: 2.0),
        const Temperature(tinyFloat),
      ]);
      final tok = await tokStream.first;
      expect(tok.id, isNot(4628)); // '▁black'
      expect(tok.id, 13); // <0x0A> or '\n'
    });

    test('temperature non-greedy', () async {
      ctx = await llama.initContext(await model,
          params: ContextParams(seed: 1, contextSizeTokens: 10, batchSizeTokens: 10));
      await ctx.add(' a a a a a a a');
      await ctx.ingest();
      final tokStream = ctx.generate(samplers: [
        const RepetitionPenalty(lastN: 64, penalty: 1.1),
        const Temperature(tinyFloat),
      ]);
      await for (final tok in tokStream) {
        expect(tok.id, 263); // 263 = ▁a
      }
    });

    test('repeat penalty last N = -1', () async {
      ctx = await llama.initContext(await model,
          params: ContextParams(seed: 1, contextSizeTokens: 9, batchSizeTokens: 9));
      await ctx.add('a a a a a a a');
      await ctx.ingest();
      final tokStream = ctx.generate(samplers: [
        const RepetitionPenalty(lastN: -1, penalty: 1.0 + tinyFloat),
        const Temperature(tinyFloat),
      ]);
      await for (final tok in tokStream) {
        expect(tok.id, 263); // 263 = ▁a
      }
    });

    test('unused sampler', () async {
      ctx = await llama.initContext(await model, params: ContextParams(seed: 1));
      const invalidSampler = TopK(40);
      try {
        await ctx.add('Holly');
        await ctx.ingest();
        await ctx.generate(samplers: [
          const Temperature(0.0),
          invalidSampler,
        ]).first;
        // ignore: avoid_catching_errors
      } on ArgumentError catch (e) {
        final samp = (e.invalidValue as List<Sampler>).first as TopK;
        expect(samp.topK, equals(invalidSampler.topK));
        return;
      }

      assert(false, 'no error thrown');
    });

    test('tokenize multiple add/ingest generate', () async {
      ctx = await llama.initContext(await model,
          params: ContextParams(
            seed: 1,
            contextSizeTokens: 19,
            batchSizeTokens: 19,
          ));
      await ctx.add("It's the end");
      await ctx.ingest();
      // NOTE: need to drop leading space oddly enough
      await ctx.add('of the world');
      await ctx.ingest();
      await ctx.add('as we know it, and');
      await ctx.ingest();

      final gen = await ctx.generate().map((a) => a.text).reduce((a, b) => a + b);
      expect(gen, ' I feel fine.');
    });

    test('complex interwoven ctls', () async {
      ctx = await llama.initContext(
        await model,
        params: ContextParams(seed: 1),
      );
      final tokens = <Token>[];
      tokens.addAll(await ctx.add('Samanth'));
      await ctx.ingest();
      tokens.add(await ctx.generate().first);
      expect(tokens.last.text, 'a');

      tokens.addAll(await ctx.add('stopped going fish'));
      await ctx.ingest();
      tokens.add(await ctx.generate().first);
      expect(tokens.last.text, 'ing');

      await ctx.clear();
      tokens
        ..clear()
        ..addAll(await ctx.add('peanut'));
      await ctx.ingest();
      final tokStream = ctx.generate();
      // [ _but ter ]
      await for (final tok in tokStream.take(2)) {
        tokens.add(tok);
      }
      expect(tokens.last.text, 'ter');

      // Check we can generate tokens using pre-computed logits without needing
      // to ingest again
      await ctx.trim(tokens.length - 1);
      expect((await ctx.generate().first).text, 'ter');

      await ctx.add('is my favorite thing to dip apple');
      await ctx.ingest();
      final nextTwoTokens = await ctx.generate().take(2).map((a) => a.text).reduce((a, b) => a + b);
      expect(nextTwoTokens, ' slices');
    });
  });
}
