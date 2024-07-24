import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class TypewriterAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250.0,
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Waiting for reply...',
              textAlign: TextAlign.center,
              textStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              speed: const Duration(milliseconds: 60),
            ),
          ],

          repeatForever: true,
          pause: const Duration(milliseconds: 1000),
          displayFullTextOnTap: true,
          stopPauseOnTap: true,
        )
      ),
    );
  }
}