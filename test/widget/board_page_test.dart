import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:task_management_app/presentation/pages/board_page.dart';
import 'package:task_management_app/presentation/bloc/task_bloc.dart';
import 'package:task_management_app/domain/entities/task.dart';
import 'package:task_management_app/core/constants.dart';
import 'package:task_management_app/domain/repositories/task_repository.dart';

class _FakeRepo implements TaskRepository {
  List<Task> memory = [];
  @override
  Future<List<Task>> getTasks() async => memory;
  @override
  Future<void> saveTasks(List<Task> tasks) async => memory = tasks;
}

void main() {
  testWidgets('Board shows three columns and can add a task', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1200, 900);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    final repo = _FakeRepo();
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider(
        create: (_) => TaskBloc(repository: repo),
        child: const BoardPage(),
      ),
    ));

    expect(find.text('To Do'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Open dialog via Add FAB (use heroTag)
    await tester.tap(find.byTooltip('Add Task'));
    await tester.pumpAndSettle();
    expect(find.text('Create Task'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'New Task');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);
  });
}

