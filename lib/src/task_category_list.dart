import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/src/notifiers/tasks_notifier.dart';
import 'package:tasks_app/src/tasks.dart';
import 'package:tasks_app/src/theme.dart';
import 'package:tasks_app/src/widgets/task_tile.dart';

class _CategoryList extends StatefulWidget {
  final TaskCategory category;

  const _CategoryList(this.category, {Key key}) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList>
    with SingleTickerProviderStateMixin {
  AnimationController _entryAnim;

  @override
  void initState() {
    _entryAnim = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 550,
      ),
    )..forward();
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
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: Builder(
            builder: (context) {
              if (tasks == null) return Scaffold();

              return Column(
                children: [
                  SizedBox(
                    height: 52,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: Icon(
                                FeatherIcons.arrowLeft,
                              ),
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
                  Expanded(
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

                            for (int i = 0; i < tasks.length; i++) {
                              final task = tasks[i];

                              tiles.add(
                                TaskTile(
                                  task,
                                  index: i,
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
                  ),
                ],
              );
            },
          ),
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
