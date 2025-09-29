import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  final Uuid uuid = const Uuid();

  TaskBloc({required this.repository}) : super(const TaskState.initial()) {
    on<LoadTasks>(_onLoad);
    on<CreateOrUpdateTask>(_onCreateOrUpdate);
    on<DeleteTask>(_onDelete);
    on<MoveTask>(_onMove);
    on<ApplyFilter>(_onFilter);
  }

  Future<void> _onLoad(LoadTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(isLoading: true));
    final tasks = await repository.getTasks();
    emit(state.copyWith(isLoading: false, tasks: tasks));
  }

  Future<void> _onCreateOrUpdate(CreateOrUpdateTask event, Emitter<TaskState> emit) async {
    final List<Task> updated = List<Task>.from(state.tasks);
    final int idx = updated.indexWhere((t) => t.id == event.task.id);
    if (idx == -1) {
      updated.add(event.task.id.isEmpty ? event.task.copyWith(id: uuid.v4()) : event.task);
    } else {
      updated[idx] = event.task;
    }
    await repository.saveTasks(updated);
    emit(state.copyWith(tasks: updated));
  }

  Future<void> _onDelete(DeleteTask event, Emitter<TaskState> emit) async {
    final updated = state.tasks.where((t) => t.id != event.taskId).toList();
    await repository.saveTasks(updated);
    emit(state.copyWith(tasks: updated));
  }

  Future<void> _onMove(MoveTask event, Emitter<TaskState> emit) async {
    final updated = state.tasks.map((t) {
      if (t.id == event.taskId) {
        return t.copyWith(status: event.newStatus);
      }
      return t;
    }).toList();
    await repository.saveTasks(updated);
    emit(state.copyWith(tasks: updated));
  }

  void _onFilter(ApplyFilter event, Emitter<TaskState> emit) {
    emit(state.copyWith(
      query: event.query,
      assigneeId: event.assigneeId,
      priority: event.priority,
    ));
  }
}

