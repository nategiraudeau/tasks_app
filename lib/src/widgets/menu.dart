import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/src/notifiers/tasks_notifier.dart';
import 'package:tasks_app/src/task_category_list.dart';
import 'package:tasks_app/src/tasks.dart';
import 'package:tasks_app/src/theme.dart';

@immutable
class _MenuLink {
  final String title;
  final TaskCategory category;

  _MenuLink(this.title, this.category);
}

void showAppMenu(BuildContext context) {
  final tween = Tween(
    begin: Offset(-1, 0),
    end: Offset.zero,
  );

  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, _) {
        return Stack(
          children: [
            FadeTransition(
              opacity: CurvedAnimation(
                curve: Curves.ease,
                parent: animation,
              ),
              child: Scaffold(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            SlideTransition(
              position: tween.animate(
                CurvedAnimation(
                  curve: Curves.easeOutCirc,
                  reverseCurve: Curves.easeInOutCubic,
                  parent: animation,
                ),
              ),
              // child: TasksAppDrawer(),
            ),
          ],
        );
      },
    ),
  );
}

final links = [
  _MenuLink('Complete', TaskCategory.complete),
  _MenuLink('In Progress', TaskCategory.inProgress),
  _MenuLink('Incomplete', TaskCategory.incomplete),
];

class TasksAppDrawer extends StatefulWidget {
  const TasksAppDrawer({
    Key key,
    @required this.close,
  }) : super(key: key);

  final void Function() close;

  @override
  _TasksAppDrawerState createState() => _TasksAppDrawerState();
}

class _TasksAppDrawerState extends State<TasksAppDrawer>
    with SingleTickerProviderStateMixin {
  AnimationController _bgAnim;

  @override
  void initState() {
    final notifier = TaskNotifier.of(context, listen: false);

    _bgAnim = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 500,
      ),
      value: (notifier?.isDark ?? false) ? 1 : 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = TaskNotifier.of(context);

    if (notifier?.isDark ?? false) {
      _bgAnim.forward();
    } else {
      _bgAnim.reverse();
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
        ),
        SlideTransition(
          position: CurvedAnimation(
            parent: _bgAnim,
            curve: Curves.easeInOutQuint,
            reverseCurve: Interval(
              0.0,
              0.5,
              curve: Curves.easeInOutQuint,
            ),
          ).drive(
            Tween(
              begin: Offset(0, 1),
              end: Offset.zero,
            ),
          ),
          child: Scaffold(
            backgroundColor: AppTheme.darkThemeData.scaffoldBackgroundColor,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 32,
                          ),
                          SizedBox(
                            width: 32,
                            child: Image.asset('assets/icon-green.png'),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            'Tasks App',
                            style: Theme.of(context)
                                .appBarTheme
                                .textTheme
                                .headline6,
                          ),
                          Spacer(),
                          IconButton(
                            iconSize: 24,
                            icon: Icon(
                              FeatherIcons.arrowRight,
                            ),
                            onPressed: widget.close ??
                                () {
                                  Navigator.pop(context);
                                },
                          ),
                          SizedBox(
                            width: 32,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        height: 18,
                        indent: 28,
                        endIndent: 36,
                      ),
                      Builder(
                        builder: (context) {
                          var items = <Widget>[];

                          for (var i = 0; i < links.length; i++) {
                            final link = links[i];

                            final tasks = TaskNotifier.of(context)
                                ?.fromCategory(link.category);

                            final color =
                                link.category == TaskCategory.incomplete
                                    ? AppTheme.incomplete
                                    : link.category == TaskCategory.inProgress
                                        ? AppTheme.inProgress
                                        : AppTheme.mainColor;

                            items.add(
                              _MenuItem(
                                link.title,
                                index: i,
                                count: tasks?.length ?? 0,
                                color: color,
                                onPressed: () async {
                                  print(link.category);

                                  final tasks =
                                      TaskNotifier.of(context, listen: false)
                                          ?.fromCategory(link.category);

                                  if (!(tasks == null || tasks.length <= 0)) {
                                    widget.close();
                                    await Future.delayed(
                                        Duration(milliseconds: 80));
                                    showTaskCategory(context, link.category);
                                  }
                                },
                              ),
                            );
                          }

                          return Column(
                            children: items,
                          );
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        height: 18,
                        indent: 28,
                        endIndent: 36,
                      ),
                      _MenuItem(
                        'Dark Mode',
                        index: links.length + 1,
                        trailing: Switch(
                          value: notifier?.isDark,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (value) {
                            notifier?.toggleIsDark(value);
                          },
                        ),
                      ),
                      Divider(
                        height: 18,
                        indent: 28,
                        endIndent: 36,
                      ),
                      _MenuItem(
                        'Clear Tasks',
                        onPressed: () {
                          notifier?.resetTasks();
                        },
                        index: links.length + 2,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FeatherIcons.trash2),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            VerticalDivider(
              width: 2,
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuItem extends StatefulWidget {
  final String title;
  final void Function() onPressed;
  final int index;
  final int count;
  final Color color;
  final Widget trailing;

  const _MenuItem(
    this.title, {
    Key key,
    this.onPressed,
    this.index = 0,
    this.count,
    this.color,
    this.trailing,
  }) : super(key: key);

  @override
  __MenuItemState createState() => __MenuItemState();
}

class __MenuItemState extends State<_MenuItem>
    with SingleTickerProviderStateMixin {
  AnimationController _entryAnim;

  Future<void> _startAnim() async {
    await Future.delayed(Duration(milliseconds: (widget.index ?? 0) * 50));
    _entryAnim?.forward();
  }

  @override
  void initState() {
    _entryAnim = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 700,
      ),
    );

    _startAnim();

    super.initState();
  }

  @override
  void dispose() {
    _entryAnim?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tween = Tween(
      begin: Offset(-1, 0),
      end: Offset.zero,
    ).chain(
      CurveTween(
        curve: ElasticOutCurve(0.9),
      ),
    );

    final textColor = Theme.of(context).colorScheme.onBackground;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 32),
      onTap:
          widget.count != null && widget.count <= 0 ? null : widget.onPressed,
      title: SlideTransition(
        position: _entryAnim.drive(tween),
        child: Row(
          children: [
            Text(
              widget.title ?? '',
              style: TextStyle(
                color: widget.count != null && widget.count <= 0
                    ? textColor.withOpacity(0.38)
                    : textColor,
              ),
            ),
            SizedBox(
              width: 16,
            ),
            widget.count == null
                ? Container()
                : Text(
                    '${widget?.count ?? 0}',
                    style: TextStyle(
                      color: widget.color,
                    ),
                  ),
          ],
        ),
      ),
      trailing: widget.trailing,
    );
  }
}
