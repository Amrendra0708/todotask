import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/hive_task_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final HiveTaskDataSource local;

  TaskRepositoryImpl({required this.local});

  @override
  Future<List<Task>> getTasks() => local.readTasks();

  @override
  Future<void> saveTasks(List<Task> tasks) => local.writeTasks(tasks);
}

