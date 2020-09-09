import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:tasks_app/src/database/task.dart';
import 'package:tasks_app/src/tasks.dart';

/// The Identifier for the tasks table.
final _tasksTableId = 'tasks';

/// The Identifier for the column in a tasks row that
/// contains the id.
final _taskIdColumnId = 'id';

/// The Identifier for the column in a tasks row that
/// contains the name.
final _taskNameColumnId = 'name';

/// The Identifier for the column in a tasks row that
/// contains the category.
final _taskCategoryColumnId = TaskCategoryIdentifiers.columnId;

/// The database helper class. It doesn't have a default
/// constructor because it's a signleton.
class TasksDatabase {
  /// The file name of the database saved locally
  static final _databaseName = 'TasksApp.db';

  /// The version of the database
  static final _databaseVersion = 1;

  // constructor to make it a signleton class
  TasksDatabase._instance();
  static final instance = TasksDatabase._instance();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  Future<Database> _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentsDirectory.path, _databaseName);

    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $_tasksTableId (
            $_taskIdColumnId TEXT NOT NULL,
            $_taskNameColumnId TEXT NOT NULL,
            $_taskCategoryColumnId TEXT NOT NULL
          )
          ''');
  }

  // Helper methods:

  /// Insert a task into the database
  Future<void> insertTask(Task task) async {
    final db = await database;

    try {
      await db.insert(_tasksTableId, task.toMap());
    } catch (e) {
      print(e);
    }
  }

  /// Insert a task into the database
  Future<void> deleteTask(String taskId) async {
    final db = await database;

    try {
      await db.delete(
        _tasksTableId,
        where: '$_taskIdColumnId = ?',
        whereArgs: [taskId],
      );
    } catch (e) {
      print(e);
    }
  }

  /// Update an existing task in the database
  Future<void> updateTask(Task task) async {
    final db = await database;

    try {
      await db.update(
        _tasksTableId,
        task.toMap(),
        where: '$_taskIdColumnId = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      print(e);
    }
  }

  /// Get all the tasks from the database
  Future<List<Task>> loadTasks() async {
    final db = await database;

    var taskMaps = <Map<String, dynamic>>[];

    try {
      taskMaps = await db.rawQuery('SELECT * FROM $_tasksTableId');
    } catch (e) {
      print(e);
    }

    var tasks = <Task>[];

    try {
      for (final taskMap in taskMaps) {
        final task = Task.fromMap(taskMap);

        if (tasks.where((existingTask) => existingTask.id == task.id).length >
            0) continue;

        if (task != null) {
          tasks.add(task);
        }
      }
    } catch (e) {
      print('tasks are incorrect');
    }

    final completed =
        tasks.where((task) => task.category == TaskCategory.complete).toList();
    final incomplete = tasks
        .where((task) => task.category == TaskCategory.incomplete)
        .toList();
    final inProgress = tasks
        .where((task) => task.category == TaskCategory.inProgress)
        .toList();

    final tasksToTake = trimTasks(completed, 15) +
        trimTasks(incomplete, 20) +
        trimTasks(inProgress, 20);

    return tasksToTake;
  }

  /// Clean all of the data out of the database
  Future<void> clean() async {
    final db = await database;

    try {
      await db.delete(_tasksTableId);
    } catch (e) {
      print(e);
    }
  }
}

List<Task> trimTasks(List<Task> tasks, [int count = 15]) {
  if (count == null || tasks == null || tasks.length <= count) return tasks;

  return tasks.reversed.take(count).toList().reversed.toList();
}
