library seekbar;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// SeekBar(
///   value: 0.5,
///   secondValue: 0.8,
///   progressColor: Colors.blue,
///   secondProgressColor: Colors.orange,
///   onStartTrackingTouch: () {
///     print('onStartTrackingTouch');
///   },
///   onProgressChanged: (value) {
///     print('onProgressChanged:$value');
///   },
///   onStopTrackingTouch: () {
///     print('onStopTrackingTouch');
///   },
/// )
class SeekBar extends StatefulWidget {
  final double progressWidth;
  final double thumbRadius;
  final double value;
  final double secondValue;
  final Color barColor;
  final Color progressColor;
  final Color secondProgressColor;
  final Color thumbColor;
  final Function? onStartTrackingTouch;
  final ValueChanged<double>? onProgressChanged;
  final Function? onStopTrackingTouch;
  final bool verticalPadding;
  final bool horizontalPadding;
  final Key? gestureDetectorKey;

  SeekBar({
    Key? key,
    this.gestureDetectorKey,
    this.progressWidth = 2.0,
    this.thumbRadius = 7.0,
    this.value = 0.0,
    this.secondValue = 0.0,
    this.barColor = const Color(0x73FFFFFF),
    this.progressColor = Colors.white,
    this.secondProgressColor = const Color(0xBBFFFFFF),
    this.thumbColor = Colors.white,
    this.onStartTrackingTouch,
    this.onProgressChanged,
    this.onStopTrackingTouch,
    this.verticalPadding = true,
    this.horizontalPadding = true,
  }) : super(key: key);

  @override
  _SeekBarState createState() {
    return _SeekBarState();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DoubleProperty('value', value));
    super.debugFillProperties(properties);
  }
}

class _SeekBarState extends State<SeekBar> {
  double _value = 0.0;
  double _secondValue = 0.0;

  bool _touchDown = false;
  double? _dragValue;

  _checkTouchPoint(BuildContext context, Offset touchPoint) {
    if (touchPoint.dx <= 0) {
      touchPoint = Offset(0, touchPoint.dy);
    }
    if (touchPoint.dx >= context.size!.width) {
      touchPoint = Offset(context.size!.width, touchPoint.dy);
    }
  }

  @override
  void initState() {
    _value = widget.value > 1
        ? 1
        : widget.value < 0
            ? 0
            : widget.value;
    _secondValue = widget.secondValue > 1
        ? 1
        : widget.secondValue < 0
            ? 0
            : widget.secondValue;
    super.initState();
  }

  @override
  void didUpdateWidget(SeekBar oldWidget) {
    _value = widget.value.clamp(0, 1);
    _secondValue = widget.secondValue.clamp(0, 1);
    super.didUpdateWidget(oldWidget);
  }

  double updateValue(BuildContext context, Offset touchPoint) {
    _value = touchPoint.dx / context.size!.width;
    return _dragValue = _value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.gestureDetectorKey,
      onHorizontalDragDown: (details) {
        debugPrint("[SeekBar] onHorizontalDragDown");

        RenderBox box = context.findRenderObject() as RenderBox;
        final touchPoint = box.globalToLocal(details.globalPosition);
        _checkTouchPoint(context, touchPoint);

        setState(() {
          updateValue(context, touchPoint);
          _touchDown = true;
        });

        widget.onStartTrackingTouch?.call();
      },
      onHorizontalDragUpdate: (details) {
        debugPrint("[SeekBar] onHorizontalDragUpdate");

        RenderBox box = context.findRenderObject() as RenderBox;
        final touchPoint = box.globalToLocal(details.globalPosition);
        _checkTouchPoint(context, touchPoint);

        final newValue = updateValue(context, touchPoint);
        setState(() {});

        widget.onProgressChanged?.call(newValue);
      },
      onHorizontalDragEnd: (details) {
        debugPrint("[SeekBar] onHorizontalDragEnd");

        _onGestureEnd();
      },
      onTap: () {
        debugPrint("[SeekBar] onTap");

        _onGestureEnd();
      },
      child: Container(
        constraints: BoxConstraints.expand(height: widget.thumbRadius * 2),
        child: CustomPaint(
          painter: _SeekBarPainter(
            progressWidth: widget.progressWidth,
            thumbRadius: widget.thumbRadius,
            value: _dragValue ?? _value,
            secondValue: _secondValue,
            barColor: widget.barColor,
            progressColor: widget.progressColor,
            secondProgressColor: widget.secondProgressColor,
            thumbColor: widget.thumbColor,
            touchDown: _touchDown,
            verticalPadding: widget.verticalPadding,
            horizontalPadding: widget.horizontalPadding,
          ),
        ),
      ),
    );
  }

  void _onGestureEnd() {
    if (_dragValue != null) {
      widget.onProgressChanged?.call(_dragValue!);
    }
    widget.onStopTrackingTouch?.call();

    setState(() {
      _touchDown = false;
      _dragValue = null;
    });
  }
}

class _SeekBarPainter extends CustomPainter {
  final double progressWidth;
  final double thumbRadius;
  final double value;
  final double secondValue;
  final Color barColor;
  final Color progressColor;
  final Color secondProgressColor;
  final Color thumbColor;
  final bool touchDown;
  final bool verticalPadding;
  final bool horizontalPadding;

  _SeekBarPainter({
    required this.progressWidth,
    required this.thumbRadius,
    required this.value,
    required this.secondValue,
    required this.barColor,
    required this.progressColor,
    required this.secondProgressColor,
    required this.thumbColor,
    required this.touchDown,
    required this.verticalPadding,
    required this.horizontalPadding,
  });

  @override
  bool shouldRepaint(_SeekBarPainter old) {
    return value != old.value || secondValue != old.secondValue || touchDown != old.touchDown;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.square
      ..strokeWidth = progressWidth;

    final centerY = verticalPadding ? (size.height / 2.0) : size.height;
    final paddingX = (horizontalPadding ? thumbRadius : 0.0);
    final barLength = size.width - paddingX * 2.0;

    final Offset startPoint = Offset(paddingX, centerY);
    final Offset endPoint = Offset(size.width - paddingX, centerY);
    final Offset progressPoint = Offset(barLength * value + paddingX, centerY);
    final Offset secondProgressPoint = Offset(barLength * secondValue + paddingX, centerY);

    paint.color = barColor;
    canvas.drawLine(startPoint, endPoint, paint);

    paint.color = secondProgressColor;
    canvas.drawLine(startPoint, secondProgressPoint, paint);

    paint.color = progressColor;
    canvas.drawLine(startPoint, progressPoint, paint);

    final Paint thumbPaint = Paint()..isAntiAlias = true;

    thumbPaint.color = Colors.transparent;
    canvas.drawCircle(progressPoint, centerY, thumbPaint);

    if (touchDown) {
      thumbPaint.color = thumbColor.withOpacity(0.6);
      canvas.drawCircle(progressPoint, thumbRadius, thumbPaint);
    }

    thumbPaint.color = thumbColor;
    canvas.drawCircle(progressPoint, thumbRadius * 0.75, thumbPaint);
  }
}
