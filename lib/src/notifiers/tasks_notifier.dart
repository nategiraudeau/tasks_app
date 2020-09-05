import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/src/tasks.dart';
import 'package:uuid/uuid.dart';

class TaskNotifier with ChangeNotifier {
  List<Task> _tasks = [];

  String _selected;

  void selectTask(String id) {
    _selected = id;
    notifyListeners();
  }

  void unselect() {
    _selected = null;
    notifyListeners();
  }

  void deleteSelected() {
    if (_selected == null) return;

    _tasks.removeWhere((task) => task.id == _selected);

    notifyListeners();
  }

  void renameTask(String name, {@required String taskId}) {
    final index = _tasks.indexWhere((task) => task.id == taskId);

    final currentTask = _tasks[index];

    final newTask = Task.rename(
      currentTask,
      name,
    );

    _tasks[index] = newTask;

    notifyListeners();
  }

  List<Task> get tasks => _tasks;

  String get selectedId => _selected;

  Task get selected {
    return _tasks.firstWhere((task) => task.id == _selected);
  }

  List<Task> fromCategory(TaskCategory category) =>
      _tasks.where((task) => task.category == category).toList();

  List<Task> get complete => fromCategory(TaskCategory.complete);
  List<Task> get inProgress => fromCategory(TaskCategory.inProgress);
  List<Task> get incomplete => fromCategory(TaskCategory.incomplete);

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void setTaskCategory(String id, TaskCategory category) {
    if (id == null || category == null) return;

    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index]..category = category;
      notifyListeners();
    }
  }

  static TaskNotifier of(BuildContext context, {bool listen = true}) {
    if (context == null) return null;

    return Provider.of<TaskNotifier>(context, listen: listen);
  }
}

class Task {
  static final _uuid = Uuid();

  String name;
  TaskCategory category;
  String id;

  Task.rename(Task task, this.name) {
    this.id = task.id;
    this.category = task.category;
  }

  Task({this.name, this.category = TaskCategory.incomplete}) {
    this.id = _uuid.v1();
  }
}
