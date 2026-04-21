import 'dart:async';
import 'dart:math';
import 'package:collector_flutter/collector_flutter.dart';
import 'package:flutter/material.dart';
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
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  List<Uint8List>? _memoryPressure;
  bool _scenarioRunning = false;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    unawaited(collector.start());
    unawaited(_simulateNetwork());

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
    try {
      await collector.network.get(uri);
    } catch (error) {
      collector.recordEvent('init_network_error', error.toString());
    } finally {
      await collector.collectNow();
    }
  }

  Future<void> _generateJank() async {
    const bursts = 6;
    const blockMs = 90;
    var checksum = 0;

    debugPrint('Gerando jank controlado...');
    collector.recordEvent('simulate_jank_started', {
      'bursts': bursts,
      'block_ms': blockMs,
    });
    await collector.collectNow();

    for (var burst = 0; burst < bursts; burst++) {
      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsedMilliseconds < blockMs) {
        for (var i = 0; i < 12000; i++) {
          checksum = (checksum + i * (burst + 1)) & 0x3fffffff;
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    collector.recordEvent('simulate_jank', {
      'bursts': bursts,
      'block_ms': blockMs,
      'checksum': checksum,
    });
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await collector.collectNow();
    _showStatus('Jank simulado. Grafico atualizado com novos frames.');
  }

  Future<void> _simulateHighMemory() async {
    debugPrint('Simulando uso controlado de memoria...');
    const chunkMB = 32;
    const chunks = 4;
    final buffers = List.generate(
      chunks,
      (_) => Uint8List(chunkMB * 1024 * 1024),
    );

    // Touch one byte per page so the allocation becomes visible in RSS, instead
    // of remaining as lazily reserved memory on some platforms.
    for (final buffer in buffers) {
      for (var offset = 0; offset < buffer.length; offset += 4096) {
        buffer[offset] = 1;
      }
    }

    _memoryPressure = buffers;
    final retainedMB = (_memoryPressure?.length ?? 0) * chunkMB;
    collector.recordEvent('simulate_memory', {'size_mb': retainedMB});
    await collector.collectNow(forceMemory: true);
    _showStatus('Memoria alocada e coletada: $retainedMB MB.');

    await Future<void>.delayed(const Duration(seconds: 3));
    _memoryPressure = null;
    collector.recordEvent('simulate_memory_released', {
      'size_mb': chunkMB * chunks,
    });
    await collector.collectNow(forceMemory: true);
    _showStatus('Memoria liberada. Nova coleta enviada ao dashboard.');
  }

  Future<void> _simulateNetworkSpam() async {
    debugPrint('Disparando requisicoes controladas...');
    const requestCount = 8;
    final uri = Uri.parse(
      'https://jsonplaceholder.typicode.com/todos/${_rand.nextInt(10) + 1}',
    );
    collector.recordEvent('simulate_network_started', {'count': requestCount});
    await collector.collectNow();

    final results = await Future.wait(
      List.generate(requestCount, (_) async {
        try {
          await collector.network.get(uri);
          return true;
        } catch (_) {
          return false;
        }
      }),
    );
    final failures = results.where((ok) => !ok).length;
    collector.recordEvent('simulate_network', {
      'count': requestCount,
      'failures': failures,
    });
    await collector.collectNow();
    _showStatus(
      failures == 0
          ? '$requestCount requisicoes registradas.'
          : '$requestCount requisicoes finalizadas, $failures com falha.',
    );
  }

  Future<void> _simulateRebuilds() async {
    debugPrint('Gerando rebuilds excessivos...');
    collector.recordEvent('simulate_rebuilds_started', {'count': 30});
    await collector.collectNow();

    for (var i = 0; i < 30; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!mounted) return;
      collector.trackRebuild();
      setState(() {});
    }
    collector.recordEvent('simulate_rebuilds', {'count': 30});
    await collector.collectNow();
    _showStatus('30 rebuilds registrados no painel.');
  }

  void _showStatus(String message) {
    if (!mounted) return;
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _runScenario(Future<void> Function() scenario) async {
    if (_scenarioRunning) {
      _showStatus(
          'Aguarde o cenario atual terminar para manter a leitura precisa.');
      return;
    }

    _scenarioRunning = true;
    try {
      await scenario();
    } finally {
      _scenarioRunning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collector Flutter Demo',
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueAccent),
      home: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 2,
          centerTitle: true,
          title: const Text(
            'Collector Flutter Demo',
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
            onJank: () => _runScenario(_generateJank),
            onMemory: () => _runScenario(_simulateHighMemory),
            onNetwork: () => _runScenario(_simulateNetworkSpam),
            onRebuilds: () => _runScenario(_simulateRebuilds),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    collector.dispose();
    _controller.dispose();
    super.dispose();
  }
}

// ─── DASHBOARD ───────────────────────────────────────────────────────────────

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
          const _IntroCard(),
          const SizedBox(height: 20),
          DashboardPage(collector: collector),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─── INTRO CARD ──────────────────────────────────────────────────────────────

class _IntroCard extends StatelessWidget {
  const _IntroCard();

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
          'Simule situacoes de carga, consumo e jank para testar o coletor em tempo real.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
      ),
    );
  }
}

// ─── BOTTOM ACTION BAR ───────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final FutureOr<void> Function() onJank;
  final FutureOr<void> Function() onMemory;
  final FutureOr<void> Function() onNetwork;
  final FutureOr<void> Function() onRebuilds;

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
          label: 'Jank',
          color: Colors.redAccent,
          onTap: onJank),
      _ActionItem(
          icon: Icons.memory,
          label: 'Memoria',
          color: Colors.blueAccent,
          onTap: onMemory),
      _ActionItem(
          icon: Icons.cloud_upload,
          label: 'Rede',
          color: Colors.orangeAccent,
          onTap: onNetwork),
      _ActionItem(
          icon: Icons.replay_circle_filled,
          label: 'Rebuilds',
          color: Colors.purpleAccent,
          onTap: onRebuilds),
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

// ─── ACTION BUTTON ───────────────────────────────────────────────────────────

class _ActionItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final FutureOr<void> Function() onTap;

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
  bool _running = false;

  Future<void> _handleTap() async {
    if (_running) return;

    setState(() {
      _pressed = true;
      _running = true;
    });
    HapticFeedback.mediumImpact();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await widget.onTap();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'collector_flutter example',
          context: ErrorDescription('while running ${widget.label} scenario'),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Falha em ${widget.label}: $error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _pressed = false;
          _running = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !_running,
      label: widget.label,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color:
                _pressed ? widget.color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: _running
                    ? CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: widget.color,
                      )
                    : Icon(widget.icon, color: widget.color, size: 26),
              ),
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
      ),
    );
  }
}
