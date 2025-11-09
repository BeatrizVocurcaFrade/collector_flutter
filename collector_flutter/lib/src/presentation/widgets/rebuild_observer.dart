import 'package:flutter/widgets.dart';
import '../../core/utils.dart';

typedef RebuildCallback = void Function(String widgetName);

/// Widget que observa rebuilds do subtree e dispara callback.
/// Uso: envolver um subtree com RebuildObserver(widgetName: 'MyWidget', onRebuild: (...))
class RebuildObserver extends StatefulWidget {
  final Widget child;
  final String widgetName;
  final RebuildCallback? onRebuild;

  const RebuildObserver({
    required this.child,
    required this.widgetName,
    this.onRebuild,
    super.key,
  });

  @override
  State<RebuildObserver> createState() => _RebuildObserverState();
}

class _RebuildObserverState extends State<RebuildObserver> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    _count++;
    widget.onRebuild?.call(widget.widgetName);
    CollectorUtils.safeLog(
      'RebuildObserver',
      '${widget.widgetName} rebuilt ($_count)',
    );
    return widget.child;
  }
}
