part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class CreateOrUpdateTask extends TaskEvent {
  final Task task;
  const CreateOrUpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class MoveTask extends TaskEvent {
  final String taskId;
  final TaskStatus newStatus;
  const MoveTask({required this.taskId, required this.newStatus});

  @override
  List<Object?> get props => [taskId, newStatus];
}

class ApplyFilter extends TaskEvent {
  final String? query;
  final String? assigneeId;
  final TaskPriority? priority;
  const ApplyFilter({this.query, this.assigneeId, this.priority});

  @override
  List<Object?> get props => [query, assigneeId, priority];
}

