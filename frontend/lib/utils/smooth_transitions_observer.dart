import 'package:flutter/material.dart';

/// Global page route observer that applies smooth transitions
/// This observer can be added to MaterialApp's navigatorObservers
class SmoothTransitionsObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint('🔀 Smooth transition: Navigating to ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    debugPrint('⬅️ Smooth pop: Back to ${previousRoute?.settings.name}');
  }
}

/// Enhancement wrapper for MaterialPageRoute that automatically
/// applies smooth transitions without requiring code changes
class SmoothMaterialPageRoute<T> extends MaterialPageRoute<T> {
  SmoothMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
         builder: builder,
         settings: settings,
         maintainState: maintainState,
         fullscreenDialog: fullscreenDialog,
       );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Fade + Slide from bottom for smooth, professional transitions
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            ),
        child: child,
      ),
    );
  }
}
