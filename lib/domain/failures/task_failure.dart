class TaskFailure implements Exception {
  final String message;

  const TaskFailure(this.message);
}