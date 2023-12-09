import 'package:ensemble_llama/src/isolate_models.dart';
import 'package:ensemble_llama/src/params.dart';

State get state => State._singleton;

final class State {
  final Map<int, Model> models = {}; // modelId => Model
  final Map<int, Context> contexts = {}; // ctxId => Context
  final Map<int, Set<int>> contextsForModel = {}; // modelId => { ctxId, ctxId, ... }

  static final State _singleton = State._();
  State._();

  int addModel(int rawModel) {
    final model = Model(rawModel);
    models[model.id] = model;
    return model.id;
  }

  int addContext(int rawCtx, Model model, ContextParams params) {
    final ctx = Context(rawCtx, model, params);
    contexts[ctx.id] = ctx;

    contextsForModel[model.id] ??= {};
    contextsForModel[model.id]!.add(ctx.id);
    return ctx.id;
  }

  Model removeModel(int model) =>
      models.remove(model) ?? (throw ArgumentError('Model#$model not found'));

  Context removeContext(int ctx) =>
      contexts.remove(ctx) ?? (throw ArgumentError('Context#$ctx not found'));

  Model getModel(int model) => models[model] ?? (throw ArgumentError('Model#$model not found'));

  Context getContext(int ctx) => contexts[ctx] ?? (throw ArgumentError('Context#$ctx not found'));
}
