import 'package:flutter/material.dart';

/// A wrapper widget that mixes in [AutomaticKeepAliveClientMixin] to prevent
/// its child from being disposed when scrolled offscreen in a [TabBarView] or [PageView].
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({
    super.key,
    required this.child,
  });

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
