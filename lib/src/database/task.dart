import 'package:tasks_app/src/tasks.dart';
import 'package:uuid/uuid.dart';

class TaskCategoryIdentifiers {
  static final complete = 'complete';
  static final inProgress = 'inProgress';
  static final incomplete = 'incomplete';

  static final columnId = 'category';
}

/// The data model for a Task
class Task {
  static final _uuid = Uuid();

  void setCategory(TaskCategory category) {
    this.category = category;
  }

  String name;
  TaskCategory category;
  String id;
  bool isSnapshot;

  Task.rename(Task task, this.name) {
    this.id = task.id;
    this.category = task.category;
  }

  bool equals(Task other) {
    return other.name == name && other.category == category && other.id == id;
  }

  Map<String, dynamic> toMap() {
    String categoryId;

    switch (category) {
      case TaskCategory.incomplete:
        categoryId = TaskCategoryIdentifiers.incomplete;
        break;
      case TaskCategory.inProgress:
        categoryId = TaskCategoryIdentifiers.inProgress;
        break;
      default:
        categoryId = TaskCategoryIdentifiers.complete;
        break;
    }

    final map = <String, dynamic>{
      'id': id,
      'name': name,
      TaskCategoryIdentifiers.columnId: categoryId,
    };

    return map;
  }

  Task.fromMap(Map<String, dynamic> map) {
    if (map == null) throw TasksDatabaseException('Map is null');

    this.isSnapshot = false;

    if (map['id'] == null ||
        map['name'] == null ||
        map[TaskCategoryIdentifiers.columnId] == null)
      throw TasksDatabaseException('Map is incorrect');

    if (map['id'] is String ||
        map['name'] is String ||
        map[TaskCategoryIdentifiers.columnId] is String) {
      // all the fields are strings
      this.id = map['id'];
      this.name = map['name'];

      final category = map[TaskCategoryIdentifiers.columnId];

      if (category == TaskCategoryIdentifiers.complete) {
        this.category = TaskCategory.complete;
      } else if (category == TaskCategoryIdentifiers.incomplete) {
        this.category = TaskCategory.incomplete;
      } else if (category == TaskCategoryIdentifiers.inProgress) {
        this.category = TaskCategory.inProgress;
      } else {
        throw TasksDatabaseException('Map category is wrong');
      }
    } else {
      throw TasksDatabaseException('Map is incorrect');
    }
  }

  Task({this.name, this.category = TaskCategory.incomplete}) {
    this.id = _uuid.v1();
    this.isSnapshot = false;
  }

  String toString() {
    return '''Task {
           name: $name,
           category: $category,
           id: $id
         }
         ''';
  }
}

class TasksDatabaseException implements Exception {
  TasksDatabaseException(String message);
}
