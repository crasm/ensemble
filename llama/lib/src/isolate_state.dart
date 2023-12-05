import 'package:ensemble_llama/src/isolate_models.dart';
import 'package:ensemble_llama/src/llama.dart' as pub;
import 'package:ensemble_llama/src/params.dart';

State get state => State._singleton;

final class State {
  final Map<pub.Model, Model> models = {};
  final Map<pub.Context, Context> contexts = {};
  final Map<pub.Model, Set<pub.Context>> contextsForModel = {};

  static final State _singleton = State._();
  State._();

  pub.Model addModel(int rawModel) {
    final model = Model(rawModel);
    models[model.id] = model;
    return model.id;
  }

  pub.Context addContext(int rawCtx, Model model, ContextParams params) {
    final ctx = Context(rawCtx, model, params);
    contexts[ctx.id] = ctx;

    contextsForModel[model.id] ??= {};
    contextsForModel[model.id]!.add(ctx.id);
    return ctx.id;
  }

  Model removeModel(pub.Model id) =>
      models.remove(id) ?? (throw ArgumentError.value(id, "not found"));

  Context removeContext(pub.Context id) =>
      contexts.remove(id) ?? (throw ArgumentError.value(id, "not found"));

  Model getModel(pub.Model id) => models[id] ?? (throw ArgumentError.value(id, "not found"));

  Context getContext(pub.Context id) =>
      contexts[id] ?? (throw ArgumentError.value(id, "not found"));
}
