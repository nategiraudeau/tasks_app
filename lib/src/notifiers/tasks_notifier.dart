import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasks_app/src/database/task.dart';
import 'package:tasks_app/src/database/tasks_database.dart';
import 'package:tasks_app/src/tasks.dart';

class TaskNotifier with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _previousTasks = [];

  final _prefs = SharedPreferences.getInstance();

  bool _isDark = false;

  bool get isDark => _isDark;

  Future<void> toggleIsDark([bool isDark]) async {
    _isDark = isDark ?? !_isDark;
    notifyListeners();

    _prefs.then((prefs) => prefs.setBool('isDark', _isDark));

    await Future.delayed(Duration(milliseconds: _isDark ? 400 : 300));

    try {
      FlutterStatusbarcolor.setStatusBarColor(Colors.transparent,
          animate: true);

      if (_isDark) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      } else {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      }
    } catch (e) {
      print(e);
    }
  }

  Timer _dbTimer;

  /// The list of task ids that have been changed. It is a
  /// [Set] so that the database is not updated twice for
  /// something that should have only required the database
  /// to update once.
  Set<String> _changedTasks = Set();

  /// The list of task ids that have been created. It is a
  /// [Set] just to be safe.
  Set<String> _newTasks = Set();

  /// The list of task ids that have been removed. It is a
  /// [Set] just to be safe.
  Set<String> _removedTasks = Set();

  static final _db = TasksDatabase.instance;

  /// Creates a new [TaskNotifier]
  TaskNotifier() {
    init();
  }

  var _ready = false;

  bool get ready => _ready;

  Future<void> init() async {
    final loadedTasks = await _db.loadTasks();

    _tasks = loadedTasks ?? _tasks;

    // Insures that the previous tasks are not linked to the real tasks
    _previousTasks = loadedTasks
            ?.map(
              (task) => Task(
                category: task.category,
                name: task.name,
              )
                ..id = task.id
                ..isSnapshot = true,
            )
            ?.toList() ??
        [];

    final duration = const Duration(milliseconds: 1500);
    _dbTimer = Timer.periodic(duration, (_) => _syncWithDatabase());

    final prefs = await _prefs;

    final _isDarkFromPrefs = prefs.getBool('isDark') ?? false;
    _isDark = _isDarkFromPrefs;

    notifyListeners();

    await Future.delayed(Duration(milliseconds: 300));

    _ready = true;

    notifyListeners();

    try {
      FlutterStatusbarcolor.setStatusBarColor(Colors.transparent,
          animate: true);

      if (_isDark) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      } else {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _syncWithDatabase() async {
    if (_changedTasks.length <= 0 &&
        _newTasks.length <= 0 &&
        _removedTasks.length <= 0) return;

    print(
      '${_changedTasks.length} task(s) have been changed since last update',
    );
    print(
      '${_newTasks.length} task(s) have been created since last update',
    );
    print(
      '${_removedTasks.length} task(s) have been removed since last update',
    );

    final changedTasks = _changedTasks;
    _changedTasks = Set();

    for (final changedId in changedTasks) {
      try {
        final changedTask = _tasks.firstWhere((task) => task.id == changedId);

        await _db.updateTask(changedTask);
      } on StateError catch (e) {
        print(e);
      }
    }

    final newTasks = _newTasks;
    _newTasks = Set();

    for (final newId in newTasks) {
      try {
        final newTask = _tasks.firstWhere((task) => task.id == newId);

        await _db.insertTask(newTask);
      } on StateError catch (e) {
        print(e);
      }
    }

    final removedTasks = _removedTasks;
    _removedTasks = Set();

    for (final removedId in removedTasks) {
      try {
        await _db.deleteTask(removedId);
      } on StateError catch (e) {
        print(e);
      }
    }
  }

  String _selected;

  var _updating = false;

  /// Notifies listeners and sends the update to the changes
  /// list to be added to the database.
  void _updateData() async {
    if (_updating) {
      print('already updating - ignoring update request');
      return;
    }

    _updating = true;

    var previousTasksUpdated = <Task>[];
    var removed = <String>[];
    var changed = <String>[];
    var created = <String>[];

    notifyListeners();

    print('notified listeners');

    await Future.delayed(Duration(milliseconds: 200));

    // Add changed tasks and new to the list of tasks to be updated
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];

      var isNew = true;
      var isChanged = false;

      for (final previousTask in _previousTasks) {
        if (previousTask.id == task.id) {
          isNew = false;

          if (!previousTask.equals(task)) {
            isChanged = true;
          }

          if (previousTask.category != task.category) {
            isChanged = true;
          }
        }
      }

      if (isNew) {
        created.add(task.id);
      } else if (isChanged) {
        changed.add(task.id);
      }

      previousTasksUpdated.add(
        Task(name: task.name, category: task.category)
          ..id = task.id
          ..isSnapshot = true,
      );
    }

    // remove tasks from database
    for (final previousTask in _previousTasks) {
      var remove = true;

      for (final task in _tasks) {
        if (task.id == previousTask.id) {
          remove = false;
        }
      }

      if (remove) {
        removed.add(previousTask.id);
      }
    }

    _changedTasks.addAll(changed);
    _newTasks.addAll(created);
    _removedTasks.addAll(removed);

    _updating = false;

    _previousTasks = previousTasksUpdated;
  }

  void selectTask(String id) {
    _selected = id;
    notifyListeners();
  }

  void unselect() {
    _selected = null;
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    if (_selected == null) return;

    final selected = _selected;

    _selected = null;

    notifyListeners();

    _tasks.removeWhere((task) => task.id == selected);

    _updateData();
  }

  void renameTask(String name, {@required String taskId}) {
    final index = _tasks.indexWhere((task) => task.id == taskId);

    final currentTask = _tasks[index];

    final newTask = Task.rename(
      currentTask,
      name,
    );

    _tasks[index] = newTask;

    _updateData();
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

    _updateData();
  }

  void setTaskCategory(String id, TaskCategory category) {
    if (id == null || category == null) return;

    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].category = category;
    }

    _updateData();
  }

  static TaskNotifier of(BuildContext context, {bool listen = true}) {
    if (context == null) return null;

    return Provider.of<TaskNotifier>(context, listen: listen);
  }

  @override
  void dispose() {
    _dbTimer?.cancel();
    super.dispose();
  }
}
