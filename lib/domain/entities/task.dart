import 'package:equatable/equatable.dart';
import '../../core/constants.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? assigneeId;
  final DateTime? deadline;
  final TaskPriority priority;
  final TaskStatus status;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.assigneeId,
    this.deadline,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? assigneeId,
    DateTime? deadline,
    TaskPriority? priority,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeId: assigneeId ?? this.assigneeId,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, title, description, assigneeId, deadline, priority, status];
}


