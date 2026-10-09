import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'folders_screen.dart';
import 'repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  await dbHelper.init();

  final repository = Repository(dbHelper);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final Repository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fall Festival Card Catalogue',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FoldersScreen(repository: repository),
    );
  }
}
