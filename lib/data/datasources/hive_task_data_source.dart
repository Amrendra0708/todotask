import 'package:hive/hive.dart';

import '../../core/constants.dart';
import '../../domain/entities/task.dart';

class HiveTaskDataSource {
  final Box<Map> box;

  HiveTaskDataSource({required this.box});

  Future<List<Task>> readTasks() async {
    return box.values.map((e) => _fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> writeTasks(List<Task> tasks) async {
    await box.clear();
    for (final t in tasks) {
      await box.put(t.id, _toMap(t));
    }
  }

  Map<String, dynamic> _toMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'assigneeId': task.assigneeId,
      'deadline': task.deadline?.toIso8601String(),
      'priority': task.priority.index,
      'status': task.status.index,
    };
  }

  Task _fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      assigneeId: map['assigneeId'] as String?,
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline'] as String) : null,
      priority: TaskPriority.values[(map['priority'] as num?)?.toInt() ?? 1],
      status: TaskStatus.values[(map['status'] as num?)?.toInt() ?? 0],
    );
  }
}

