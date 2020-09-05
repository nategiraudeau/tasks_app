import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:tasks_app/src/notifiers/tasks_notifier.dart';
import 'package:tasks_app/src/tasks.dart';
import 'package:tasks_app/src/theme.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final int index;
  final bool animate;
  final bool visible;

  const TaskTile(
    this.task, {
    Key key,
    this.index,
    this.animate = true,
    this.visible = true,
  }) : super(key: key);

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> with TickerProviderStateMixin {
  var _expanded = false;
  var _deleted = false;

  // Animation for the expand icon
  AnimationController _iconAnim;
  AnimationController _entryAnim;

  Future<void> _startEntry() async {
    await Future.delayed(
      Duration(
        milliseconds: ((widget.index ?? 0) * 40),
      ),
    );

    _entryAnim.forward();
  }

  Future<void> _collapseWhenNotVisible() async {
    await Future.delayed(
      Duration(
        milliseconds: 1200,
      ),
    );

    final notifier = TaskNotifier.of(context, listen: false);

    if ((notifier?.fromCategory(widget.task.category)?.length ?? 0) <= 0 ||
        _deleted) _expanded = false;

    if (mounted) setState(() {});
  }

  var _taskName = TextEditingController();

  @override
  void initState() {
    assert(widget.animate != null, "Animate must not be null.");

    _taskName.value = TextEditingValue(
      text: widget.task.name,
    );

    _iconAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _entryAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ((widget.index ?? 0) * 3) + 700),
      value: widget.animate ? 0 : 0.5,
    );

    _startEntry();

    super.initState();
  }

  @override
  void dispose() {
    _iconAnim.dispose();
    _entryAnim.dispose();
    super.dispose();
  }

  void _makeComplete() {
    final taskNotifier = TaskNotifier.of(context, listen: false);
    taskNotifier.setTaskCategory(widget.task.id, TaskCategory.complete);
  }

  void _makeIncomplete() {
    final taskNotifier = TaskNotifier.of(context, listen: false);
    taskNotifier.setTaskCategory(widget.task.id, TaskCategory.incomplete);
  }

  void _makeInProgress() {
    final taskNotifier = TaskNotifier.of(context, listen: false);
    taskNotifier.setTaskCategory(widget.task.id, TaskCategory.inProgress);
  }

  @override
  Widget build(BuildContext context) {
    if (_expanded) {
      _iconAnim.forward();
    } else {
      _iconAnim.reverse();
    }

    var icon = FeatherIcons.circle;
    var color = AppTheme.incomplete;
    var alignment = Alignment.centerLeft;

    if (widget.task.category == TaskCategory.inProgress) {
      color = AppTheme.inProgress;
      alignment = Alignment.center;
    }

    if (widget.task.category == TaskCategory.complete) {
      icon = FeatherIcons.checkCircle;
      color = AppTheme.mainColor;
      alignment = Alignment.centerRight;
    }

    final tween = widget.animate
        ? Tween<Offset>(
            begin: Offset(0, 3),
            end: Offset.zero,
          ).chain(
            CurveTween(
              curve: ElasticOutCurve(0.95),
            ),
          )
        : Tween<Offset>(
            begin: Offset.zero,
            end: Offset.zero,
          );

    assert(widget.visible != null);

    if ((!widget.visible || _deleted) && _expanded) {
      _collapseWhenNotVisible();
    }

    var selected = false;

    final notifier = TaskNotifier.of(context, listen: false);

    if (notifier.selectedId == widget.task.id) selected = true;

    return Stack(
      children: [
        AnimatedOpacity(
          duration: Duration(milliseconds: 800),
          opacity: widget.visible && !_deleted ? 1 : 0,
          curve: Interval(
            0.5,
            1,
            curve: Curves.ease,
          ),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: FadeTransition(
              key: ValueKey(selected),
              opacity: CurvedAnimation(curve: Curves.ease, parent: _entryAnim),
              child: SlideTransition(
                position: _entryAnim.drive(tween),
                child: Column(
                  children: <Widget>[
                    Material(
                      animationDuration: _expanded
                          ? Duration(milliseconds: 300)
                          : Duration.zero,
                      color: _expanded ? Colors.white : Colors.transparent,
                      elevation: !selected && _expanded ? 12 : 0,
                      shadowColor: _expanded
                          ? Colors.black26.withBlue(20)
                          : Colors.transparent,
                      borderRadius: _expanded || selected
                          ? BorderRadius.circular(28)
                          : BorderRadius.zero,
                      clipBehavior: Clip.antiAlias,
                      child: Material(
                        borderRadius: _expanded
                            ? BorderRadius.circular(28)
                            : BorderRadius.zero,
                        color: selected
                            ? color.withOpacity(0.07)
                            : Colors.transparent,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            AnimatedContainer(
                              duration: Duration(milliseconds: 800),
                              curve: Interval(
                                0.5,
                                1,
                                curve: Curves.easeInOutCirc,
                              ),
                              height: widget.visible && !_deleted ? 56 : 0,
                              child: ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: 56,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        splashColor: selected
                                            ? color.withOpacity(0.2)
                                            : null,
                                        highlightColor: selected
                                            ? color.withOpacity(0.2)
                                            : null,
                                      ),
                                      child: ListTile(
                                        onLongPress: () {
                                          final notifier = TaskNotifier.of(
                                              context,
                                              listen: false);

                                          if (selected) {
                                            notifier.unselect();
                                          } else {
                                            notifier.selectTask(widget.task.id);
                                          }

                                          setState(() {});
                                        },
                                        onTap: widget.visible && !_deleted
                                            ? () {
                                                setState(() {
                                                  _expanded = !_expanded;
                                                });
                                              }
                                            : () {},
                                        contentPadding: EdgeInsets.only(
                                          right: 32,
                                          left: 12,
                                        ),
                                        title: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: 12,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  if (widget.task.category ==
                                                      TaskCategory.complete)
                                                    _makeIncomplete();
                                                  else
                                                    _makeComplete();
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                child: AnimatedSwitcher(
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  child: Padding(
                                                    key: ValueKey(
                                                        widget.task.category),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Icon(
                                                      icon,
                                                      size: 20,
                                                      color: widget.task
                                                                  .category ==
                                                              TaskCategory
                                                                  .incomplete
                                                          ? selected
                                                              ? color
                                                              : Colors.black
                                                                  .withOpacity(
                                                                      0.5)
                                                          : color,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: selected
                                                  ? CupertinoTextField(
                                                      padding: EdgeInsets.zero,
                                                      decoration: null,
                                                      autofocus: true,
                                                      cursorColor: color,
                                                      controller: _taskName,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1,
                                                      onChanged: (value) {
                                                        if (value != null &&
                                                            value.isNotEmpty) {
                                                          final notifier =
                                                              TaskNotifier.of(
                                                                  context,
                                                                  listen:
                                                                      false);

                                                          notifier.renameTask(
                                                            value,
                                                            taskId:
                                                                widget.task.id,
                                                          );
                                                        }
                                                      },
                                                    )
                                                  : Text(
                                                      widget.task.name ?? '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                    ),
                                            ),
                                          ],
                                        ),
                                        trailing: selected
                                            ? _SelectedActions(
                                                delete: () async {
                                                  setState(() {
                                                    _deleted = true;
                                                  });
                                                  await Future.delayed(
                                                    Duration(milliseconds: 780),
                                                  );

                                                  final notifier =
                                                      TaskNotifier.of(context,
                                                          listen: false);

                                                  if (selected)
                                                    notifier.deleteSelected();
                                                },
                                              )
                                            : Builder(
                                                builder: (context) {
                                                  final anim = _expanded
                                                      ? CurvedAnimation(
                                                          parent: _iconAnim,
                                                          curve: Curves
                                                              .easeOutCirc,
                                                        )
                                                      : CurvedAnimation(
                                                          parent: _iconAnim,
                                                          curve:
                                                              Curves.easeInCirc,
                                                        );

                                                  return AnimatedBuilder(
                                                    animation: anim,
                                                    builder: (context, child) =>
                                                        Transform.rotate(
                                                      angle: anim.value * 3.15,
                                                      child: child,
                                                    ),
                                                    child: Icon(
                                                      Icons.expand_more,
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 200),
                              opacity: _expanded ? 1 : 0,
                              child: Divider(
                                height: 0,
                              ),
                            ),
                            AnimatedOpacity(
                              duration: Duration(
                                milliseconds: 200,
                              ),
                              curve: Curves.ease,
                              opacity: _expanded ? 1 : 0,
                              child: AnimatedContainer(
                                duration:
                                    !widget.visible && !_deleted && _expanded
                                        ? Duration(milliseconds: 1200)
                                        : Duration(milliseconds: 600),
                                curve: !widget.visible && !_deleted && _expanded
                                    ? Interval(
                                        0.5,
                                        1.0,
                                        curve: Curves.fastLinearToSlowEaseIn,
                                      )
                                    : Curves.fastLinearToSlowEaseIn,
                                height: _expanded && widget.visible && !_deleted
                                    ? 140
                                    : 0,
                                child: DefaultTextStyle(
                                  style: Theme.of(context).textTheme.subtitle2,
                                  child: ListView(
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height: 140,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Stack(
                                            children: [
                                              AnimatedAlign(
                                                duration:
                                                    Duration(milliseconds: 700),
                                                curve: ElasticOutCurve(0.9),
                                                alignment: alignment,
                                                child: AnimatedSwitcher(
                                                  duration: Duration(
                                                      milliseconds: 200),
                                                  child: SizedBox(
                                                    key: ValueKey(
                                                        widget.task.category),
                                                    width: 93,
                                                    height: 116,
                                                    child: Material(
                                                      color: color
                                                          .withOpacity(0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              AnimatedSwitcher(
                                                duration:
                                                    Duration(milliseconds: 400),
                                                child: Row(
                                                  key: ValueKey(
                                                      widget.task.category),
                                                  children: <Widget>[
                                                    _TaskCategoryWidget(
                                                      TaskCategory.incomplete,
                                                      selected: widget
                                                              .task.category ==
                                                          TaskCategory
                                                              .incomplete,
                                                      onPressed: () {
                                                        _makeIncomplete();
                                                      },
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Center(
                                                        child: Opacity(
                                                          opacity: 0.5,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 8,
                                                            ),
                                                            child: Icon(
                                                              LineIcons
                                                                  .arrow_right,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    _TaskCategoryWidget(
                                                      TaskCategory.inProgress,
                                                      selected: widget
                                                              .task.category ==
                                                          TaskCategory
                                                              .inProgress,
                                                      onPressed: () {
                                                        _makeInProgress();
                                                      },
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Center(
                                                        child: Opacity(
                                                          opacity: 0.5,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 8,
                                                            ),
                                                            child: Icon(
                                                              LineIcons
                                                                  .arrow_right,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    _TaskCategoryWidget(
                                                      TaskCategory.complete,
                                                      selected: widget
                                                              .task.category ==
                                                          TaskCategory.complete,
                                                      onPressed: () {
                                                        _makeComplete();
                                                      },
                                                    ),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: !widget.visible && !_deleted && _expanded
                          ? Duration(milliseconds: 1200)
                          : Duration(milliseconds: 600),
                      curve: !widget.visible && !_deleted && _expanded
                          ? Interval(
                              0.5,
                              1.0,
                              curve: Curves.fastLinearToSlowEaseIn,
                            )
                          : Curves.fastLinearToSlowEaseIn,
                      height: _expanded && widget.visible && !_deleted ? 20 : 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: _deleted
              ? GestureDetector(
                  onTap: () {},
                )
              : Container(),
        ),
      ],
    );
  }
}

//
// ---------------------------------------------
//

class _SelectedActions extends StatefulWidget {
  final void Function() delete;

  const _SelectedActions({
    Key key,
    @required this.delete,
  }) : super(key: key);

  @override
  __SelectedActionsState createState() => __SelectedActionsState();
}

class __SelectedActionsState extends State<_SelectedActions>
    with TickerProviderStateMixin {
  AnimationController _closeAnim;
  AnimationController _deleteAnim;

  Future<void> _startAnim() async {
    _deleteAnim?.forward();

    await Future.delayed(Duration(milliseconds: 80));

    _closeAnim?.forward();
  }

  @override
  void initState() {
    _closeAnim = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 700,
      ),
    );
    _deleteAnim = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 700,
      ),
    );

    _startAnim();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final curve = ElasticOutCurve(0.65);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: CurvedAnimation(
            parent: _deleteAnim,
            curve: curve,
          ),
          child: IconButton(
            icon: Icon(FeatherIcons.trash2),
            color: Colors.black,
            iconSize: 20,
            onPressed: widget.delete ?? () {},
          ),
        ),
        SizedBox(
          width: 2,
        ),
        ScaleTransition(
          scale: CurvedAnimation(
            parent: _closeAnim,
            curve: curve,
          ),
          child: IconButton(
            icon: Icon(FeatherIcons.x),
            color: Colors.black,
            iconSize: 20,
            onPressed: () {
              final notifier = TaskNotifier.of(context, listen: false);

              notifier.unselect();
            },
          ),
        ),
      ],
    );
  }
}

//
// ---------------------------------------------
//

class _TaskCategoryWidget extends StatefulWidget {
  final TaskCategory category;
  final bool selected;
  final void Function() onPressed;

  const _TaskCategoryWidget(
    this.category, {
    Key key,
    this.onPressed,
    this.selected = false,
  }) : super(key: key);

  @override
  __TaskCategoryWidgetState createState() => __TaskCategoryWidgetState();
}

class __TaskCategoryWidgetState extends State<_TaskCategoryWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _iconAnim;

  @override
  void initState() {
    _iconAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      value: 0.8,
    );
    super.initState();
  }

  @override
  void dispose() {
    _iconAnim?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var icon = FeatherIcons.circle;
    var color = AppTheme.incomplete;
    var text = 'Incomplete';

    if (widget.category == TaskCategory.inProgress) {
      icon = FeatherIcons.arrowRightCircle;
      color = AppTheme.inProgress;
      text = "In Progress";
    }

    if (widget.category == TaskCategory.complete) {
      icon = FeatherIcons.checkCircle;
      color = AppTheme.mainColor;
      text = "Complete";
    }

    if (widget.selected)
      _iconAnim.forward();
    else
      _iconAnim.animateTo(0.8);

    return SizedBox(
      width: 93,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ScaleTransition(
                      scale: CurvedAnimation(
                        curve: widget.selected
                            ? Curves.elasticOut
                            : Curves.easeInOutCubic,
                        parent: _iconAnim,
                      ),
                      child: Icon(
                        icon,
                        color: widget.selected ? color : Colors.black45,
                        size: 28,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    FittedBox(
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: widget.selected ? color : Colors.black45,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  splashColor: !widget.selected
                      ? Colors.black.withOpacity(0.02)
                      : color.withOpacity(0.13),
                  highlightColor: !widget.selected
                      ? Colors.black.withOpacity(0.02)
                      : color.withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
