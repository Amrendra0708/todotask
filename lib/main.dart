import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/datasources/hive_task_data_source.dart';
import 'data/repositories/task_repository_impl.dart';
import 'presentation/bloc/task_bloc.dart';
import 'presentation/pages/board_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initHive(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }
        final Box<Map> box = snapshot.data as Box<Map>;
        final repo = TaskRepositoryImpl(local: HiveTaskDataSource(box: box));
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => TaskBloc(repository: repo)..add(const LoadTasks())),
          ],
          child: MaterialApp(
            title: 'Task Management',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF7F8FA),
              appBarTheme: const AppBarTheme(
                centerTitle: false,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            home: const BoardPage(),
          ),
        );
      },
    );
  }

  Future<Box<Map>> _initHive() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<Map>('${AppTitle}_tasks');
    return box;
  }
}
