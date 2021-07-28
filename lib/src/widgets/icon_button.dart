import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/src/android_icon_button_ripple.dart';

class TasksIconButton extends StatefulWidget {
  const TasksIconButton({
    Key key,
    this.onPressed,
    this.icon,
    this.iconSize,
    this.color,
    this.iOSHighlight = false,
  }) : super(key: key);

  final Function onPressed;
  final IconData icon;
  final double iconSize;
  final Color color;
  final bool iOSHighlight;

  @override
  _TasksIconButtonState createState() => _TasksIconButtonState();
}

class _TasksIconButtonState extends State<TasksIconButton> {
  @override
  Widget build(BuildContext context) {
    final tapChild = Icon(
      widget.icon,
      size: widget.iconSize ?? 24,
      color: widget.color ??
          Theme.of(context).colorScheme.onBackground.withOpacity(0.87),
    );

    return Material(
      borderRadius: Platform.isAndroid ? null : BorderRadius.circular(40),
      clipBehavior: Platform.isAndroid ? Clip.none : Clip.antiAlias,
      color: Colors.transparent,
      child: SizedBox(
        height: 48,
        width: 48,
        child: Platform.isAndroid || widget.iOSHighlight
            ? InkWell(
                child: tapChild,
                onTap: widget.onPressed,
                splashFactory: AndroidIconButtonRipple.splashFactory,
              )
            : SizedBox(
                width: 48,
                height: 48,
                child: CupertinoButton(
                  child: tapChild,
                  onPressed: widget.onPressed,
                ),
              ),
      ),
    );
  }
}
