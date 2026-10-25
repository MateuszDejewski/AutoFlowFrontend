import 'package:flutter/material.dart';

void navigateToClientScreen(BuildContext context, {required Widget screen}) {
  final navigator = Navigator.of(context);
  navigator.popUntil((route) => route.isFirst);
  navigator.push<void>(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    ),
  );
}
