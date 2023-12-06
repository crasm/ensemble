import 'package:ensemble_llama/src/isolate_models.dart';
import 'package:ensemble_llama/src/llama.dart' as pub;
import 'package:ensemble_llama/src/params.dart';

State get state => State._singleton;

final class State {
  final Map<int, Model> models = {}; // modelId => Model
  final Map<int, Context> contexts = {}; // ctxId => Context
  final Map<int, Set<int>> contextsForModel = {}; // modelId => { ctxId, ctxId, ... }

  static final State _singleton = State._();
  State._();

  pub.Model addModel(int rawModel) {
    final model = Model(rawModel);
    models[model.id] = model;
    return pub.Model(model.id);
  }

  pub.Context addContext(int rawCtx, Model model, ContextParams params) {
    final ctx = Context(rawCtx, model, params);
    contexts[ctx.id] = ctx;

    contextsForModel[model.id] ??= {};
    contextsForModel[model.id]!.add(ctx.id);
    return pub.Context(ctx.id);
  }

  Model removeModel(pub.Model model) =>
      models.remove(model.id) ?? (throw ArgumentError.value(model, "not found"));

  Context removeContext(pub.Context ctx) =>
      contexts.remove(ctx.id) ?? (throw ArgumentError.value(ctx, "not found"));

  Model getModel(pub.Model model) =>
      models[model.id] ?? (throw ArgumentError.value(model, "not found"));

  Context getContext(pub.Context ctx) =>
      contexts[ctx.id] ?? (throw ArgumentError.value(ctx, "not found"));
}
