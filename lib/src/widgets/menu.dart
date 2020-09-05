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

class TasksAppDrawer extends StatelessWidget {
  const TasksAppDrawer({
    Key key,
    @required this.close,
  }) : super(key: key);

  final void Function() close;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Scaffold(
            body: SafeArea(
              child: ListView(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Text(
                          'Tasks App',
                          style:
                              Theme.of(context).appBarTheme.textTheme.headline6,
                        ),
                        Spacer(),
                        IconButton(
                          iconSize: 24,
                          icon: Icon(
                            FeatherIcons.arrowRight,
                          ),
                          onPressed: close ??
                              () {
                                Navigator.pop(context);
                              },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Builder(
                    builder: (context) {
                      var items = <Widget>[];

                      for (var i = 0; i < links.length; i++) {
                        final link = links[i];

                        final tasks = TaskNotifier.of(context)
                            ?.fromCategory(link.category);

                        final color = link.category == TaskCategory.incomplete
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
                                close();
                                await Future.delayed(
                                    Duration(milliseconds: 220));
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
                ],
              ),
            ),
          ),
        ),
        VerticalDivider(
          width: 2,
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

  const _MenuItem(this.title,
      {Key key, this.onPressed, this.index = 0, this.count, this.color})
      : super(key: key);

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

    return SlideTransition(
      position: _entryAnim.drive(tween),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 32),
        onTap: widget.count <= 0 ? null : widget.onPressed,
        title: Row(
          children: [
            Text(
              widget.title ?? '',
              style: TextStyle(
                color: widget.count <= 0 ? Colors.black38 : Colors.black,
              ),
            ),
            SizedBox(
              width: 16,
            ),
            Text(
              '${widget.count ?? 0}',
              style: TextStyle(
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
