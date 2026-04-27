import 'package:flutter/material.dart';

/// Design tokens — corner radii.
abstract final class AppRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
}
