# collector_flutter

[![pub package](https://img.shields.io/pub/v/collector_flutter.svg)](https://pub.dev/packages/collector_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.24-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.5-0175C2?logo=dart&logoColor=white)](https://dart.dev)

Real-time performance monitoring for Flutter apps — FPS, jank, memory, HTTP traffic, and custom events, with an **embedded visual dashboard** and **actionable recommendations**, all in pure Dart with no external tools required.

---

## Features

- **Frame timing** — FPS, jank detection, P50 / P95 / P99 percentiles, and variance
- **Memory** — RSS and heap usage, trend in MB/min, rolling history graph
- **HTTP traffic** — request count, latency, payload sizes, and failure rate via a transparent client wrapper
- **Custom events** — record arbitrary named events with values and timestamps
- **Widget rebuilds** — manual tracking or automatic via the `RebuildObserver` wrapper
- **Heuristic analysis** — automatically detects frame drops, memory pressure, and network anomalies
- **Recommendations** — severity-coded suggestions (info / low / medium / high) with detailed explanations
- **Embedded dashboard** — `DashboardPage` with live charts, metric cards, network panel, and JSON export

---

## Getting started

Add `collector_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  collector_flutter: ^0.1.0
```

Run:

```sh
flutter pub get
```

> **Tip:** Run your app in **profile mode** (`flutter run --profile`) to enable the Dart VM Service, which provides accurate memory readings. In debug mode the package falls back to `ProcessInfo.currentRss`.

---

## Usage

### 1 — Initialize and start

```dart
import 'package:collector_flutter/collector_flutter.dart';

final collector = ResourceCollector(
  collectionInterval: const Duration(seconds: 2),
  budget: const PerformanceBudget(targetFrameRate: 60),
);

// Call before the first frame or in initState
await collector.start();
```

### 2 — Open the dashboard

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DashboardPage(collector: collector),
  ),
);
```

### 3 — Instrument HTTP traffic

Replace your `http` client with the collector's wrapper to capture network metrics:

```dart
// Before
final response = await http.get(Uri.parse('https://api.example.com/data'));

// After
final response = await collector.network.get(
  Uri.parse('https://api.example.com/data'),
);
```

All standard methods are supported: `get`, `post`, `put`, `patch`, `delete`, `head`.

### 4 — Record custom events

```dart
collector.recordEvent('checkout_started', {'cart_items': 3});
collector.recordEvent('payment_success', {'amount': 49.90});
```

### 5 — Track widget rebuilds

**Manual** (inside `build`):

```dart
@override
Widget build(BuildContext context) {
  collector.trackRebuild();
  return const MyWidget();
}
```

**Automatic** via wrapper:

```dart
RebuildObserver(
  widgetName: 'ProductList',
  onRebuild: (_) => collector.trackRebuild(),
  child: const ProductList(),
)
```

### 6 — Clean up

```dart
@override
void dispose() {
  collector.dispose(); // stops collection, cancels streams, releases VM Service
  super.dispose();
}
```

---

## Dashboard

`DashboardPage` is a self-contained screen that consumes a `ResourceCollector` instance and updates every collection cycle.

| Panel | Content |
|---|---|
| **Metric cards** | FPS, memory (with trend arrow), jank count, HTTP requests, P95 frame time |
| **Frame chart** | Spline area chart of recent frame timings with a 16.6 ms budget reference line |
| **Network panel** | Last 5 HTTP requests — method, URL, status code, duration |
| **Recommendations** | Severity-coded cards; tap any card for a detailed explanation |
| **Export** | Copies a full JSON snapshot of the session to the clipboard |

---

## API overview

| Class / Widget | Role |
|---|---|
| `ResourceCollector` | Main entry point — lifecycle (`start` / `stop` / `dispose`), access to sub-collectors |
| `DashboardPage` | Embedded performance dashboard |
| `PerformanceBudget` | Target frame rate and memory / network thresholds |
| `RebuildObserver` | Widget wrapper for automatic rebuild counting |
| `TelemetryHttpClient` | Transparent HTTP client for network instrumentation |
| `AnalysisResult` | Output of the heuristic analyzer (frame stats, memory stats, network stats) |
| `Recommendation` | Single actionable suggestion with title, body, and severity |

---

## Platform support

| Android | iOS | macOS | Linux | Windows | Web |
|:---:|:---:|:---:|:---:|:---:|:---:|
| ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ | ❌ |

> ⚠️ Desktop: frame and event collection work, but VM Service memory readings require profile-mode setup. ❌ Web: `vm_service` is not supported on the web platform.

---

## Additional information

- **Overhead:** target < 3%, hard limit < 5% on average frame rendering time
- **Collection interval:** configurable (default 2 s); shorter intervals increase CPU usage
- **Bugs and feature requests:** [github.com/BeatrizVocurcaFrade/collector_flutter/issues](https://github.com/BeatrizVocurcaFrade/collector_flutter/issues)
- **Contributing:** pull requests are welcome — please open an issue first to discuss larger changes
- **License:** [MIT](LICENSE)
