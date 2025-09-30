part of 'task_bloc.dart';

class TaskState extends Equatable {
  final bool isLoading;
  final List<Task> tasks;
  final String? query;
  final String? assigneeId;
  final TaskPriority? priority;

  const TaskState({
    required this.isLoading,
    required this.tasks,
    this.query,
    this.assigneeId,
    this.priority,
  });

  const TaskState.initial()
      : isLoading = false,
        tasks = const [],
        query = null,
        assigneeId = null,
        priority = null;

  TaskState copyWith({
    bool? isLoading,
    List<Task>? tasks,
    String? query,
    String? assigneeId,
    TaskPriority? priority,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      query: query ?? this.query,
      assigneeId: assigneeId ?? this.assigneeId,
      priority: priority ?? this.priority,
    );
  }

  List<Task> get filteredTasks {
    return tasks.where((t) {
      final bool matchesQuery = (query == null || query!.isEmpty)
          ? true
          : t.title.toLowerCase().contains(query!.toLowerCase());
      final bool matchesAssignee = assigneeId == null || assigneeId!.isEmpty
          ? true
          : t.assigneeId == assigneeId;
      final bool matchesPriority = priority == null ? true : t.priority == priority;
      return matchesQuery && matchesAssignee && matchesPriority;
    }).toList();
  }

  @override
  List<Object?> get props => [isLoading, tasks, query, assigneeId, priority];
}


