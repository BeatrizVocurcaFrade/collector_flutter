import 'package:collector_flutter/collector_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CollectorApp());
}

class CollectorApp extends StatefulWidget {
  const CollectorApp({super.key});
  @override
  State<CollectorApp> createState() => _CollectorAppState();
}

class _CollectorAppState extends State<CollectorApp> {
  final ResourceCollector collector = ResourceCollector();

  @override
  void initState() {
    super.initState();
    collector.start();
    _simulateNetwork();
  }

  Future<void> _simulateNetwork() async {
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/todos/1');
    await collector.network.get(uri);
    collector.recordEvent('custom_event', {
      'screen': 'dashboard',
      'time': DateTime.now().toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collector Dashboard Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Collector Flutter Demo')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Widget com RebuildObserver (demonstra rebuilds)
              RebuildObserver(
                widgetName: 'CounterWidget',
                onRebuild: (w) => debugPrint('Rebuilt $w'),
                child: CounterWidget(),
              ),
              const Divider(),
              // Dashboard completo
              SizedBox(height: 400, child: DashboardPage()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    collector.stop();
    super.dispose();
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Rebuild counter: $count', style: const TextStyle(fontSize: 20)),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: const Text('Incrementar (gera rebuild)'),
        ),
      ],
    );
  }
}
