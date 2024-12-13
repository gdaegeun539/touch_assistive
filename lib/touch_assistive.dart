import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// 어세시티브 터치를 응용한 버튼은 아래 레포지토리의 코드를 응용했습니다.
// https://github.com/PJRadadiya/touch_assistive

class TouchAssistive extends StatefulWidget {
  final Widget child;
  final Offset initialOffset;
  final VoidCallback onPressed;
  final double buttonSize;
  final double disableOpacity;

  const TouchAssistive({
    super.key,
    required this.child,
    required this.initialOffset,
    required this.onPressed,
    required this.buttonSize,
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
  // Size size = Size.zero;
  Timer? timer;

  double? lastOffsetX;
  double? lastOffsetY;

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
    // FIXME: 빌드가 계속 일어나는 문제가 있다.
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Opacity(
        opacity: _isDragging ? 1.0 : widget.disableOpacity,
        child: Listener(
          onPointerMove: (PointerMoveEvent pointerMoveEvent) {
            _updatePosition(pointerMoveEvent);
            setState(() {
              isIdle = false;
              _isDragging = true;
            });
            _scheduleIdle();

            _setOffset(_offset);
          },
          onPointerUp: (PointerUpEvent pointerUpEvent) {
            bool isOffsetInCalibrationRange = _checkOffsetInCalibrationRange();
            if (isOffsetInCalibrationRange) {
              _isDragging = false;
            }

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
    // MARK: 샘플링 레이트 1000ms -> 500ms로 변경
    timer = Timer(const Duration(milliseconds: 500), () {
      if (_isDragging == false) {
        // 멈춘 후에는 마지막 오프셋을 업데이트한다.
        lastOffsetX = _offset.dx;
        lastOffsetY = _offset.dy;
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

    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    const double left = 0;
    const double top = 0;
    final right = width - widget.buttonSize;
    final bottom = height - (widget.buttonSize * 3);
    final middlePoint = width / 2;

    final topValue = max(min(offset.dy, bottom), top);
    // 가장자리에 버튼이 붙는 것을 원할 경우 아래 코드를 사용
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
    // 버튼이 움직인 위치에 남는 것을 원할 경우 아래 코드를 사용
    // final leftValue = max(min(offset.dx, right), left);
    setState(() {
      _offset = Offset(leftValue, topValue);
    });
  }

  /// 이전에 마지막으로 움직인 값과 지금 움직인 값이 오차범위(10픽셀) 내에 있는지 판단한다.
  ///
  /// 안드로이드의 경우 엣지로 인해 버튼을 누르는 것을 원했는데 움직이는 경우가 있어 이를 보정하기 위해 사용한다.
  bool _checkOffsetInCalibrationRange() {
    final isMoveXInCalibrationRange = lastOffsetX != null && (_offset.dx - lastOffsetX!) <= 10;
    final isMoveYInCalibrationRange = lastOffsetY != null && (_offset.dy - lastOffsetY!) <= 10;
    return isMoveXInCalibrationRange && isMoveYInCalibrationRange;
  }
}
