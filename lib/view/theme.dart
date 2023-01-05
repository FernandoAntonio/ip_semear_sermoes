import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/constants.dart';

ThemeData getTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: semearDarkGrey,
    sliderTheme: const SliderThemeData(
      thumbColor: semearGreen,
      activeTrackColor: semearGreen,
      inactiveTrackColor: semearLightGreyWithOpacity30,
      trackShape: GradientRectSliderTrackShape(),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0),
    ),
    cardTheme: const CardTheme(color: semearGrey),
    appBarTheme:
        const AppBarTheme(foregroundColor: semearGreen, backgroundColor: semearDarkGrey),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: semearGreen),
    textButtonTheme:
        TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: semearGreen)),
    colorScheme: const ColorScheme.dark().copyWith(secondary: semearGreen),
    checkboxTheme: const CheckboxThemeData(
      fillColor: MaterialStatePropertyAll(Colors.transparent),
      checkColor: MaterialStatePropertyAll(semearGreen),
      side: BorderSide(color: semearOrange),
    ),
  );
}

class GradientRectSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const GradientRectSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double? trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    LinearGradient activeGradient = LinearGradient(
      colors: [
        sliderTheme.activeTrackColor!,
        semearGrey,
      ],
    );

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeGradientRect = Rect.fromLTRB(
      trackRect.left,
      (textDirection == TextDirection.ltr)
          ? trackRect.top - (additionalActiveTrackHeight / 2)
          : trackRect.top,
      thumbCenter.dx,
      (textDirection == TextDirection.ltr)
          ? trackRect.bottom + (additionalActiveTrackHeight / 2)
          : trackRect.bottom,
    );

    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..shader = activeGradient.createShader(activeGradientRect)
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular(trackRect.height / 2 + 1);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr) ? activeTrackRadius : trackRadius,
        bottomLeft:
            (textDirection == TextDirection.ltr) ? activeTrackRadius : trackRadius,
      ),
      leftTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topRight: (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
        bottomRight:
            (textDirection == TextDirection.rtl) ? activeTrackRadius : trackRadius,
      ),
      rightTrackPaint,
    );
  }
}

class CustomSliderThumbShape extends SliderComponentShape {
  final double thumbSize;

  const CustomSliderThumbShape({this.thumbSize = 10.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromWidth(thumbSize);
  }

  @override
  Future<void> paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) async {
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    Path path = Path();
    const Size size = Size(7.11201, 10.4987);
    final double xScaling = 1.2 / size.width;
    final double yScaling = 1.7 / size.height;
    final double xOffset = center.dx - size.width;

    path.lineTo(xOffset + 1.06 * xScaling, 8.12 * yScaling);
    path.cubicTo(
      xOffset + 0.97 * xScaling,
      2.38 * yScaling,
      xOffset + 4.69 * xScaling,
      0.84 * yScaling,
      xOffset + 8.5 * xScaling,
      0.75 * yScaling,
    );
    path.cubicTo(
      xOffset + 8.5 * xScaling,
      0.75 * yScaling,
      xOffset + 74.42 * xScaling,
      0.2 * yScaling,
      xOffset + 74.87 * xScaling,
      0.16 * yScaling,
    );
    path.cubicTo(
      xOffset + 80.91 * xScaling,
      0.2 * yScaling,
      xOffset + 82.69 * xScaling,
      3.98 * yScaling,
      xOffset + 82.75 * xScaling,
      8 * yScaling,
    );
    path.cubicTo(
      xOffset + 82.75 * xScaling,
      8 * yScaling,
      xOffset + 83.03 * xScaling,
      80.12 * yScaling,
      xOffset + 82.96 * xScaling,
      80.74 * yScaling,
    );
    path.cubicTo(
      xOffset + 83.25 * xScaling,
      86.86 * yScaling,
      xOffset + 81 * xScaling,
      88.25 * yScaling,
      xOffset + 81 * xScaling,
      88.25 * yScaling,
    );
    path.cubicTo(
      xOffset + 81 * xScaling,
      88.25 * yScaling,
      xOffset + 46.98 * xScaling,
      122.33 * yScaling,
      xOffset + 46.75 * xScaling,
      122.5 * yScaling,
    );
    path.cubicTo(
      xOffset + 43.98 * xScaling,
      124.6 * yScaling,
      xOffset + 40.42 * xScaling,
      124.38 * yScaling,
      xOffset + 38.75 * xScaling,
      122.75 * yScaling,
    );
    path.cubicTo(
      xOffset + 38.75 * xScaling,
      122.5 * yScaling,
      xOffset + 4.16 * xScaling,
      88.31 * yScaling,
      xOffset + 3.89 * xScaling,
      88.04 * yScaling,
    );
    path.cubicTo(
      xOffset + 2.49 * xScaling,
      86.78 * yScaling,
      xOffset + 1.02 * xScaling,
      84.72 * yScaling,
      xOffset + 0.98 * xScaling,
      82.22 * yScaling,
    );
    path.cubicTo(
      xOffset + 1.05 * xScaling,
      81.91 * yScaling,
      xOffset + 1.06 * xScaling,
      8.78 * yScaling,
      xOffset + 1.06 * xScaling,
      8.12 * yScaling,
    );
    path.cubicTo(
      xOffset + 1.06 * xScaling,
      8.12 * yScaling,
      xOffset + 1.06 * xScaling,
      8.12 * yScaling,
      xOffset + 1.06 * xScaling,
      8.12 * yScaling,
    );

    final Canvas canvas = context.canvas;
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    canvas.drawPath(
      path,
      Paint()..color = colorTween.evaluate(enableAnimation)!,
    );
  }
}
