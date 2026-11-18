import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../domain/entities/task.dart';
import '../domain/failures/task_failure.dart';
import '../domain/repositories/task_repository.dart';

sealed class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

class TaskListInitial extends TaskListState {
  const TaskListInitial();
}

class TaskListLoading extends TaskListState {
  const TaskListLoading();
}

class TaskListEmpty extends TaskListState {
  const TaskListEmpty();
}

class TaskListLoaded extends TaskListState {
  final List<Task> tasks;

  const TaskListLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskListError extends TaskListState {
  final String message;

  const TaskListError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskListViewModel extends ChangeNotifier {
  final TaskRepository _repository;

  TaskListViewModel(this._repository);

  TaskListState _state = const TaskListInitial();
  TaskListState get state => _state;

  bool _disposed = false;

  Future<void> loadTasks() async {
    _emit(const TaskListLoading());
    await _fetch();
  }

  Future<void> addTask(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: trimmed,
    );
    await _run(() => _repository.addTask(task));
  }

  Future<void> toggleTask(Task task) {
    return _run(
      () => _repository.updateTask(task.copyWith(isDone: !task.isDone)),
    );
  }

  Future<void> deleteTask(String id) {
    return _run(() => _repository.deleteTask(id));
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on TaskFailure catch (e) {
      _emit(TaskListError(e.message));
      return;
    }
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final tasks = await _repository.getTasks();
      _emit(tasks.isEmpty ? const TaskListEmpty() : TaskListLoaded(tasks));
    } on TaskFailure catch (e) {
      _emit(TaskListError(e.message));
    }
  }

  void _emit(TaskListState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}