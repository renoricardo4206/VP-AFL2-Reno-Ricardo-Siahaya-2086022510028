import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart';
import '../../viewmodel/task_list_viewmodel.dart';

class TaskListView extends StatelessWidget {
  final List<Task> tasks;

  const TaskListView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TaskListViewModel>();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          leading: Checkbox(
            value: task.isDone,
            onChanged: (_) => viewModel.toggleTask(task),
          ),
          title: Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: task.isDone
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus tugas',
            onPressed: () => viewModel.deleteTask(task.id),
          ),
          onTap: () => viewModel.toggleTask(task),
        );
      },
    );
  }
}