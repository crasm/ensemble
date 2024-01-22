import 'dart:io';

import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'package:ensemble_llamacpp/ensemble_llamacpp.dart';

// We can't use double.minPositive because that number gets rounded to zero when
// converted to Float32. We also can't actually use the min float value (for
// Temperature) because dividing by such a small number can still become Inf,
// leading to garbage output.
const tinyFloat = 5.35e-38;
const modelPath =
    '/Users/vczf/models/gguf-hf/TheBloke_Llama-2-7B-GGUF/llama-2-7b.Q2_K.gguf';

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

  group('model', () {
    test('model load cancel', () {
      try {
        LlamaCpp.loadModel(modelPath, progressCallback: (p) {
          return p > 0.50;
        });
      } on Exception catch (e) {
        expect(e, isException);
      }
    });
  });

  group('main', () {
    final model = LlamaCpp.loadModel(modelPath);

    test('tokenize', () {
      final ctx = model.newContext(Context.defaultParams..seed = 1);
      final tokens = ctx.add('peanut');
      expect(tokens.length, 4);
      expect(tokens[0].id, 1); // BOS
      expect(tokens[1].id, 1236);
      expect(tokens[2].id, 273);
      expect(tokens[3].id, 329);
    });

    test('happy path', () async {
      final ctx = model.newContext(
        Context.defaultParams
          ..seed = 1
          ..n_ctx = 19
          ..n_batch = 19,
      );
      ctx.add("It's the end of the world as we know it, and");
      await ctx.ingest();
      final tokStream = ctx.generate();
      final sbuf = StringBuffer();
      await for (final tok in tokStream) {
        sbuf.write(tok.text);
      }
      expect(sbuf.toString(), ' I feel fine.');
    });

    test('happy path batch size 1', () async {
      final ctx = model.newContext(
        Context.defaultParams
          ..seed = 1
          ..n_ctx = 19
          ..n_batch = 1,
      );
      ctx.add("It's the end of the world as we know it, and");
      await ctx.ingest();
      final tokStream = ctx.generate();
      final sbuf = StringBuffer();
      await for (final tok in tokStream) {
        sbuf.write(tok.text);
      }
      expect(sbuf.toString(), ' I feel fine.');
    });

    test('gen one token', () async {
      final ctx = model.newContext(
        Context.defaultParams
          ..seed = 1
          ..n_ctx = 2 // Need +1 for BOS token
          ..n_batch = 1,
      );

      ctx.add('');
      await ctx.ingest();
      final tokStream = ctx.generate();
      expect((await tokStream.single).text, ' hopefully');
    });

    test('repeat penalty', () async {
      final ctx = model.newContext(
        Context.defaultParams
          ..seed = 1
          ..n_ctx = 32
          ..n_batch = 32,
      );
      ctx.add('paint it black, paint it black, paint it black, paint it');
      await ctx.ingest();
      final tokStream = ctx.generate(samplers: const [
        RepetitionPenalty(lastN: 64, penalty: 2.0),
        Temperature(tinyFloat),
      ]);
      final tok = await tokStream.first;
      expect(tok.id, isNot(4628)); // '▁black'
      expect(tok.id, 13); // <0x0A> or '\n'
    });

    test('temperature non-greedy', () async {
      final ctx = model.newContext(
        Context.defaultParams
          ..seed = 1
          ..n_ctx = 10
          ..n_batch = 10,
      );
      ctx.add(' a a a a a a a');
      await ctx.ingest();
      final tokStream = ctx.generate(samplers: const [
        RepetitionPenalty(lastN: 64, penalty: 1.1),
        Temperature(tinyFloat),
      ]);
      await for (final tok in tokStream) {
        expect(tok.id, 263); // 263 = ▁a
      }
    });

    test('repeat penalty last N = -1', () async {
      final ctx = model.newContext(
        Context.defaultParams
          ..seed = 1
          ..n_ctx = 9
          ..n_batch = 9,
      );
      ctx.add('a a a a a a a');
      await ctx.ingest();
      final tokStream = ctx.generate(samplers: const [
        RepetitionPenalty(lastN: -1, penalty: 0.5),
        Temperature(tinyFloat),
      ]);
      await for (final tok in tokStream) {
        expect(tok.text, ' a'); // 263 = ▁a
      }
    });

    test('unused sampler', () async {
      final ctx = model.newContext(Context.defaultParams..seed = 1);
      const invalidSampler = TopK(40);
      try {
        ctx.add('Holly');
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

    // 0:     1 = <s>
    // 1:   739 = ▁It
    // 2: 29915 = '
    // 3: 29879 = s
    // 4:   278 = ▁the
    // 5:  1095 = ▁end
    // 6:   310 = ▁of
    // 7:   278 = ▁the
    // 8:  3186 = ▁world
    // 9:   408 = ▁as
    // 10:   591 = ▁we
    // 11:  1073 = ▁know
    // 12:   372 = ▁it
    // 13: 29892 = ,
    // 14:   322 = ▁and
    // 15:   306 = ▁I
    // 16:  4459 = ▁feel
    // 17:  2691 = ▁fine
    // 18: 29889 = .
    test('tokenize multiple add/ingest generate', () async {
      final ctx = model.newContext(
        Context.defaultParams
          ..seed = 1
          ..n_ctx = 19
          ..n_batch = 19,
      );
      stderr.writeln(ctx.add("It's the end"));
      await ctx.ingest();
      stderr.writeln(ctx.add(' of the world'));
      await ctx.ingest();
      stderr.writeln(ctx.add(' as we know it, and'));
      await ctx.ingest();

      final gen =
          await ctx.generate().map((a) => a.text).reduce((a, b) => a + b);
      expect(gen, ' I feel fine.');
    });

    test('complex interwoven ctls', () async {
      final ctx = model.newContext(Context.defaultParams..seed = 1);
      final tokens = <Token>[];
      tokens.addAll(ctx.add('Samanth'));
      await ctx.ingest();
      tokens.add(await ctx.generate().first);
      expect(tokens.last.text, 'a');

      tokens.addAll(ctx.add('stopped going fish'));
      await ctx.ingest();
      tokens.add(await ctx.generate().first);
      expect(tokens.last.text, 'ing');

      ctx.clear();
      tokens
        ..clear()
        ..addAll(ctx.add('peanut'));
      await ctx.ingest();
      final tokStream = ctx.generate();
      // [ _but ter ]
      await for (final tok in tokStream.take(2)) {
        tokens.add(tok);
      }
      expect(tokens.last.text, 'ter');

      // Check we can generate tokens using pre-computed logits without needing
      // to ingest again
      ctx.trim(tokens.length - 1);
      expect((await ctx.generate().first).text, 'ter');

      ctx.add('is my favorite thing to dip apple');
      await ctx.ingest();
      final nextTwoTokens = await ctx
          .generate()
          .take(2)
          .map((a) => a.text)
          .reduce((a, b) => a + b);
      expect(nextTwoTokens, ' slices');
    });

    test('logit bias map', () async {
      final ctx = model.newContext(Context.defaultParams..seed = 1);
      ctx.add('Four score');
      ctx.ingest();
      final tok = await ctx.generate(
        samplers: [
          LogitBias(const {322: double.negativeInfinity}),
        ],
      ).first;
      expect(tok.text, isNot(' and'));
    });
  });
}
