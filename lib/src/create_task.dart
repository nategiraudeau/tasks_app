import 'package:tasks_app/src/database/task.dart';
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
      duration: Duration(milliseconds: 600),
    )..forward();

    _focusNode.requestFocus();

    super.initState();
  }

  @override
  void dispose() {
    _slideUpAnim.dispose();
    _focusNode.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                      elevation: 52,
                      shadowColor: Colors.black12,
                      color: Colors.white,
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
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 60,
                              child: TextField(
                                cursorColor: Colors.black,
                                focusNode: _focusNode,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isNotEmpty) {
                                      _validated = true;
                                    }
                                    _taskName = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Task Name',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.1),
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
                                  color: Colors.redAccent[400],
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
                                onTap: () => setState(
                                  () => _inProgress = !_inProgress,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  title: Text(
                                    'In Progress',
                                    style: TextStyle(
                                      color: _inProgress
                                          ? Colors.black
                                          : Colors.black.withOpacity(0.7),
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    activeColor: AppTheme.mainColor,
                                    value: _inProgress,
                                    onChanged: (value) => setState(
                                      () => _inProgress = value,
                                    ),
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
                                shadowColor:
                                    AppTheme.mainColor.withOpacity(0.5),
                                color: AppTheme.mainColor,
                                child: InkWell(
                                  splashColor: Colors.white24,
                                  highlightColor: Colors.white12,
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
                                      'Finish',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                            color: Colors.white,
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
                              color: Colors.grey[300],
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
    );
  }
}
