import 'package:flutter/material.dart';

/// Converts a Flutter [Color] to a CSS hex string for the chart bridge.
String colorToCssHex(Color color) {
  // ignore: deprecated_member_use
  final value = color.value;
  final alpha = (value >> 24) & 0xff;
  final red = (value >> 16) & 0xff;
  final green = (value >> 8) & 0xff;
  final blue = value & 0xff;
  final channels =
      alpha == 0xff ? [red, green, blue] : [red, green, blue, alpha];
  return '#${channels.map((channel) => channel.toRadixString(16).padLeft(2, '0')).join()}';
}

List<String> colorsToCssHex(List<Color> colors) {
  return colors.map(colorToCssHex).toList();
}
