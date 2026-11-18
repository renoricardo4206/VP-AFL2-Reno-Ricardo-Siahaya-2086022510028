import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

class TaskLocalService {
  static const _key = 'tasks';

  final SharedPreferences _prefs;

  TaskLocalService(this._prefs);

  Future<List<TaskModel>> getTasks() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(_key, raw);
  }
}