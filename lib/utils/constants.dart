import 'package:flutter/material.dart';

//Green
const semearGreen = Color.fromARGB(255, 167, 205, 79);
const semearGreenWithOpacity10 = Color.fromARGB(25, 167, 205, 79);
const semearGreenWithOpacity30 = Color.fromARGB(76, 167, 205, 79);
const semearGreenWithOpacity50 = Color.fromARGB(76, 167, 205, 79);
const semearGreenGradient = LinearGradient(
  transform: GradientRotation(45.0),
  colors: [
    semearGreen,
    semearGreenWithOpacity30,
  ],
  stops: [0.5, 1.0],
);
const semearGreenAndDarkGreyGradient = LinearGradient(
  transform: GradientRotation(45.0),
  colors: [
    semearGreen,
    semearDarkGrey,
  ],
);

//Orange
const semearOrange = Color.fromARGB(255, 196, 115, 110);
const semearOrangeWithOpacity30 = Color.fromARGB(76, 196, 115, 110);
const semearOrangeGradient = LinearGradient(
  transform: GradientRotation(45.0),
  colors: [
    Colors.transparent,
    semearOrangeWithOpacity30,
  ],
  stops: [0.5, 1.0],
);

//Light Grey
const semearLightGrey = Color.fromARGB(255, 240, 240, 240);
const semearLightGreyWithOpacity30 = Color.fromARGB(76, 240, 240, 240);
const semearLightGreyWithOpacity50 = Color.fromARGB(128, 240, 240, 240);
const semearLightGreyGradient = LinearGradient(
  transform: GradientRotation(45.0),
  colors: [
    semearLightGrey,
    semearLightGreyWithOpacity30,
  ],
  stops: [0.5, 1.0],
);
const semearLightestGreyGradient = LinearGradient(
  transform: GradientRotation(45.0),
  colors: [
    semearLightGreyWithOpacity30,
    semearLightGreyWithOpacity50,
  ],
  stops: [0.5, 1.0],
);

//Grey
const semearGrey = Color.fromARGB(255, 30, 30, 30);

//Dark Grey
const semearDarkGrey = Color.fromARGB(255, 20, 20, 20);

//Shadows
const List<BoxShadow> boxShadowsGrey = [
  BoxShadow(
    color: semearGrey,
    offset: Offset(-1.0, 1.0),
    blurRadius: 1.5,
  ),
];
const List<BoxShadow> boxShadowsGreen = [
  BoxShadow(
    color: semearGreenWithOpacity50,
    offset: Offset(-1.0, 1.0),
    blurRadius: 1.5,
  ),
];
