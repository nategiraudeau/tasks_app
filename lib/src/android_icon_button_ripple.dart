import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

const Duration _kSplashDuration = Duration(milliseconds: 180);
const Duration _kSplashFadeDuration = Duration(milliseconds: 140);
const Duration _kSplashFadeInDuration = Duration(milliseconds: 10);

const Curve _kSplashCurve = Curves.easeOutQuart;

class AndroidIconButtonRippleFactory extends InteractiveInkFeatureFactory {
  const AndroidIconButtonRippleFactory();

  @override
  InteractiveInkFeature create({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required Offset position,
    @required Color color,
    @required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
    VoidCallback onRemoved,
  }) {
    return AndroidIconButtonRipple(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      onRemoved: onRemoved,
      textDirection: textDirection,
    );
  }
}

class AndroidIconButtonRipple extends InteractiveInkFeature {
  AndroidIconButtonRipple({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required TextDirection textDirection,
    Offset position,
    Color color,
    bool containedInkWell = false,
    RectCallback rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    VoidCallback onRemoved,
  })  : assert(textDirection != null),
        _position = Offset(24, 24),
        _borderRadius = borderRadius ?? BorderRadius.zero,
        _customBorder = customBorder,
        _targetRadius = 18,
        _clipCallback = (() {
          return Rect.fromLTRB(0, 0, 100000, 100000);
        }),
        _repositionToReferenceBox = !containedInkWell,
        _textDirection = textDirection,
        super(
            controller: controller,
            referenceBox: referenceBox,
            color: color,
            onRemoved: onRemoved) {
    assert(_borderRadius != null);
    _radiusController =
        AnimationController(duration: _kSplashDuration, vsync: controller.vsync)
          ..addListener(controller.markNeedsPaint)
          ..forward();
    _radius = _radiusController.drive(CurveTween(curve: _kSplashCurve));
    _alphaController = AnimationController(
        duration: _kSplashFadeDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleAlphaStatusChanged);
    _alpha = _alphaController.drive(IntTween(
      begin: color.alpha,
      end: 0,
    ));

    _alphaFadeInController = AnimationController(
        duration: _kSplashFadeInDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleAlphaFadeInStatusChanged);
    _alphaFadeIn = _alphaFadeInController.drive(IntTween(
      begin: color.alpha,
      end: 0,
    ));

    _alphaFadeInController.forward();

    controller.addInkFeature(this);
  }

  final Offset _position;
  final BorderRadius _borderRadius;
  final ShapeBorder _customBorder;
  final double _targetRadius;
  final RectCallback _clipCallback;
  final bool _repositionToReferenceBox;
  final TextDirection _textDirection;

  Animation<double> _radius;
  AnimationController _radiusController;

  Animation<int> _alpha;
  AnimationController _alphaController;
  Animation<int> _alphaFadeIn;
  AnimationController _alphaFadeInController;

  static const InteractiveInkFeatureFactory splashFactory =
      AndroidIconButtonRippleFactory();

  @override
  void confirm() {
    _radiusController.drive(CurveTween(curve: _kSplashCurve));
    Future.delayed(Duration(milliseconds: 320)).then((_) {
      _alphaController.forward();
    });
  }

  @override
  void cancel() {
    _alphaController?.forward();
  }

  void _handleAlphaStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) dispose();
  }

  void _handleAlphaFadeInStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _alphaFadeInController.dispose();
      _alphaFadeInController = null;
    }
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _alphaController.dispose();
    _alphaController = null;
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final Paint paint = Paint()
      ..color = color.withAlpha(_alpha.value - _alphaFadeIn.value);
    Offset center = _position;
    if (_repositionToReferenceBox)
      center = Offset.lerp(center, referenceBox.size.center(Offset.zero),
          _radiusController.value);
    final Offset originOffset = MatrixUtils.getAsTranslation(transform);
    canvas.save();
    if (originOffset == null) {
      canvas.transform(transform.storage);
    } else {
      canvas.translate(originOffset.dx, originOffset.dy);
    }
    if (_clipCallback != null) {
      final Rect rect = _clipCallback();
      if (_customBorder != null) {
        canvas.clipPath(
            _customBorder.getOuterPath(rect, textDirection: _textDirection));
      } else if (_borderRadius != BorderRadius.zero) {
        canvas.clipRRect(RRect.fromRectAndCorners(
          rect,
          topLeft: _borderRadius.topLeft,
          topRight: _borderRadius.topRight,
          bottomLeft: _borderRadius.bottomLeft,
          bottomRight: _borderRadius.bottomRight,
        ));
      } else {
        canvas.clipRect(rect);
      }
    }

    final double k = _targetRadius * 1.05;
    final double m = _targetRadius * .25;
    canvas.drawCircle(center, _radius.value * k + m, paint);
    canvas.restore();
  }
}
