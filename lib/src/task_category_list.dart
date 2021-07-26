import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/src/notifiers/tasks_notifier.dart';
import 'package:tasks_app/src/tasks.dart';
import 'package:tasks_app/src/theme.dart';
import 'package:tasks_app/src/widgets/icon_button.dart';
import 'package:tasks_app/src/widgets/task_tile.dart';

import 'package:tasks_app/src/data/task.dart';

class _CategoryList extends StatefulWidget {
  final TaskCategory category;

  const _CategoryList(this.category, {Key key}) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList>
    with SingleTickerProviderStateMixin {
  AnimationController _entryAnim;
  List<Task> _initialTasks = [];

  @override
  void initState() {
    _entryAnim = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 550,
      ),
    )..forward();

    final notifier = TaskNotifier.of(context, listen: false);
    _initialTasks = notifier?.fromCategory(widget.category) ?? [];

    super.initState();
  }

  @override
  void dispose() {
    _entryAnim.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await Future.delayed(Duration(milliseconds: 700));

    try {
      final notifier = TaskNotifier.of(context, listen: false);

      notifier?.unselect();

      Navigator.popUntil(context, ModalRoute.withName('/'));
    } catch (e) {
      print('error popping route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = TaskNotifier.of(context);
    final tasks = notifier?.tasks;

    final title = widget.category == TaskCategory.complete
        ? 'Completed Tasks'
        : widget.category == TaskCategory.inProgress
            ? 'Tasks In Progress'
            : 'Incomplete Tasks';

    final tween = Tween<Offset>(
      begin: Offset(0, 4),
      end: Offset.zero,
    ).chain(
      CurveTween(
        curve: ElasticOutCurve(0.95),
      ),
    );

    var color = AppTheme.incomplete;

    if (widget.category == TaskCategory.inProgress) {
      color = AppTheme.inProgress;
    }

    if (widget.category == TaskCategory.complete) {
      color = AppTheme.mainColor;
    }

    if (notifier.fromCategory(widget.category).length <= 0) {
      _close();
    }

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: Future.delayed(
            Duration(
              milliseconds: 500,
            ),
          ),
          builder: (context, snapshot) {
            if (tasks == null) return Scaffold();

            final isNotReady = false;
            // (notifier?.fromCategory(widget.category)?.length ?? 0) > 8 &&
            //     snapshot.connectionState != ConnectionState.done;

            return AnimatedSwitcher(
              duration: Duration(milliseconds: 100),
              child: Column(
                children: [
                  SizedBox(
                    height: 52,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TasksIconButton(
                              icon: FeatherIcons.arrowLeft,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: DefaultTextStyle(
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              child: SlideTransition(
                                position: _entryAnim.drive(tween),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      '${notifier?.fromCategory(widget.category)?.length ?? 0}',
                                      style: TextStyle(
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Builder(
                    key: ValueKey(isNotReady),
                    builder: (context) {
                      if (isNotReady) {
                        return Container();
                      }
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final notifier =
                                TaskNotifier.of(context, listen: false);

                            notifier?.unselect();
                          },
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Builder(builder: (context) {
                                var tiles = <Widget>[];

                                for (int i = 0; i < _initialTasks.length; i++) {
                                  final task = _initialTasks[i];

                                  tiles.add(
                                    TaskTile(
                                      task,
                                      index: i,
                                      key: ValueKey(task.id),
                                      visible: task.category == widget.category,
                                    ),
                                  );
                                }

                                return Column(
                                  children: tiles,
                                );
                              }),
                              SizedBox(
                                height: 100,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void showTaskCategory(BuildContext context, TaskCategory category) {
  final notifier = TaskNotifier.of(context, listen: false);
  final tasks = notifier?.fromCategory(category);

  if (tasks == null || tasks.length <= 0) return;

  notifier?.unselect();

  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          // child: SlideTransition(
          //   position: animation.drive(
          //     Tween<Offset>(
          //       begin: Offset(0, 0.15),
          //       end: Offset.zero,
          //     ).chain(
          //       CurveTween(
          //         curve: ElasticOutCurve(1.2),
          //       ),
          //     ),
          //   ),
          child: Material(
            elevation: 52,
            child: _CategoryList(category),
          ),
          // ),
        );
      },
    ),
  );
}
