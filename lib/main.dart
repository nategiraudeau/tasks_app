import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tasks_app/src/tasks_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(TasksApp());
}
