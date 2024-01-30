import 'package:flutter/material.dart';

extension WithSetState on State {
  VoidCallback withSetState(VoidCallback cb) {
    return () {
      cb();
      setState(() {}); // ignore: invalid_use_of_protected_member
    };
  }
}

extension GetColorBuildContext on BuildContext {
  ColorScheme get color => Theme.of(this).colorScheme;
}
