import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/src/notifiers/tasks_notifier.dart';
import 'package:tasks_app/src/task_category_list.dart';
import 'package:tasks_app/src/tasks.dart';

import 'create_task.dart';
import 'theme.dart';

class Overview extends StatefulWidget {
  final bool animate;
  final void Function() goToTasks;

  const Overview({Key key, @required this.goToTasks, this.animate = true})
      : super(key: key);

  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController _contentAnim;
  AnimationController _contentAnim2;

  @override
  void initState() {
    assert(widget.animate != null);

    _contentAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
      value: widget.animate ? 0 : 1,
    );
    _contentAnim2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
      value: widget.animate ? 0 : 1,
    );
    if (widget.animate) _startAnimation();

    super.initState();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(Duration(milliseconds: 500));
    _contentAnim.forward();
    await Future.delayed(Duration(milliseconds: 80));
    _contentAnim2.forward();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final slideUpTween = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).chain(CurveTween(
      curve: ElasticOutCurve(0.9),
    ));

    final taskNotifier = TaskNotifier.of(context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      children: <Widget>[
        SafeArea(
          child: AppBar(
            title: Text(
              'Overview',
            ),
          ),
        ),
        SizedBox(
          height: 28,
        ),
        SlideTransition(
          position: _contentAnim.drive(slideUpTween),
          child: Column(
            children: <Widget>[
              Card(
                child: InkWell(
                  onTap: widget.goToTasks,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 12),
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.headline5,
                          child: Row(
                            children: <Widget>[
                              Text('Tasks'),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                '${taskNotifier.tasks.length}',
                                style: TextStyle(
                                  color: AppTheme.mainColor.withOpacity(0.8),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Icon(
                                    FeatherIcons.arrowRight,
                                    size: 22,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Material(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.black.withOpacity(0.05),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              createTask(
                                context,
                                goToTasks: widget.goToTasks,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Icon(Icons.add),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 32,
              ),
              SlideTransition(
                position: _contentAnim2.drive(slideUpTween),
                child: SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Builder(builder: (context) {
                        final count = taskNotifier?.complete?.length ?? 0;
                        final tappable = count > 0;

                        return Expanded(
                          flex: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              border: tappable
                                  ? null
                                  : Border.all(
                                      width: 3,
                                      color: Colors.black.withOpacity(0.06),
                                    ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Card(
                              color: tappable
                                  ? AppTheme.mainColor.withOpacity(0.9)
                                  : Colors.white24,
                              shadowColor: tappable
                                  ? AppTheme.mainColor.withOpacity(0.5)
                                  : Colors.transparent,
                              elevation: tappable ? 40 : 0,
                              child: InkWell(
                                highlightColor: Colors.white12,
                                splashColor: Colors.white24,
                                onTap: !tappable
                                    ? null
                                    : () {
                                        showTaskCategory(
                                            context, TaskCategory.complete);
                                      },
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '$count',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2
                                            .copyWith(
                                              color: tappable
                                                  ? Colors.white
                                                  : Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.6),
                                            ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Text(
                                          'Completed',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(
                                                color: tappable
                                                    ? Colors.white
                                                    : Colors.black
                                                        .withOpacity(0.6),
                                              ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      // Padding(
                                      //   padding: EdgeInsets.symmetric(
                                      //     horizontal: 20,
                                      //   ),
                                      //   child: Text(
                                      //     'This Week',
                                      //     textAlign: TextAlign.center,
                                      //     style: Theme.of(context)
                                      //         .textTheme
                                      //         .subtitle2
                                      //         .copyWith(
                                      //           color: Colors.white.withOpacity(0.85),
                                      //         ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            Builder(builder: (context) {
                              final count =
                                  taskNotifier?.inProgress?.length ?? 0;
                              final tappable = count > 0;

                              return Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: tappable
                                        ? null
                                        : Border.all(
                                            width: 3,
                                            color:
                                                Colors.black.withOpacity(0.06),
                                          ),
                                  ),
                                  child: Material(
                                    color: tappable
                                        ? AppTheme.inProgress.withOpacity(0.13)
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(16),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      splashColor:
                                          AppTheme.inProgress.withOpacity(0.15),
                                      highlightColor:
                                          AppTheme.inProgress.withOpacity(0.1),
                                      onTap: !tappable
                                          ? null
                                          : () {
                                              showTaskCategory(context,
                                                  TaskCategory.inProgress);
                                            },
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              '$count',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4
                                                  .copyWith(
                                                    color: tappable
                                                        ? AppTheme.inProgress
                                                        : AppTheme.inProgress
                                                            .withOpacity(0.6),
                                                  ),
                                            ),
                                            Text(
                                              'In Progress',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: tappable
                                                        ? AppTheme.inProgress
                                                        : Colors.black
                                                            .withOpacity(0.7),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            SizedBox(height: 20),
                            Builder(builder: (context) {
                              final count =
                                  taskNotifier?.incomplete?.length ?? 0;
                              final tappable = count > 0;

                              return Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: tappable
                                        ? null
                                        : Border.all(
                                            width: 3,
                                            color:
                                                Colors.black.withOpacity(0.06),
                                          ),
                                  ),
                                  child: Material(
                                    color: tappable
                                        ? AppTheme.incomplete.withOpacity(0.13)
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(16),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      splashColor:
                                          AppTheme.incomplete.withOpacity(0.15),
                                      highlightColor:
                                          AppTheme.incomplete.withOpacity(0.1),
                                      onTap: !tappable
                                          ? null
                                          : () {
                                              showTaskCategory(context,
                                                  TaskCategory.incomplete);
                                            },
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              '${taskNotifier.incomplete.length}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4
                                                  .copyWith(
                                                    color: AppTheme.incomplete
                                                        .withOpacity(
                                                            tappable ? 1 : 0.6),
                                                  ),
                                            ),
                                            Text(
                                              'Incomplete',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: tappable
                                                        ? AppTheme.incomplete
                                                        : Colors.black
                                                            .withOpacity(0.7),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
