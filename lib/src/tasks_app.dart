import 'dart:io';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/src/create_task.dart';
import 'package:tasks_app/src/notifiers/tasks_notifier.dart';
import 'package:tasks_app/src/overview.dart';
import 'package:tasks_app/src/theme.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/src/widgets/icon_button.dart';
import 'package:tasks_app/src/widgets/menu.dart';

import 'tasks.dart';

class TasksApp extends StatefulWidget {
  @override
  _TasksAppState createState() => _TasksAppState();
}

class _TasksAppState extends State<TasksApp> {
  TaskNotifier _notifier;

  @override
  void initState() {
    _notifier = TaskNotifier();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskNotifier>.value(
      value: _notifier,
      child: Builder(
        builder: (context) {
          final notifier = TaskNotifier.of(context);

          final isDark = notifier?.isDark ?? false;

          return MaterialApp(
            theme: isDark ? AppTheme.darkThemeData : AppTheme.themeData,
            debugShowCheckedModeBanner: false,
            routes: {
              '/': (_) => HomeScreen(),
            },
            initialRoute: '/',
          );
        },
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
  AnimationController _splashAnim;

  var _pageController = PageController();
  var _drawerPageController = PageController(
    initialPage: 1,
  );

  var _hasAnimated = false;

  int _currentIndex = 0;

  void _handleChangeTab() {
    if (mounted) {
      setState(() {
        _currentIndex = _pageController.page.round();
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
      duration: Duration(milliseconds: 240),
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

    _splashAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
      value: widget.animate ? 0 : 1,
    );
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

    _pageController.addListener(_handleChangeTab);

    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(_handleChangeTab);
    _pageController.dispose();

    _drawerPageController.dispose();

    _slideAnim.dispose();
    _contentAnim.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    try {
      _splashAnim.forward();
      await Future.delayed(Duration(milliseconds: 500));
      _slideAnim.forward();
      await Future.delayed(Duration(milliseconds: 100));
      _contentAnim.forward();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final notifier = TaskNotifier.of(context);

    final ready = notifier?.ready ?? false;

    return Stack(
      children: [
        Scaffold(),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 1100),
          switchInCurve: Curves.ease,
          switchOutCurve: Curves.ease,
          child: Builder(
            key: ValueKey(ready),
            builder: (context) {
              if (!ready) {
                return Container();
              }

              if (widget.animate && !_hasAnimated) _startAnimation();

              final slideUpTween = Tween<Offset>(
                begin: Offset(0, 0.3),
                end: Offset.zero,
              ).chain(CurveTween(
                curve: Curves.fastLinearToSlowEaseIn,
              ));

              final isDark = notifier?.isDark ?? false;

              return Scaffold(
                resizeToAvoidBottomInset: false,
                body: PageView(
                  controller: _drawerPageController,
                  physics: ClampingScrollPhysics(),
                  children: [
                    TasksAppDrawer(
                      close: _closeDrawer,
                    ),
                    Scaffold(
                      resizeToAvoidBottomInset: false,
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
                                elevation: isDark ? 24 : 20,
                                color: AppTheme.mainColor,
                                borderRadius: BorderRadius.circular(20),
                                shadowColor: isDark
                                    ? Colors.black
                                    : AppTheme.mainColor.withOpacity(0.6),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    createTask(context);
                                  },
                                  highlightColor: Colors.white12,
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      size: isDark ? 30 : 27,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 58,
                                        width: 58,
                                        child: AnimatedOpacity(
                                          opacity: 1,
                                          duration: Duration(milliseconds: 200),
                                          child: Material(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor
                                                .withOpacity(0.85),
                                            borderRadius:
                                                BorderRadius.horizontal(
                                              right: Radius.circular(40),
                                            ),
                                            child: Center(
                                              child: TasksIconButton(
                                                icon: FeatherIcons.menu,
                                                onPressed: () {
                                                  _showDrawer();
                                                },
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
                      bottomNavigationBar: SlideTransition(
                        position: _contentAnim.drive(
                          Tween(
                            begin: Offset(0, 1),
                            end: Offset.zero,
                          ).chain(
                            CurveTween(
                              curve: Interval(
                                0.2,
                                1,
                                curve: Curves.fastLinearToSlowEaseIn,
                              ),
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          onHorizontalDragStart: (_) {},
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Divider(
                                height: 0,
                                thickness: 2,
                              ),
                              SafeArea(
                                child: SizedBox(
                                  height: 80,
                                  child: Material(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          NavbarIcon(
                                            FeatherIcons.home,
                                            selected: _currentIndex == 0,
                                            onPressed: () => _changeTab(0),
                                          ),
                                          NavbarIcon(
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
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // SlideTransition(
        //   position: _splashAnim.drive(
        //     Tween(
        //       begin: Offset.zero,
        //       end: Offset(0, -1),
        //     ).chain(
        //       CurveTween(curve: Curves.easeInOutExpo),
        //     ),
        //   ),
        //   child: Scaffold(
        //     backgroundColor: Theme.of(context).primaryColor,
        //   ),
        // ),
      ],
    );
  }
}

class NavbarIcon extends StatefulWidget {
  const NavbarIcon(
    this.icon, {
    Key key,
    this.selected = false,
    this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final bool selected;
  final void Function() onPressed;

  @override
  _NavbarIconState createState() => _NavbarIconState();
}

class _NavbarIconState extends State<NavbarIcon> {
  @override
  Widget build(BuildContext context) {
    final notifier = TaskNotifier.of(context);
    final tapChild = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            widget.icon,
            color: widget.selected
                ? Theme.of(context).primaryColor
                : notifier?.isDark ?? false
                    ? Colors.white70
                    : Colors.black.withOpacity(0.7).withBlue(20),
            size: 25,
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 800),
            curve: Curves.fastLinearToSlowEaseIn,
            padding: widget.selected ? EdgeInsets.only(top: 5) : null,
            height: widget.selected ? 10 : 0,
            width: widget.selected ? 5 : 0,
            child: SizedBox(
              height: 5,
              child: Material(
                borderRadius: BorderRadius.circular(2.5),
                color: widget.selected
                    ? Colors.greenAccent[400].withOpacity(0.8)
                    : Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: 70,
      key: ValueKey(widget.icon),
      child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Platform.isAndroid
              ? InkWell(
                  onTap: widget.onPressed ?? () {},
                  child: tapChild,
                )
              : CupertinoButton(
                  onPressed: widget.onPressed ?? () {},
                  child: tapChild,
                )),
    );
  }
}
