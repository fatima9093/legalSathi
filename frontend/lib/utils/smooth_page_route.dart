import 'package:flutter/material.dart';

/// Custom PageRoute with smooth fade and slide transition
class SmoothPageRoute<T> extends PageRoute<T> {
  final Widget page;
  final String? name;
  final Duration duration;
  final Curve curve;
  final bool slideFromBottom;

  SmoothPageRoute({
    required this.page,
    this.name,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
    this.slideFromBottom = true,
  }) : super(settings: RouteSettings(name: name));

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = slideFromBottom
        ? Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        : Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero);

    return SlideTransition(
      position: animation.drive(tween.chain(CurveTween(curve: curve))),
      child: FadeTransition(
        opacity: animation.drive(CurveTween(curve: curve)),
        child: child,
      ),
    );
  }
}

/// Smooth fade-only page route (faster, minimal)
class SmoothFadePageRoute<T> extends PageRoute<T> {
  final Widget page;
  final String? name;
  final Duration duration;
  final Curve curve;

  SmoothFadePageRoute({
    required this.page,
    this.name,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutQuad,
  }) : super(settings: RouteSettings(name: name));

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: curve)),
      child: child,
    );
  }
}

/// Smooth scale + fade page route (modern look)
class SmoothScalePageRoute<T> extends PageRoute<T> {
  final Widget page;
  final String? name;
  final Duration duration;
  final Curve curve;

  SmoothScalePageRoute({
    required this.page,
    this.name,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOutCubic,
  }) : super(settings: RouteSettings(name: name));

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: animation.drive(
        Tween<double>(begin: 0.95, end: 1.0).chain(CurveTween(curve: curve)),
      ),
      child: FadeTransition(
        opacity: animation.drive(CurveTween(curve: curve)),
        child: child,
      ),
    );
  }
}

/// Smooth slide page route (horizontal)
class SmoothSlidePageRoute<T> extends PageRoute<T> {
  final Widget page;
  final String? name;
  final Duration duration;
  final Curve curve;

  SmoothSlidePageRoute({
    required this.page,
    this.name,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
  }) : super(settings: RouteSettings(name: name));

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve)),
      ),
      child: FadeTransition(
        opacity: animation.drive(CurveTween(curve: curve)),
        child: child,
      ),
    );
  }
}

/// Helper extension for easy navigation
extension SmoothNavigation on NavigatorState {
  Future<T?> pushSmooth<T>(
    Widget page, {
    String? name,
    Duration duration = const Duration(milliseconds: 400),
    bool slideFromBottom = true,
  }) {
    return push<T>(
      SmoothPageRoute<T>(
        page: page,
        name: name,
        duration: duration,
        slideFromBottom: slideFromBottom,
      ),
    );
  }

  Future<T?> pushReplacementSmooth<T>(
    Widget page, {
    String? name,
    Duration duration = const Duration(milliseconds: 400),
    bool slideFromBottom = true,
  }) {
    return pushReplacement<T, T>(
      SmoothPageRoute<T>(
        page: page,
        name: name,
        duration: duration,
        slideFromBottom: slideFromBottom,
      ),
    );
  }

  Future<T?> pushFade<T>(
    Widget page, {
    String? name,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return push<T>(
      SmoothFadePageRoute<T>(page: page, name: name, duration: duration),
    );
  }

  Future<T?> pushScale<T>(
    Widget page, {
    String? name,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return push<T>(
      SmoothScalePageRoute<T>(page: page, name: name, duration: duration),
    );
  }
}

/// Helper for smooth dialogs
Future<T?> showSmoothDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Curve curve = Curves.easeInOutCubic,
  Duration duration = const Duration(milliseconds: 300),
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: animation.drive(
          Tween<double>(begin: 0.9, end: 1.0).chain(CurveTween(curve: curve)),
        ),
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: curve)),
          child: child,
        ),
      );
    },
    transitionDuration: duration,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  );
}

/// Helper for smooth bottom sheets
Future<T?> showSmoothBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Curve curve = Curves.easeInOutCubic,
  Duration duration = const Duration(milliseconds: 350),
  bool isScrollControlled = false,
  Color? barrierColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: isScrollControlled,
    barrierColor: barrierColor,
    transitionAnimationController: AnimationController(
      duration: duration,
      vsync: Scaffold.of(context),
    ),
  );
}
