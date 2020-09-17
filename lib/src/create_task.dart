import 'package:tasks_app/src/data/task.dart';
import 'package:tasks_app/src/notifiers/tasks_notifier.dart';
import 'package:tasks_app/src/tasks.dart';
import 'package:tasks_app/src/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Future<void> createTask(BuildContext context,
    {void Function() goToTasks}) async {
  await showDialog(
    context: context,
    builder: (context) => CreateTaskPage(
      goToTasks: goToTasks,
    ),
  );
}

class CreateTaskPage extends StatefulWidget {
  final void Function() goToTasks;

  const CreateTaskPage({Key key, this.goToTasks}) : super(key: key);

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage>
    with TickerProviderStateMixin {
  AnimationController _slideUpAnim;
  bool _validated;

  var _taskName = '';
  var _inProgress = false;

  final _focusNode = FocusNode();

  @override
  void initState() {
    _slideUpAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    )..forward();

    _focusOnStart();

    _focusNode.addListener(_handleFocusChange);

    super.initState();
  }

  Future<void> _focusOnStart() async {
    await Future.delayed(Duration(milliseconds: 500));
    _focusNode.requestFocus();
  }

  void _handleFocusChange() => setState(() {});

  @override
  void dispose() {
    _slideUpAnim.dispose();
    _focusNode.unfocus();
    _focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = Theme.of(context).primaryColor;

    final isDark = TaskNotifier.of(context)?.isDark ?? false;

    return SafeArea(
      child: SystemPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            Stack(
              children: <Widget>[
                SlideTransition(
                  position: _slideUpAnim.drive(
                    Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).chain(
                      CurveTween(
                        curve: ElasticOutCurve(0.7),
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _focusNode?.unfocus();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Material(
                        elevation: isDark ? 0 : 52,
                        shadowColor: Colors.black12,
                        color: isDark
                            ? Color.alphaBlend(
                                Colors.white10,
                                AppTheme.dark2,
                              )
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Create Task',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: 60,
                                child: TextField(
                                  cursorColor: colorScheme.onBackground,
                                  focusNode: _focusNode,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.isNotEmpty) {
                                        _validated = true;
                                      }
                                      _taskName = value;
                                    });
                                  },
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Task Name',
                                    labelStyle: isDark
                                        ? TextStyle(
                                            color: _focusNode.hasFocus
                                                ? Color.alphaBlend(
                                                    Colors.white24, primary)
                                                : null,
                                          )
                                        : null,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: isDark
                                        ? OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: primary.withOpacity(0.5),
                                              width: 2,
                                            ),
                                          )
                                        : null,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: colorScheme.onBackground
                                            .withOpacity(0.1),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                curve: Curves.fastLinearToSlowEaseIn,
                                height: _validated == false ? 16 : 0,
                                padding: EdgeInsets.only(left: 5),
                                child: Text(
                                  'Please enter a name for this task.',
                                  style: TextStyle(
                                    color: isDark
                                        ? Color.alphaBlend(
                                            Colors.white30,
                                            Colors.pinkAccent[400],
                                          )
                                        : Colors.redAccent[400],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    _focusNode.unfocus();
                                    setState(
                                      () => _inProgress = !_inProgress,
                                    );
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    title: Text(
                                      'In Progress',
                                      style: TextStyle(
                                        color: _inProgress
                                            ? colorScheme.onSurface
                                            : isDark
                                                ? Colors.cyan[50]
                                                    .withOpacity(0.7)
                                                : colorScheme.onSurface
                                                    .withOpacity(0.7),
                                      ),
                                    ),
                                    trailing: Checkbox(
                                      activeColor: AppTheme.mainColor,
                                      value: _inProgress,
                                      checkColor: colorScheme.background,
                                      onChanged: (value) {
                                        _focusNode.unfocus();
                                        setState(
                                          () => _inProgress = value,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 14,
                              ),
                              SizedBox(
                                height: 52,
                                child: Material(
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 20,
                                  shadowColor: isDark
                                      ? Colors.black12
                                      : AppTheme.mainColor.withOpacity(0.5),
                                  color: AppTheme.mainColor,
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    splashColor: colorScheme.background
                                        .withOpacity(0.24),
                                    highlightColor: colorScheme.background
                                        .withOpacity(0.12),
                                    onTap: () {
                                      if (_taskName.isEmpty) {
                                        setState(() {
                                          _validated = false;
                                        });
                                      } else {
                                        var task = Task(
                                          name: _taskName,
                                          category: _inProgress
                                              ? TaskCategory.inProgress
                                              : TaskCategory.incomplete,
                                        );

                                        TaskNotifier.of(context, listen: false)
                                            .addTask(task);

                                        if (widget.goToTasks != null) {
                                          widget.goToTasks();
                                        }

                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        'Create',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                              color: colorScheme.background,
                                              letterSpacing: 0.4,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _slideUpAnim,
                      curve: Interval(0, 0.5),
                    ),
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _slideUpAnim,
                        curve: Curves.elasticOut,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Material(
                                color:
                                    isDark ? AppTheme.dark2 : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SystemPadding extends StatelessWidget {
  final Widget child;

  SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(
      padding: mediaQuery.viewInsets,
      duration: const Duration(milliseconds: 700),
      curve: Curves.fastLinearToSlowEaseIn,
      child: child,
    );
  }
}
