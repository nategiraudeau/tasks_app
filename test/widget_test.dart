import 'package:flutter_test/flutter_test.dart';
import 'package:tasks_app/src/data/task.dart';
import 'package:tasks_app/src/tasks.dart';

void main() {
  test(
    'Remove duplicate tasks from a list.',
    () async {
      final testId = 'tr3tr8c3tr7twcufg8733';

      final tasks = [
        Task(
          name: 'Task 1',
          category: TaskCategory.complete,
        )..id = testId,
        Task(
          name: 'Task 1',
          category: TaskCategory.complete,
        )..id = testId,
        Task(
          name: 'Task 2',
          category: TaskCategory.inProgress,
        ),
      ];

      for (final task in tasks) {}
    },
  );
}
