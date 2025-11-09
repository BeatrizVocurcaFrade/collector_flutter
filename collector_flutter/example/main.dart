import 'dart:math';
import 'package:collector_flutter/collector_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() => runApp(const CollectorApp());

class CollectorApp extends StatefulWidget {
  const CollectorApp({super.key});

  @override
  State<CollectorApp> createState() => _CollectorAppState();
}

class _CollectorAppState extends State<CollectorApp>
    with SingleTickerProviderStateMixin {
  final ResourceCollector collector = ResourceCollector();
  final Random _rand = Random();

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    collector.start();
    _simulateNetwork();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _simulateNetwork() async {
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/todos/1');
    collector.recordEvent('init_network', {
      'time': DateTime.now().toIso8601String(),
    });
    await collector.network.get(uri);
  }

  Future<void> _generateJank() async {
    debugPrint('🔥 Gerando jank pesado...');
    final start = DateTime.now();
    while (DateTime.now().difference(start).inMilliseconds < 2500) {
      List.generate(40000, (i) => i * i);
    }
    collector.recordEvent('simulate_jank', {'duration_ms': 2500});
  }

  Future<void> _simulateHighMemory() async {
    debugPrint('🧠 Simulando uso intenso de memória...');
    final buffers = List.generate(3, (_) => Uint8List(150 * 1024 * 1024));
    await Future.delayed(const Duration(seconds: 2));
    buffers.clear();
    collector.recordEvent('simulate_memory', {'size_mb': 150});
  }

  Future<void> _simulateNetworkSpam() async {
    debugPrint('🌐 Disparando requisições simultâneas...');
    final uri = Uri.parse(
      'https://jsonplaceholder.typicode.com/todos/${_rand.nextInt(10) + 1}',
    );
    await Future.wait(List.generate(20, (_) => http.get(uri)));
    collector.recordEvent('simulate_network', {'count': 20});
  }

  void _simulateRebuilds() {
    debugPrint('⚙️ Gerando rebuilds excessivos...');
    for (int i = 0; i < 50; i++) {
      setState(() {});
    }
    collector.recordEvent('simulate_rebuilds', {'count': 50});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collector Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueAccent),
      home: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 2,
          centerTitle: true,
          title: const Text(
            '📱 Collector Flutter Demo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFF9FAFB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: _DashboardContent(collector: collector),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: _BottomActionBar(
            onJank: _generateJank,
            onMemory: _simulateHighMemory,
            onNetwork: _simulateNetworkSpam,
            onRebuilds: _simulateRebuilds,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    collector.stop();
    _controller.dispose();
    super.dispose();
  }
}

//
// ──────────────────────────────── DASHBOARD ────────────────────────────────
//
class _DashboardContent extends StatelessWidget {
  final ResourceCollector collector;
  const _DashboardContent({required this.collector});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const IntroCard(),
          const SizedBox(height: 20),
          DashboardPage(collector: collector),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

//
// ──────────────────────────────── CARTÃO INTRO ────────────────────────────────
//
class IntroCard extends StatelessWidget {
  const IntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.blueAccent.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.15),
              Colors.blue.shade100.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Text(
          "Simule situações de carga, consumo e jank para testar o coletor em tempo real.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
      ),
    );
  }
}

//
// ──────────────────────────────── BARRA INFERIOR PERSONALIZADA ────────────────────────────────
//
class _BottomActionBar extends StatelessWidget {
  final VoidCallback onJank;
  final VoidCallback onMemory;
  final VoidCallback onNetwork;
  final VoidCallback onRebuilds;

  const _BottomActionBar({
    required this.onJank,
    required this.onMemory,
    required this.onNetwork,
    required this.onRebuilds,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _ActionItem(
        icon: Icons.speed,
        label: "Jank",
        color: Colors.redAccent,
        onTap: onJank,
      ),
      _ActionItem(
        icon: Icons.memory,
        label: "Memória",
        color: Colors.blueAccent,
        onTap: onMemory,
      ),
      _ActionItem(
        icon: Icons.cloud_upload,
        label: "Rede",
        color: Colors.orangeAccent,
        onTap: onNetwork,
      ),
      _ActionItem(
        icon: Icons.replay_circle_filled,
        label: "Rebuilds",
        color: Colors.purpleAccent,
        onTap: onRebuilds,
      ),
    ];

    return BottomAppBar(
      elevation: 8,
      color: Colors.white.withOpacity(0.95),
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons.map((btn) => Expanded(child: btn)).toList(),
        ),
      ),
    );
  }
}

//
// ──────────────────────────────── BOTÃO INDIVIDUAL ────────────────────────────────
//
class _ActionItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<_ActionItem> {
  bool _pressed = false;

  void _handleTap() async {
    setState(() => _pressed = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() => _pressed = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: _pressed ? widget.color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 26),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
