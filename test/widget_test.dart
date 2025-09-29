// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_management_app/presentation/pages/board_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management_app/presentation/bloc/task_bloc.dart';
import 'package:task_management_app/domain/repositories/task_repository.dart';
import 'package:task_management_app/domain/entities/task.dart';

class _FakeRepo implements TaskRepository {
  List<Task> memory = [];
  @override
  Future<List<Task>> getTasks() async => memory;
  @override
  Future<void> saveTasks(List<Task> tasks) async => memory = tasks;
}

void main() {
  testWidgets('Board renders and add task works', (WidgetTester tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider(create: (_) => TaskBloc(repository: repo), child: const BoardPage()),
    ));

    expect(find.text('To Do'), findsOneWidget);
    await tester.tap(find.byTooltip('Add Task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Test Task');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Test Task'), findsOneWidget);
  });
}
