import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImmersiveModeGuard extends StatefulWidget {
  final Widget child;

  const ImmersiveModeGuard({super.key, required this.child});

  static Future<void> enable() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  State<ImmersiveModeGuard> createState() => _ImmersiveModeGuardState();
}

class _ImmersiveModeGuardState extends State<ImmersiveModeGuard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ImmersiveModeGuard.enable();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ImmersiveModeGuard.enable();
    }
  }

  @override
  void didChangeMetrics() {
    ImmersiveModeGuard.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
