import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/message_view.dart';
import 'widgets/task_list_view.dart';
import 'widgets/add_task_dialog.dart';
import '../viewmodel/task_list_viewmodel.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskListViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tugas')),
      body: SafeArea(child: _buildBody(viewModel)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: 'Tambah tugas',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TaskListViewModel viewModel) {
    return switch (viewModel.state) {
      TaskListInitial() || TaskListLoading() =>
        const Center(child: CircularProgressIndicator()),
      TaskListEmpty() => const MessageView(
          icon: Icons.checklist,
          message: 'Belum ada tugas. Ketuk tombol + untuk menambahkan.',
        ),
      TaskListLoaded(:final tasks) => TaskListView(tasks: tasks),
      TaskListError(:final message) => MessageView(
          icon: Icons.error_outline,
          message: message,
          actionLabel: 'Coba lagi',
          onAction: viewModel.loadTasks,
        ),
    };
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final viewModel = context.read<TaskListViewModel>();
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const AddTaskDialog(),
    );
    if (title != null) {
      await viewModel.addTask(title);
    }
  }
}
