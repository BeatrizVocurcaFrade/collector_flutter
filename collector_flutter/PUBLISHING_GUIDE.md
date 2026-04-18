# Guia de Publicação no pub.dev

Este documento descreve passo a passo como publicar o `collector_flutter` no [pub.dev](https://pub.dev), desde os pré-requisitos até a verificação dos pub points após a publicação.

---

## Índice

1. [Pré-requisitos](#1-pré-requisitos)
2. [Checklist do pubspec.yaml](#2-checklist-do-pubspecyaml)
3. [Checklist de documentação](#3-checklist-de-documentação)
4. [Checklist de qualidade de código](#4-checklist-de-qualidade-de-código)
5. [Dry-run e interpretação de avisos](#5-dry-run-e-interpretação-de-avisos)
6. [Publicação](#6-publicação)
7. [Verificação pós-publicação e pub points](#7-verificação-pós-publicação-e-pub-points)
8. [Atualização de versão (patch, minor, major)](#8-atualização-de-versão-patch-minor-major)
9. [Referência rápida de comandos](#referência-rápida-de-comandos)

---

## 1. Pré-requisitos

### Ferramentas

| Ferramenta | Versão mínima | Verificação |
|---|---|---|
| Dart SDK | 3.5.0 | `dart --version` |
| Flutter SDK | 3.24.0 | `flutter --version` |
| pana (opcional, recomendado) | qualquer | `dart pub global activate pana` |

### Conta no pub.dev

1. Acesse [pub.dev](https://pub.dev) e faça login com uma conta Google.
2. A autenticação é feita via OAuth na primeira publicação — não é necessário criar tokens manualmente.

### Autenticação no terminal

```sh
dart pub login
```

Isso abre o navegador para autenticação OAuth. Após confirmar, o token é salvo localmente e reutilizado nas publicações seguintes.

---

## 2. Checklist do pubspec.yaml

O `pubspec.yaml` já está configurado com os campos necessários. Verifique cada item antes de publicar:

```yaml
name: collector_flutter               # ✅ obrigatório
description: >-                       # ✅ 60–180 caracteres
  Real-time resource monitoring ...
version: 0.1.0                        # ✅ Semantic Versioning (MAJOR.MINOR.PATCH)
repository: https://github.com/...    # ✅ URL HTTPS do repositório
homepage: https://github.com/...      # ✅ URL da página principal
issue_tracker: https://github.com/.../issues  # ✅ sistema de bugs

topics:                               # ✅ máx. 5; minúsculas, alfanumérico e hífens
  - flutter
  - performance
  - monitoring
  - profiling
  - telemetry

environment:
  sdk: ">=3.5.0 <4.0.0"             # ✅ range conservador
  flutter: ">=3.24.0"                # ✅ versão mínima testada
```

> **Atenção:** O campo `publish_to: none` foi **removido** do `pubspec.yaml`. Quando esse campo está presente, `dart pub publish` recusa a publicação. Se quiser travar temporariamente a publicação acidental, adicione `publish_to: none` e remova apenas quando estiver pronto.

### Regras de versão semântica

| Tipo de mudança | O que incrementar | Exemplo |
|---|---|---|
| Correção de bug sem quebra de API | PATCH | `0.1.0` → `0.1.1` |
| Nova funcionalidade, API compatível | MINOR | `0.1.0` → `0.2.0` |
| Quebra de API pública | MAJOR | `0.1.0` → `1.0.0` |

---

## 3. Checklist de documentação

| Artefato | Status | Requisito pub.dev |
|---|---|---|
| `README.md` | ✅ completo | obrigatório para pub points |
| `CHANGELOG.md` | ✅ semântico | obrigatório para pub points |
| `LICENSE` | ✅ MIT | obrigatório para pub points |
| `example/lib/main.dart` | ✅ presente | obrigatório para "illustrative example" |
| Dartdoc ≥ 20% API pública | ⚠️ parcial | obrigatório para pub points de documentação |

### Como gerar e visualizar a documentação

```sh
# Gera a documentação em doc/api/
dart doc .

# Serve localmente em http://localhost:8080
dart pub global activate dhttpd
dhttpd --path doc/api
```

Verifique se as classes e métodos públicos mais importantes têm comentários `///`.

---

## 4. Checklist de qualidade de código

Execute todos os comandos abaixo na pasta raiz do pacote (`collector_flutter/`):

```sh
# 1. Análise estática — deve retornar "No issues found!"
dart analyze

# 2. Formatação — não deve produzir saída (sem diffs)
dart format --output=none --set-exit-if-changed .

# 3. Dependências desatualizadas
flutter pub outdated

# 4. Testes (quando existirem)
flutter test
```

> **Sobre o `dart format`:** se o comando retornar diff, rode `dart format .` para corrigir e verifique as mudanças antes de commitar.

### Análise com pana (prévia dos pub points)

```sh
dart pub global activate pana
pana --no-warning .
```

`pana` simula exatamente o que o pub.dev calculará e exibe os pontos por categoria. Use isso para identificar problemas antes de publicar.

---

## 5. Dry-run e interpretação de avisos

Execute o dry-run para ver o que seria enviado ao pub.dev sem publicar de fato:

```sh
dart pub publish --dry-run
```

### Interpretação da saída

| Saída | Significado | Ação |
|---|---|---|
| `Package has 0 warnings.` | Pronto para publicar | Nenhuma |
| `Warning: ...` | Problema não bloqueante | Avaliar e corrigir se possível |
| `Error: ...` | Bloqueante — publicação recusada | Obrigatório corrigir |

### Avisos comuns

**`pubspec.yaml` description muito curta/longa**
```
description must be between 60 and 180 characters
```
→ Ajuste o campo `description` no `pubspec.yaml`.

**Arquivo `LICENSE` ausente ou inválido**
```
No LICENSE file found
```
→ O `LICENSE` agora contém a licença MIT completa. ✅

**Dartdoc coverage baixo**
```
x.x% of public API members have dartdoc comments
```
→ Adicione comentários `///` às classes e métodos públicos (veja seção 3).

---

## 6. Publicação

Após confirmar que o dry-run está limpo:

```sh
dart pub publish
```

O terminal exibirá um resumo do que será publicado e pedirá confirmação:

```
Publishing collector_flutter 0.1.0 to https://pub.dev.
Looks great! Are you ready to upload your package (y/n)?
```

Digite `y` para confirmar. O upload leva alguns segundos. Após concluir, a URL do pacote será exibida:

```
Successfully uploaded package.
https://pub.dev/packages/collector_flutter
```

> **Publicação é permanente e irreversível.** Versões publicadas não podem ser removidas, apenas descontinuadas (`dart pub unpublish --force` retracta a versão mas não a apaga). Teste tudo com `--dry-run` antes.

---

## 7. Verificação pós-publicação e pub points

### 7.1 Aguardar a análise

O pub.dev roda o `pana` automaticamente após cada publicação. A análise leva de 1 a 5 minutos. Acesse:

```
https://pub.dev/packages/collector_flutter/score
```

### 7.2 Categorias de pub points (máx. 160)

| Categoria | Pontos | O que avaliar |
|---|---|---|
| **Seguir convenções Dart** | até 30 | `pubspec.yaml` válido, `LICENSE`, `README.md`, `CHANGELOG.md` com versões formatadas |
| **Fornecer documentação** | até 20 | Exemplo de código em `example/`; dartdoc em ≥ 20% da API pública |
| **Suporte a plataformas** | até 20 | Múltiplas plataformas detectadas via análise de imports |
| **Passar análise estática** | até 30 | Zero erros/warnings em `dart analyze` / `flutter analyze` |
| **Dependências atualizadas** | até 20 | Compatibilidade com o Flutter/Dart SDK mais recentes e dependências atuais |
| **Null safety** | até 20 | Adoção de null safety (já atendido — Dart ≥ 3.5) |

### 7.3 Adicionar badges ao README

Após a publicação, substitua os placeholders dos badges no `README.md`:

```markdown
[![pub package](https://img.shields.io/pub/v/collector_flutter.svg)](https://pub.dev/packages/collector_flutter)
[![pub points](https://img.shields.io/pub/points/collector_flutter)](https://pub.dev/packages/collector_flutter/score)
[![popularity](https://img.shields.io/pub/popularity/collector_flutter)](https://pub.dev/packages/collector_flutter)
```

---

## 8. Atualização de versão (patch, minor, major)

Para cada nova versão:

### Passo 1 — Incrementar a versão no `pubspec.yaml`

```yaml
version: 0.1.1  # era 0.1.0
```

### Passo 2 — Atualizar o `CHANGELOG.md`

Adicione uma nova seção **acima** da versão anterior:

```markdown
## [0.1.1] - YYYY-MM-DD

### Fixed
- Descrição do que foi corrigido.

[0.1.1]: https://github.com/BeatrizVocurcaFrade/collector_flutter/compare/v0.1.0...v0.1.1
```

### Passo 3 — Commitar e criar tag Git

```sh
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: release v0.1.1"
git tag v0.1.1
git push origin main --tags
```

### Passo 4 — Publicar

```sh
dart pub publish --dry-run  # verificar
dart pub publish             # publicar
```

---

## Referência rápida de comandos

```sh
# Autenticação
dart pub login

# Verificações de qualidade
dart analyze
dart format --output=none --set-exit-if-changed .
flutter pub outdated
flutter test

# Prévia dos pub points
dart pub global activate pana
pana --no-warning .

# Dry-run
dart pub publish --dry-run

# Publicação
dart pub publish

# Gerar documentação
dart doc .
```
