# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Replaced `syncfusion_flutter_charts` (proprietary) with `fl_chart ^0.69.0` (MIT) for the frame timing chart — removes the Syncfusion Community License requirement from downstream projects
- All `.withOpacity()` calls replaced with `.withOpacity()` for compatibility with Flutter SDK ≥ 3.24 and < 3.27

### Fixed
- Removed unused `_FrameSample` class after chart library migration

---

## [0.1.0] - 2026-04-18

### Added

- `ResourceCollector` — main facade for unified lifecycle management (`start`, `stop`, `dispose`, `collectNow`)
- `FrameDataSource` — frame timing collection via `SchedulerBinding.addTimingsCallback`; buffers up to 600 frames
- `MemoryDataSource` — RSS and heap monitoring via the Dart VM Service, with `ProcessInfo.currentRss` fallback; maintains up to 120 samples
- `HttpClientWrapper` / `TelemetryHttpClient` — transparent HTTP client wrapper that records method, URL, status, latency, and payload sizes; stores up to 1 000 events
- `EventDataSource` — timestamped custom event recording; stores up to 1 000 entries
- `Analyzer` — heuristic engine computing FPS estimate, P50 / P95 / P99 frame percentiles, jank count, memory trend (MB/min), and network statistics
- `Recommender` — generates severity-coded (`info` / `low` / `medium` / `high`) actionable recommendations from `AnalysisResult`
- `CollectorBloc` — reactive state management for the collection lifecycle (`CollectorIdle`, `CollectorRunning`, `CollectorData`, `CollectorError`)
- `DashboardPage` — embedded real-time dashboard with frame chart, five metric cards, network panel, recommendations, and JSON clipboard export
- `RebuildObserver` — widget wrapper for automatic rebuild counting on a subtree
- `PerformanceBudget` — configurable target frame rate, memory warning threshold, and network request threshold
- `ExportService` — JSON snapshot generation for the current telemetry session
- Clean Architecture structure: Data / Domain / Presentation layers with repository pattern and use-case interactors

### Fixed

- Frame chart X-axis: replaced `DateTime.now()` with sequential frame indices to produce a correct timing plot
- Memory history: introduced `_lastMemorySnapshot` guard to prevent false downward spikes from missed samples
- Chart rendering: wrapped chart in `ClipRRect` + `SingleChildScrollView` with dynamic Y-axis scaling (`interval = maxY / 4`)
- Network URL display: added `_extractShortHost()` for readable, non-redundant URL truncation
- Collection synchronisation: memory sampling interval set to `0.9 × collectionInterval` to guarantee fresh data on every collection cycle
- `StreamSubscription` leak in `DashboardPage.dispose()`: subscription now correctly cancelled
- `ResourceCollector.dispose()`: now calls `stop()` before `bloc.dispose()`, preventing in-flight collection after disposal

[0.1.0]: https://github.com/BeatrizVocurcaFrade/collector_flutter/releases/tag/v0.1.0
