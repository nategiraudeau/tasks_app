import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/src/create_task.dart';
import 'package:tasks_app/src/notifiers/tasks_notifier.dart';
import 'package:tasks_app/src/overview.dart';
import 'package:tasks_app/src/theme.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/src/widgets/menu.dart';

import 'tasks.dart';

class TasksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskNotifier>.value(
      value: TaskNotifier(),
      child: MaterialApp(
        theme: AppTheme.themeData,
        routes: {
          '/': (_) => HomeScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool animate;

  const HomeScreen({Key key, this.animate = true}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController _slideAnim;
  AnimationController _contentAnim;

  var _pageController = PageController();
  var _drawerPageController = PageController(
    initialPage: 1,
  );

  var _isShowingDrawer = false;

  int _currentIndex = 0;

  void _handleChangeTab() {
    if (mounted) {
      setState(() {
        _currentIndex = _pageController.page.round();
      });
    }
  }

  void _handleShowDrawer() {
    if (mounted) {
      setState(() {
        _isShowingDrawer = _drawerPageController.page != 1.0;
      });
    }
  }

  void _showDrawer() {
    _drawerPageController.animateToPage(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  void _closeDrawer() {
    _drawerPageController.animateToPage(
      1,
      duration: Duration(milliseconds: 400),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  void _changeTab(int index) {
    if (_currentIndex != index) {
      try {
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn,
        );
      } catch (e) {}
    }
  }

  @override
  void initState() {
    assert(widget.animate != null);

    _slideAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
      value: widget.animate ? 0 : 1,
    );
    _contentAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
      value: widget.animate ? 0 : 1,
    );

    if (widget.animate) _startAnimation();

    _pageController.addListener(_handleChangeTab);
    _drawerPageController.addListener(_handleShowDrawer);

    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(_handleChangeTab);
    _pageController.dispose();

    _drawerPageController.removeListener(_handleShowDrawer);
    _drawerPageController.dispose();

    _slideAnim.dispose();
    _contentAnim.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      _slideAnim.forward();
      await Future.delayed(Duration(milliseconds: 100));
      _contentAnim.forward();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final slideUpTween = Tween<Offset>(
          begin: Offset(0, 0.3),
          end: Offset.zero,
        ).chain(CurveTween(
          curve: ElasticOutCurve(0.9),
        ));

        return Scaffold(
          body: PageView(
            controller: _drawerPageController,
            physics: _isShowingDrawer
                ? ClampingScrollPhysics()
                : NeverScrollableScrollPhysics(),
            children: [
              TasksAppDrawer(
                close: _closeDrawer,
              ),
              Scaffold(
                body: Stack(
                  children: <Widget>[
                    FadeTransition(
                      opacity: _slideAnim,
                      child: SlideTransition(
                        position: _slideAnim.drive(slideUpTween),
                        child: PageView(
                          controller: _pageController,
                          children: <Widget>[
                            Overview(
                              animate: widget.animate,
                              goToTasks: () {
                                _changeTab(1);
                              },
                            ),
                            Tasks(),
                          ],
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: Duration(
                          milliseconds: _currentIndex == 1 ? 800 : 500),
                      curve: _currentIndex == 1
                          ? Curves.elasticOut
                          : Curves.easeOutCirc,
                      bottom: _currentIndex == 1 ? 24 : -60,
                      right: 24,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: _currentIndex == 1 ? 56 : 40,
                        height: _currentIndex == 1 ? 56 : 40,
                        curve: Curves.fastLinearToSlowEaseIn,
                        child: Material(
                          elevation: 20,
                          color: AppTheme.mainColor,
                          borderRadius: BorderRadius.circular(20),
                          shadowColor: AppTheme.mainColor.withOpacity(0.6),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              createTask(context);
                            },
                            highlightColor: Colors.white12,
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 27,
                              ),
                            ),
                            splashColor: Colors.white24,
                          ),
                        ),
                      ),
                    ),

                    // Menu button
                    Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: SafeArea(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 58,
                                  width: 58,
                                  child: AnimatedOpacity(
                                    opacity: 1,
                                    duration: Duration(milliseconds: 200),
                                    child: Material(
                                      color: Colors.white.withOpacity(0.85),
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(40),
                                      ),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(40),
                                        clipBehavior: Clip.antiAlias,
                                        color: Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: IconButton(
                                            icon: Icon(FeatherIcons.menu),
                                            color: Colors.black87,
                                            onPressed: () {
                                              _showDrawer();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                bottomNavigationBar: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Divider(
                      height: 0,
                      color: Colors.black.withOpacity(0.04),
                      thickness: 2,
                    ),
                    SafeArea(
                      child: SizedBox(
                        height: 80,
                        child: Material(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                buildNavbarIcon(
                                  FeatherIcons.home,
                                  selected: _currentIndex == 0,
                                  onPressed: () => _changeTab(0),
                                ),
                                buildNavbarIcon(
                                  FeatherIcons.edit3,
                                  selected: _currentIndex == 1,
                                  onPressed: () => _changeTab(1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget buildNavbarIcon(IconData icon,
    {void Function() onPressed, bool selected = false}) {
  return SizedBox(
    width: 70,
    key: ValueKey(icon),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed ?? () {},
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: selected
                    ? Colors.greenAccent[400]
                    : Colors.black.withOpacity(0.7).withBlue(20),
                size: 25,
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 800),
                curve: Curves.fastLinearToSlowEaseIn,
                padding: selected ? EdgeInsets.only(top: 5) : null,
                height: selected ? 10 : 0,
                width: selected ? 5 : 0,
                child: SizedBox(
                  height: 5,
                  child: Material(
                    borderRadius: BorderRadius.circular(2.5),
                    color: Colors.greenAccent[400].withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
