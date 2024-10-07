import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class TouchAssistive extends StatefulWidget {
  final Widget child;
  final Offset initialOffset;
  final VoidCallback onPressed;
  final EdgeInsets margin;
  final bool shouldStickToSide;
  final double buttonSize;
  final double disableOpacity;

  const TouchAssistive({
    super.key,
    required this.child,
    required this.initialOffset,
    required this.onPressed,
    required this.buttonSize,
    this.margin = const EdgeInsets.all(8.0),
    this.shouldStickToSide = true,
    this.disableOpacity = 0.5,
  });

  @override
  State<StatefulWidget> createState() => _TouchAssistiveState();
}

class _TouchAssistiveState extends State<TouchAssistive> {
  bool _isDragging = false;
  late Offset _offset;
  late Offset largerOffset = _offset;
  bool isIdle = true;
  Size size = Size.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent) {
    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Opacity(
        opacity: _isDragging ? 1.0 : widget.disableOpacity,
        child: Listener(
          onPointerMove: (PointerMoveEvent pointerMoveEvent) {
            _updatePosition(pointerMoveEvent);

            setState(() {
              _isDragging = true;
            });
            _scheduleIdle();

            _setOffset(_offset);
          },
          onPointerUp: (PointerUpEvent pointerUpEvent) {
            if (_isDragging) {
              setState(() {
                _isDragging = false;
              });
              _scheduleIdle();

              _setOffset(_offset);
            } else {
              widget.onPressed();
            }
          },
          child: widget.child,
        ),
      ),
    );
  }

  void _scheduleIdle() {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 1), () {
      if (_isDragging == false) {
        setState(() {
          isIdle = true;
        });
      }
    });
  }

  void _setOffset(Offset offset, [bool shouldUpdateLargerOffset = true]) {
    if (shouldUpdateLargerOffset) {
      largerOffset = offset;
    }

    if (_isDragging) {
      setState(() {
        _offset = offset;
      });
      return;
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    const double left = 0;
    const double top = 0;
    final right = width - widget.buttonSize;
    final bottom = height - (widget.buttonSize*3);
    final middlePoint = width / 2;

    final topValue = max(min(offset.dy, bottom), top);
    final leftValue = max(
      min(
        topValue == bottom || topValue == top
            ? offset.dx
            : offset.dx < middlePoint
                ? left
                : right,
        right,
      ),
      left,
    );
    setState(() {
      _offset = Offset(leftValue, topValue);
    });
  }
}
