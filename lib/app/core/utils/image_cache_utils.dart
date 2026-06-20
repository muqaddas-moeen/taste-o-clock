import 'package:flutter/material.dart';

class ImageCacheSize {
  ImageCacheSize._();

  static int memWidth(BuildContext context, double logicalWidth) {
    return (logicalWidth * MediaQuery.devicePixelRatioOf(context)).round();
  }

  static int memHeight(BuildContext context, double logicalHeight) {
    return (logicalHeight * MediaQuery.devicePixelRatioOf(context)).round();
  }
}
