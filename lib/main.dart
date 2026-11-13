import 'package:flutter/material.dart';

import 'app.dart';

void main(List<String> arguments) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GitGuiExpandApp(
      initialRepositoryPath: arguments.isEmpty ? null : arguments.first,
    ),
  );
}
