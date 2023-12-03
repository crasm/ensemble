import 'package:ensemble_llama/src/isolate_models.dart';
import 'package:ensemble_llama/src/llama.dart' as pub;
import 'package:ensemble_llama/src/params.dart';

State get state => State._singleton;

final class State {
  pub.Model _nextModel = 1;
  pub.Context _nextContext = 1;

  final Map<pub.Model, Model> models = {};
  final Map<pub.Context, Context> contexts = {};
  final Map<pub.Model, Set<pub.Context>> contextsForModel = {};

  static final State _singleton = State._();
  State._();

  pub.Model addModel(int rawModel) {
    final id = _nextModel++;
    models[id] = Model(id, rawModel);
    return id;
  }

  pub.Context addContext(int rawCtx, Model model, ContextParams params) {
    final id = _nextContext++;
    contexts[id] = Context(id, rawCtx, model, params);

    contextsForModel[model.id] ??= {};
    contextsForModel[model.id]!.add(id);
    return id;
  }

  Model removeModel(pub.Model id) =>
      models.remove(id) ?? (throw ArgumentError.value(id, "not found"));

  Context removeContext(pub.Context id) =>
      contexts.remove(id) ?? (throw ArgumentError.value(id, "not found"));

  Model getModel(pub.Model id) =>
      models[id] ?? (throw ArgumentError.value(id, "not found"));

  Context getContext(pub.Context id) =>
      contexts[id] ?? (throw ArgumentError.value(id, "not found"));
}
