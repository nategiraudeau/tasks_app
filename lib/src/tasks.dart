import 'package:tasks_app/src/create_task.dart';
import 'package:tasks_app/src/notifiers/tasks_notifier.dart';
import 'package:tasks_app/src/task_category_list.dart';
import 'package:tasks_app/src/theme.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/src/widgets/task_tile.dart';

enum TaskCategory { complete, inProgress, incomplete, trash }

class Tasks extends StatefulWidget {
  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> with AutomaticKeepAliveClientMixin {
  var _showCompleted = false;

  @override
  void initState() {
    final taskNotifier = TaskNotifier.of(context, listen: false);

    if (taskNotifier.incomplete.isEmpty &&
        taskNotifier.inProgress.isEmpty &&
        taskNotifier.tasks.isNotEmpty) {
      _showCompleted = true;
    }

    super.initState();
  }

  Future<void> _showCompletedMessage() async {
    final taskNotifier = TaskNotifier.of(context, listen: false);

    await Future.delayed(Duration(milliseconds: 1000));

    if (taskNotifier.incomplete.isEmpty &&
        taskNotifier.inProgress.isEmpty &&
        taskNotifier.tasks.isNotEmpty) {
      _showCompleted = true;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final taskNotifier = TaskNotifier.of(context);

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: Builder(
        key: ValueKey(taskNotifier.tasks.length > 0),
        builder: (context) {
          if (taskNotifier.tasks.length <= 0) {
            return Column(
              children: <Widget>[
                AppBar(
                  title: Text('Tasks'),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: GestureDetector(
                        onTap: () {
                          createTask(context);
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'You don\'t have any tasks yet. ',
                              ),
                              TextSpan(
                                text: '\nCreate One',
                                style: TextStyle(
                                  color: AppTheme.mainColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 52,
                ),
              ],
            );
          }

          final incompleteTasksCount = (taskNotifier?.tasks
                  ?.where((task) => task.category != TaskCategory.complete)
                  ?.length ??
              0);

          if (incompleteTasksCount <= 0) {
            _showCompletedMessage();
          } else
            _showCompleted = false;

          return GestureDetector(
            onTap: () {
              taskNotifier.unselect();
            },
            child: ListView(
              children: <Widget>[
                SafeArea(
                  child: AppBar(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Tasks'),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          '$incompleteTasksCount',
                          style: TextStyle(
                            color: AppTheme.mainColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width >= 500 ? 20 : 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          TaskCategoryChip(
                            text: 'Complete',
                            color: AppTheme.mainColor,
                            count: taskNotifier.complete.length,
                            onPressed: () {
                              showTaskCategory(context, TaskCategory.complete);
                            },
                          ),
                          SizedBox(width: 10),
                          TaskCategoryChip(
                            text: 'In Progress',
                            color: AppTheme.inProgress,
                            count: taskNotifier.inProgress.length,
                            onPressed: () {
                              showTaskCategory(
                                  context, TaskCategory.inProgress);
                            },
                          ),
                          SizedBox(width: 10),
                          TaskCategoryChip(
                            text: 'Incomplete',
                            color: AppTheme.incomplete,
                            count: taskNotifier.incomplete.length,
                            onPressed: () {
                              showTaskCategory(
                                  context, TaskCategory.incomplete);
                            },
                          ),
                        ],
                      ),
                      Divider(
                        height:
                            MediaQuery.of(context).size.width >= 500 ? 56 : 32,
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    if (incompleteTasksCount <= 0 && _showCompleted) {
                      return _CompletedAllTasksMessage();
                    }

                    final tasks = taskNotifier.tasks;

                    var tiles = <Widget>[];

                    for (int i = 0; i < tasks.length; i++) {
                      final task = tasks[i];

                      tiles.add(
                        TaskTile(
                          task,
                          key: ValueKey(task.id),
                          index: i,
                          animate: false,
                          visible: task.category != TaskCategory.complete,
                        ),
                      );
                    }

                    return SystemPadding(
                      child: Column(
                        children: tiles,
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 48,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

//
// ------------------------------------------------
//

class _CompletedAllTasksMessage extends StatefulWidget {
  const _CompletedAllTasksMessage({
    Key key,
  }) : super(key: key);

  @override
  __CompletedAllTasksMessageState createState() =>
      __CompletedAllTasksMessageState();
}

class __CompletedAllTasksMessageState extends State<_CompletedAllTasksMessage>
    with SingleTickerProviderStateMixin {
  AnimationController _entryAnim;

  @override
  void initState() {
    _entryAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..forward();

    super.initState();
  }

  @override
  void dispose() {
    _entryAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tween1 = Tween(
      begin: Offset(0, 4),
      end: Offset.zero,
    ).chain(
      CurveTween(
        curve: ElasticOutCurve(0.8),
      ),
    );
    final tween2 = Tween(
      begin: Offset(0, 4),
      end: Offset.zero,
    ).chain(
      CurveTween(
        curve: Interval(
          0.2,
          1,
          curve: ElasticOutCurve(0.92),
        ),
      ),
    );

    final isDark = TaskNotifier.of(context)?.isDark ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 56,
      ),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4.5,
          ),
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _entryAnim,
              curve: Interval(
                0.0,
                0.3,
                curve: Curves.ease,
              ),
            ),
            child: SlideTransition(
              position: _entryAnim.drive(tween1),
              child: Column(
                children: [
                  Text(
                    'Great Job!',
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entryAnim,
                      curve: Interval(
                        0.2,
                        0.7,
                        curve: Curves.ease,
                      ),
                    ),
                    child: SlideTransition(
                      position: _entryAnim.drive(tween2),
                      child: Column(
                        children: [
                          Text(
                            'You\'ve finished all your tasks.',
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      color: isDark
                                          ? Colors.white60
                                          : Theme.of(context)
                                              .colorScheme
                                              .onBackground
                                              .withOpacity(0.45),
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

//
// ------------------------------------------------
//

class TaskCategoryChip extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final int count;
  final Color color;

  const TaskCategoryChip({
    Key key,
    this.onPressed,
    this.text,
    this.count,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = 18.0;
    final isBig = MediaQuery.of(context).size.width >= 500;
    final aintTappable = (count ?? 0) <= 0;
    final isDark = TaskNotifier.of(context)?.isDark ?? false;

    return Expanded(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: Container(
          key: ValueKey(aintTappable),
          decoration: BoxDecoration(
            color: aintTappable
                ? Colors.transparent
                : (color ?? Colors.transparent).withOpacity(0.1),
            border: aintTappable
                ? Border.all(
                    width: 2,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.07),
                  )
                : null,
            borderRadius: BorderRadius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              splashColor: (color ?? Colors.black).withOpacity(0.15),
              highlightColor: (color ?? Colors.black).withOpacity(0.1),
              onTap: aintTappable ? null : onPressed ?? () {},
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: Padding(
                  key: ValueKey(count),
                  padding: EdgeInsets.symmetric(
                    vertical:
                        isBig ? aintTappable ? 14 : 16 : aintTappable ? 4 : 6,
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: !isBig && isDark && (count ?? 0) > 0
                          ? Color.alphaBlend(Colors.white24, color)
                          : (count ?? 0) <= 0 ? color.withOpacity(0.5) : color,
                      fontWeight: isDark ? FontWeight.w600 : FontWeight.w700,
                      fontSize: fontSize,
                      fontFamily: 'Gellix',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        isBig
                            ? Text(
                                text ?? '',
                                style: TextStyle(
                                  color: (isDark
                                          ? Colors.white
                                          : color ?? Colors.black)
                                      .withOpacity(count <= 0 ? 0.6 : 0.8),
                                ),
                              )
                            : Container(),
                        isBig
                            ? SizedBox(
                                width: 6,
                              )
                            : Container(),
                        Text(
                          '${count ?? 0}',
                          style: TextStyle(
                            fontWeight:
                                isDark ? FontWeight.w700 : FontWeight.w900,
                            fontSize: fontSize + 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
