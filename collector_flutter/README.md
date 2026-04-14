# collector_flutter

Pacote Flutter para coleta e análise de telemetria de runtime em apps Flutter.

Ele monitora:

- FPS observado por janela real de coleta
- frame timings, P50/P95/P99, jank e variância
- memória RSS/heap com histórico e tendência em MB/min
- requests HTTP feitos pelo client instrumentado
- eventos customizados com timestamp
- rebuilds marcados manualmente ou via `RebuildObserver`
- recomendações e exportação JSON/CSV

## Precisão

O coletor trabalha com snapshots temporais. Cada snapshot contém a janela desde
a última coleta (`sampleDuration`), os frames capturados nessa janela, um buffer
recente para gráficos, totais acumulados da sessão e estatísticas derivadas.

Isso evita estimar FPS apenas por tempo médio de frame e evita perder eventos de
rede, memória e eventos customizados entre coletas.

## Como Usar

```dart
import 'dart:async';

import 'package:collector_flutter/collector_flutter.dart';

final collector = ResourceCollector(
  collectionInterval: const Duration(seconds: 2),
  budget: const PerformanceBudget(targetFrameRate: 60),
);

unawaited(collector.start());
```

Para capturar rede, faça requests pelo wrapper:

```dart
final response = await collector.network.get(
  Uri.parse('https://api.example.com/items'),
);
```

Para eventos e rebuilds:

```dart
collector.recordEvent('checkout_opened', {'items': 3});
collector.trackRebuild();
```

Ou envolva uma subárvore:

```dart
RebuildObserver(
  widgetName: 'CatalogPage',
  onRebuild: (_) => collector.trackRebuild(),
  child: const CatalogPage(),
);
```

## Dashboard

O pacote inclui `DashboardPage`, que consome `ResourceCollector` e mostra FPS,
memória, jank, rede, percentis de frame, recomendações e exportação JSON.

```dart
DashboardPage(collector: collector);
```
