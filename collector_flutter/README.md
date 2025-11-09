# collector_flutter

Pacote Flutter para coleta e análise básica de métricas de runtime:
- FPS / Frame timings (via `SchedulerBinding.addTimingsCallback`)
- Jank detection (frames acima de threshold)
- Rebuild observation (`RebuildObserver`)
- Memória (best-effort; ideal usar `vm_service` em modo profile)
- Network (wrapper HTTP para interceptar requisições)
- Eventos customizados (`recordEvent(name, value)`)
- Orquestrador `ResourceCollector` e dashboard de exemplo

## Estrutura
Veja a árvore do projeto (lib/src/...), incluindo `core`, `data`, `domain`, `presentation`.

## Como usar
1. Adicione o package (local ou via path).
2. No `main()` instancie e inicie:
```dart
final collector = ResourceCollector();
collector.start();
