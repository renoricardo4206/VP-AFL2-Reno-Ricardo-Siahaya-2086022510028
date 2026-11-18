import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/task_repository_impl.dart';
import '../../data/services/task_local_service.dart';
import '../../domain/repositories/task_repository.dart';

Future<TaskRepository> createTaskRepository() async {
  final prefs = await SharedPreferences.getInstance();
  return TaskRepositoryImpl(TaskLocalService(prefs));
}