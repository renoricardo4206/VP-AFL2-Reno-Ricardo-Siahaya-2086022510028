import '../../domain/entities/task.dart';
import '../../domain/failures/task_failure.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import '../services/task_local_service.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalService _service;

  TaskRepositoryImpl(this._service);

  @override
  Future<List<Task>> getTasks() async {
    try {
      final models = await _service.getTasks();
      return List<Task>.of(models);
    } catch (_) {
      throw const TaskFailure('Gagal memuat tugas. Coba lagi.');
    }
  }

  @override
  Future<void> addTask(Task task) {
    return _modify(
      (tasks) => tasks.add(TaskModel.fromEntity(task)),
      'Gagal menambahkan tugas. Coba lagi.',
    );
  }

  @override
  Future<void> updateTask(Task task) {
    return _modify(
      (tasks) {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) tasks[index] = TaskModel.fromEntity(task);
      },
      'Gagal menyimpan perubahan. Coba lagi.',
    );
  }

  @override
  Future<void> deleteTask(String id) {
    return _modify(
      (tasks) => tasks.removeWhere((t) => t.id == id),
      'Gagal menghapus tugas. Coba lagi.',
    );
  }

  Future<void> _modify(
    void Function(List<TaskModel> tasks) change,
    String errorMessage,
  ) async {
    try {
      final tasks = await _service.getTasks();
      change(tasks);
      await _service.saveTasks(tasks);
    } catch (_) {
      throw TaskFailure(errorMessage);
    }
  }
}