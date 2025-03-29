import 'package:flutter/material.dart';
import 'package:credit_mania/utils/asset_images.dart';

class BackgroundImage extends StatelessWidget {
  final Widget child;

  const BackgroundImage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetImages.backgroundWood),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
