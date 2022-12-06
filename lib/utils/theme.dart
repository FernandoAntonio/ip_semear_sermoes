import 'package:flutter/material.dart';

import 'constants.dart';

ThemeData getTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: semearDarkGrey,
    sliderTheme: const SliderThemeData(
      thumbColor: semearGreen,
      activeTrackColor: Colors.transparent,
      overlayColor: Colors.transparent,
      inactiveTrackColor: semearLightGrey,
      trackShape: SliderCustomTrackShape(),
    ),
    cardTheme: const CardTheme(color: semearGrey),
    appBarTheme:
        const AppBarTheme(foregroundColor: semearGreen, backgroundColor: semearDarkGrey),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: semearGreen),
    textButtonTheme:
        TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: semearGreen)),
    colorScheme: const ColorScheme.dark().copyWith(secondary: semearGreen),
  );
}

class SliderCustomTrackShape extends RoundedRectSliderTrackShape {
  const SliderCustomTrackShape();

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
}
