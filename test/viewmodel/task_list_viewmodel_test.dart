import 'package:flutter_test/flutter_test.dart';
import 'package:task_list/domain/entities/task.dart';
import 'package:task_list/domain/failures/task_failure.dart';
import 'package:task_list/domain/repositories/task_repository.dart';
import 'package:task_list/viewmodel/task_list_viewmodel.dart';

class FakeTaskRepository implements TaskRepository {
  List<Task> tasks;
  TaskFailure? failure;
  final Duration delay;

  FakeTaskRepository({
    this.tasks = const [],
    this.failure,
    this.delay = Duration.zero,
  });

  @override
  Future<List<Task>> getTasks() async {
    await Future<void>.delayed(delay);
    if (failure != null) throw failure!;
    return List<Task>.of(tasks);
  }

  @override
  Future<void> addTask(Task task) async {
    if (failure != null) throw failure!;
    tasks = [...tasks, task];
  }

  @override
  Future<void> updateTask(Task task) async {
    if (failure != null) throw failure!;
    tasks = [for (final t in tasks) t.id == task.id ? task : t];
  }

  @override
  Future<void> deleteTask(String id) async {
    if (failure != null) throw failure!;
    tasks = tasks.where((t) => t.id != id).toList();
  }
}

void main() {
  const task = Task(id: '1', title: 'Belajar Flutter');

  test('loadTasks menghasilkan Loaded saat ada data', () async {
    final viewModel = TaskListViewModel(FakeTaskRepository(tasks: [task]));

    await viewModel.loadTasks();

    expect(viewModel.state, const TaskListLoaded([task]));
  });

  test('loadTasks menghasilkan Empty saat tidak ada data', () async {
    final viewModel = TaskListViewModel(FakeTaskRepository());

    await viewModel.loadTasks();

    expect(viewModel.state, const TaskListEmpty());
  });

  test('loadTasks menghasilkan Error dengan pesan untuk pengguna', () async {
    final viewModel = TaskListViewModel(
      FakeTaskRepository(
        failure: const TaskFailure('Gagal memuat tugas. Coba lagi.'),
      ),
    );

    await viewModel.loadTasks();

    expect(
      viewModel.state,
      const TaskListError('Gagal memuat tugas. Coba lagi.'),
    );
  });

  test('addTask menyimpan tugas dengan judul yang sudah dirapikan', () async {
    final viewModel = TaskListViewModel(FakeTaskRepository());

    await viewModel.addTask('  Tugas baru  ');

    final state = viewModel.state;
    expect(state, isA<TaskListLoaded>());
    expect((state as TaskListLoaded).tasks.single.title, 'Tugas baru');
  });

  test('addTask dengan judul kosong tidak mengubah apa pun', () async {
    final repository = FakeTaskRepository();
    final viewModel = TaskListViewModel(repository);

    await viewModel.addTask('   ');

    expect(repository.tasks, isEmpty);
    expect(viewModel.state, const TaskListInitial());
  });

  test('tidak melempar error jika di-dispose saat sedang memuat', () async {
    final viewModel = TaskListViewModel(
      FakeTaskRepository(
        tasks: [task],
        delay: const Duration(milliseconds: 50),
      ),
    );

    final loading = viewModel.loadTasks();
    viewModel.dispose();

    await loading;
  });
}