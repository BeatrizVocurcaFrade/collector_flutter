# Roteiro de apresentação - 15 minutos

Este arquivo acompanha `slides/main.tex`. Ele foi reescrito para uma apresentação mais curta, direta e alinhada à monografia, sem vender a avaliação como validação estatística ou validação cruzada formal.

Use este roteiro como fala de treino. A ideia é soar natural: se uma frase ficar dura na sua voz, mantenha o sentido e fale com as suas palavras.

## Como usar

- A seção "Roteiro falado" é a fala principal, quase literal.
- As seções finais são apoio para perguntas da banca.
- Quando falar de validação, use sempre a expressão "validação funcional" ou "avaliação funcional qualitativa".
- Se perguntarem sobre validação cruzada, diga que não houve validação cruzada estatística formal; houve apoio qualitativo por ADB, logs, capturas, exportação e testes.
- Não diga que Android Profiler e Perfetto geraram dados quantitativos do trabalho. Na monografia, eles aparecem como referências conceituais e ferramentas de aprofundamento.

## Mapa de tempo

| Slide | Tema | Tempo alvo | Acumulado |
| --- | --- | ---: | ---: |
| 1 | Capa | 0min35s | 0min35s |
| 2 | Problema e motivação | 1min15s | 1min50s |
| 3 | Dimensão de humanidades | 1min05s | 2min55s |
| 4 | Objetivos | 0min55s | 3min50s |
| 5 | Base científica e lacuna | 1min10s | 5min00s |
| 6 | Proposta | 1min00s | 6min00s |
| 7 | Metodologia | 1min05s | 7min05s |
| 8 | Arquitetura em camadas | 1min10s | 8min15s |
| 9 | Cenários controlados | 1min00s | 9min15s |
| 10 | Resultados observados | 1min25s | 10min40s |
| 11 | Evidências da validação funcional | 1min00s | 11min40s |
| 12 | Testes automatizados | 0min55s | 12min35s |
| 13 | Dashboard integrado | 0min55s | 13min30s |
| 14 | Publicação no pub.dev | 0min45s | 14min15s |
| 15 | Conclusão | 0min40s | 14min55s |
| 16 | Perguntas | 0min05s | 15min00s |

Regra de ritmo:

> Se estiver atrasada no slide 10, cite só um número principal por cenário e avance. Não corte dashboard, publicação e conclusão.

## Tese em uma frase

> A biblioteca desenvolvida aproxima o primeiro diagnóstico de desempenho do fluxo real de desenvolvimento Flutter, reunindo coleta, análise, dashboard, recomendações, exportação e evidências funcionais em uma ferramenta integrada ao app.

Versão de 10 segundos:

> Eu desenvolvi uma biblioteca Flutter que coleta sinais de desempenho dentro do app e orienta a primeira investigação técnica.

Versão de 30 segundos:

> O pacote `collector_flutter` é integrado à aplicação monitorada. Ele coleta FPS, jank, memória, rede, CPU, bateria, eventos e rebuilds; analisa sintomas por heurísticas; apresenta recomendações no dashboard; e permite exportar dados para inspeção externa.

## Roteiro falado

### Slide 1 - Capa - 0min35s

Fala literal:

> Boa tarde. Eu sou a Beatriz Vocurca Frade e vou apresentar o meu trabalho de conclusão de curso, com o tema "Monitoramento e otimização de recursos em aplicativos Flutter".
>
> O trabalho resultou no pacote `collector_flutter`, uma biblioteca que eu desenvolvi para coletar métricas de desempenho dentro de uma aplicação Flutter, analisar sintomas técnicos e apresentar recomendações para o desenvolvedor.
>
> A ideia central é aproximar o primeiro diagnóstico de performance do fluxo real de desenvolvimento, sem depender sempre de abrir uma ferramenta externa logo no primeiro momento.

Transição:

> Para começar, eu apresento o problema que motivou a proposta.

### Slide 2 - Problema e motivação - 1min15s

Fala literal:

> Flutter ajuda bastante no desenvolvimento multiplataforma porque permite criar aplicações com uma base de código comum. Mas essa produtividade não elimina os problemas de desempenho.
>
> Em aplicativos reais, a interface combina listas dinâmicas, animações, chamadas de rede, estado reativo, processamento local e execução em dispositivos muito diferentes.
>
> Quando o desempenho degrada, o usuário percebe diretamente: a tela engasga, o FPS cai, a memória aumenta, a bateria dura menos ou o aplicativo fica menos responsivo.
>
> Hoje existem ferramentas muito boas para investigar esses problemas, como Flutter DevTools, Android Profiler e Perfetto. A dificuldade que motivou o trabalho é o atrito de usar essas ferramentas de forma contínua durante o desenvolvimento.
>
> A pergunta de pesquisa foi: como tornar o diagnóstico de desempenho mais acessível, contínuo e acionável em Flutter?

Transição:

> Antes de entrar nos objetivos, eu queria explicitar a dimensão humana que orienta a proposta.

### Slide 3 - Dimensão de humanidades - 1min05s

Fala literal:

> Esse slide conecta a implementação com uma leitura de humanidades.
>
> Para o desenvolvedor, o problema não é só ter métricas. É conseguir interpretar essas métricas sem aumentar demais o atrito do trabalho. Por isso o pacote tenta transformar sinais técnicos em uma primeira leitura mais compreensível.
>
> Para o usuário, desempenho também é experiência: fluidez, tempo de espera, consumo de bateria, aquecimento e confiança no aplicativo.
>
> E existe ainda uma responsabilidade no uso de recursos. Um aplicativo que desperdiça CPU, memória, rede ou bateria impacta o dispositivo, a autonomia e o contexto de quem usa.
>
> Então a contribuição não é apenas medir desempenho. É aproximar evidência técnica de uma decisão mais responsável, compreensível e centrada na pessoa.

Transição:

> A partir dessa leitura, eu defini os objetivos do trabalho.

### Slide 4 - Objetivos - 0min55s

Fala literal:

> O objetivo geral foi desenvolver e avaliar funcionalmente o pacote `collector_flutter`, uma biblioteca Dart e Flutter embarcada na própria aplicação.
>
> O pacote deveria coletar métricas como FPS, jank, memória, rede, CPU, bateria, eventos e rebuilds. Além da coleta, ele precisava organizar esses dados, analisar sintomas e exibir recomendações dentro do app.
>
> Também fez parte do escopo exportar sessões em JSON e timings de frames em CSV, para permitir inspeção externa.
>
> Por fim, a avaliação foi feita por cenários controlados, verificando se os sinais registrados acompanhavam as cargas induzidas no aplicativo de exemplo.

Transição:

> Para sustentar essas escolhas, a revisão bibliográfica foi importante.

### Slide 5 - Base científica e lacuna - 1min10s

Fala literal:

> A revisão ajudou em três pontos principais.
>
> O primeiro é energia. Trabalhos sobre consumo em dispositivos móveis mostram que CPU, rede, tempo de execução e memória estão relacionados ao uso de recursos.
>
> O segundo ponto é desempenho móvel. A literatura reforça que uma métrica isolada raramente explica o problema inteiro. FPS, frames longos, rede, memória e CPU precisam ser analisados em conjunto.
>
> O terceiro ponto é diagnóstico. Não basta coletar números: o desenvolvedor precisa transformar sintomas observáveis em hipóteses de otimização.
>
> Com isso, a lacuna identificada ficou entre medir e agir. As ferramentas externas são fortes, mas a triagem inicial ainda exige troca de contexto e interpretação manual. O trabalho entra justamente nesse espaço.

Transição:

> A proposta foi criar uma biblioteca integrada ao aplicativo para fazer essa primeira leitura.

### Slide 6 - Proposta: biblioteca desenvolvida - 1min00s

Fala literal:

> A ferramenta proposta é o pacote `collector_flutter`, uma biblioteca integrada à aplicação monitorada.
>
> Ela coleta métricas durante a execução do app, analisa sintomas por heurísticas, classifica recomendações por severidade e mostra essas informações em um dashboard.
>
> A contribuição não é substituir DevTools, Profiler ou Perfetto. Essas ferramentas continuam importantes para investigação profunda.
>
> A contribuição é oferecer uma primeira camada de observação dentro do próprio app, reduzindo a distância entre perceber um sintoma e começar a investigar.

Transição:

> Para construir e avaliar essa proposta, o trabalho seguiu uma metodologia aplicada e funcional.

### Slide 7 - Metodologia - 1min05s

Fala literal:

> A metodologia começa pela revisão bibliográfica, passa pela definição dos requisitos e da arquitetura, depois pela implementação do pacote e, por fim, pela execução de cenários controlados.
>
> A avaliação teve caráter funcional e qualitativo. Isso significa que o objetivo foi verificar se o pacote funcionava no aplicativo de exemplo e se os sinais coletados eram coerentes com os sintomas induzidos.
>
> As evidências usadas foram painel, logs do aplicativo, capturas de tela, exportação de dados e leituras complementares por ADB.
>
> É importante deixar claro que a monografia não apresenta benchmark estatístico, nem cálculo formal de erro em relação a ferramentas externas. Esse é um limite metodológico assumido no trabalho.

Transição:

> A implementação foi organizada em camadas para separar coleta, análise e interface.

### Slide 8 - Arquitetura em camadas - 1min10s

Fala literal:

> A arquitetura foi dividida em três camadas.
>
> Na camada Data ficam as fontes de dados: frames, memória, rede, eventos, CPU e bateria. É a camada que conversa com APIs do Flutter, `vm_service`, cliente HTTP e platform channels.
>
> Na camada Domain ficam as entidades, os casos de uso, o `Analyzer` e o `Recommender`. Essa camada transforma dados brutos em sintomas e recomendações.
>
> Na camada Presentation ficam o `CollectorBloc`, o dashboard e os widgets visuais. Ela apresenta as métricas e recomendações de forma reativa.
>
> Essa separação foi importante porque permitiu evoluir o pacote com CPU, bateria, exportação e testes sem misturar responsabilidades.

Transição:

> Para avaliar o comportamento do pacote, eu executei quatro cenários controlados.

### Slide 9 - Cenários controlados - 1min00s

Fala literal:

> Foram definidos quatro cenários no aplicativo de exemplo.
>
> O primeiro cenário força rebuilds, ou reconstruções intensivas da interface. Ele ajuda a observar impacto em renderização, FPS, P95 e frames longos.
>
> O segundo cenário dispara requisições HTTP simultâneas. O foco é verificar eventos de rede, latência e possível impacto na fluidez.
>
> O terceiro cenário provoca alocação intensiva de memória. Nesse caso, o objetivo foi observar crescimento do processo e confrontar com leitura complementar por ADB.
>
> O quarto cenário combina interface, rede, memória e CPU, porque aplicações reais frequentemente apresentam mais de um sinal ao mesmo tempo.

Transição:

> A partir dessas execuções, alguns resultados foram registrados na monografia.

### Slide 10 - Resultados observados - 1min25s

Fala literal:

> Este slide resume os principais sinais observados.
>
> No cenário de rebuilds, foram registrados 30 rebuilds, FPS de 55,4, P95 de 20,4 milissegundos e 2 frames longos. Isso mostra que a carga de interface apareceu no painel.
>
> No cenário de rede, foram registradas 9 requisições, FPS de 42,9, P95 de 139,5 milissegundos e 4 frames longos. Aqui o cliente instrumentado registrou eventos e latências.
>
> No cenário de memória, o ADB registrou RSS de 236.480 KB e PSS de 222.232 KB. Essa leitura confirmou aumento real de memória no processo. Ao mesmo tempo, o snapshot do painel mostrou uma limitação da leitura interna, porque apareceu 0,0 MB naquele registro.
>
> No cenário combinado, apareceram 17 requisições, 54 rebuilds, FPS de 44,6, P95 de 37,7 milissegundos e CPU de 75,3%. Esse cenário mostrou múltiplos sinais simultâneos e recomendações compatíveis.
>
> A leitura geral é que os sinais acompanharam os sintomas provocados, dentro do escopo funcional e qualitativo do trabalho.

Transição:

> Para que esses resultados não ficassem só em descrição textual, a monografia preservou evidências da execução.

### Slide 11 - Evidências da validação funcional - 1min00s

Fala literal:

> Essas imagens foram geradas no projeto e documentam os quatro cenários: rebuilds, rede, memória e carga combinada.
>
> Além das capturas, a evidência inclui logs do aplicativo, exportação de dados, leituras por ADB e a suíte de testes automatizados.
>
> Então, quando eu falo em validação funcional, eu estou falando desse conjunto: execução real do app de exemplo, sinais observados, registros preservados e contratos internos testados.
>
> O ADB foi usado como apoio qualitativo, principalmente com `dumpsys meminfo` e `dumpsys gfxinfo`. Ele não foi usado para calcular erro estatístico de FPS, até porque nessa execução o `gfxinfo` confirmou a superfície Flutter ativa, mas não forneceu uma série comparável de frames.

Transição:

> A outra parte importante da validação foi a suíte automatizada.

### Slide 12 - Testes automatizados - 0min55s

Fala literal:

> A suíte automatizada possui 60 testes.
>
> Eles estão distribuídos em quatro grupos: 24 testes de análise, 17 de CPU e bateria, 12 de recomendações e 7 de exportação.
>
> Esses testes verificam cálculos internos, serialização, recomendações, exportação em JSON e CSV e comportamento de fallback dos canais nativos.
>
> Os testes não provam desempenho real sozinhos, mas complementam os cenários manuais porque verificam contratos internos da implementação.
>
> Então a avaliação junta duas frentes: o pacote funcionando no app de exemplo e a lógica interna sendo exercitada por testes.

Transição:

> Depois dos resultados e dos testes, eu volto para a interface, que é a forma como esses sinais chegam ao desenvolvedor.

### Slide 13 - Dashboard integrado - 0min55s

Fala literal:

> Aqui aparecem duas telas reais do painel.
>
> À esquerda, a aplicação está em uma condição mais estável. À direita, aparecem gargalos e recomendações com maior severidade.
>
> O objetivo do dashboard é agregar os sinais em uma leitura visual. Em vez de o desenvolvedor depender só de logs soltos, ele vê métricas, gráficos e recomendações no próprio aplicativo.
>
> Isso ajuda a decidir qual sintoma investigar primeiro: renderização, rede, memória, CPU ou outro comportamento observado.

Transição:

> Depois de mostrar a interface, eu fecho a entrega mostrando que o pacote também foi disponibilizado para a comunidade.

### Slide 14 - Publicação no pub.dev - 0min45s

Fala literal:

> Um ponto importante do trabalho é que o pacote foi publicado no pub.dev, que é o repositório oficial do ecossistema Dart e Flutter.
>
> A versão publicada é a 0.1.3, e o pub.dev registrava 32 pessoas usando o pacote.
>
> Isso é relevante porque amplia o acesso à ferramenta, facilita reprodutibilidade e permite que outros desenvolvedores ou pesquisadores testem, avaliem e evoluam a biblioteca.
>
> Então a contribuição não ficou apenas como código local da monografia; ela foi disponibilizada em um canal usado pela comunidade Flutter.

Transição:

> Com a ferramenta implementada, avaliada e publicada, eu volto à contribuição central do trabalho.

### Slide 15 - Conclusão - 0min40s

Fala literal:

> A conclusão principal é que é viável aproximar o primeiro diagnóstico de desempenho do fluxo real de desenvolvimento Flutter.
>
> A biblioteca desenvolvida reúne coleta, análise, dashboard, recomendações, exportação, CPU, bateria e testes em uma arquitetura organizada.
>
> A avaliação foi funcional e qualitativa, com cenários controlados, painel, logs, capturas, ADB e 60 testes automatizados.
>
> Além disso, a publicação no pub.dev torna o pacote acessível para a comunidade, permitindo uso, reprodução e evolução futura.
>
> A mensagem final é que performance não é só fazer o app rodar mais rápido; é fazer o app respeitar melhor o dispositivo, a bateria e a pessoa que o utiliza.

Transição:

> Obrigada pela atenção. Fico à disposição para perguntas.

### Slide 16 - Perguntas - 0min05s

Fala literal:

> Obrigada. Fico à disposição para perguntas.

Se houver silêncio:

> Posso detalhar a arquitetura, os cenários de validação funcional, a publicação no pub.dev ou a diferença entre a ferramenta proposta e Profiler/Perfetto.

## Números que você precisa saber de cabeça

| Item | Número | Como falar |
| --- | ---: | --- |
| Cenários controlados | 4 | Rebuilds, rede, memória e carga combinada. |
| Testes automatizados | 60 | Verificam análise, CPU/bateria, recomendações e exportação. |
| Testes de análise | 24 | Estatísticas, sintomas e contratos do `Analyzer`. |
| Testes de CPU/bateria | 17 | Platform channel, fallback e integração de métricas. |
| Testes de recomendações | 12 | Severidade e mensagens do `Recommender`. |
| Testes de exportação | 7 | JSON, CSV e serialização. |
| Rebuilds no cenário de interface | 30 | Carga de interface registrada pelo painel. |
| FPS no cenário de rebuilds | 55,4 | P95 de 20,4 ms e 2 frames longos. |
| Requisições no cenário de rede | 9 | Cliente instrumentado registrou eventos e latências. |
| P95 no cenário de rede | 139,5 ms | Frames mais longos sob carga de rede. |
| Memória no ADB | RSS 236.480 KB e PSS 222.232 KB | Aumento real do processo durante alocação. |
| Carga combinada | 17 requisições, 54 rebuilds, CPU 75,3% | Vários sinais apareceram juntos. |
| Versão publicada | 0.1.3 | Versão disponível no pub.dev. |
| Pessoas usando no pub.dev | 32 | Indica alcance inicial fora do repositório local. |

## Respostas prontas sobre validação cruzada

### Se perguntarem: "Houve validação cruzada?"

> Não houve validação cruzada estatística formal. O que houve foi uma validação funcional qualitativa, com apoio de diferentes fontes de evidência: painel, logs, capturas, exportação, ADB e testes automatizados.

### Se perguntarem: "Então por que aparece ADB?"

> O ADB aparece porque eu quis ter uma fonte externa do Android para conferir se os sinais observados no pacote faziam sentido fora do próprio painel. No cenário de memória, usei `adb shell dumpsys meminfo` para observar RSS e PSS do processo e confirmar que havia crescimento real durante a alocação. No caso de renderização, usei `adb shell dumpsys gfxinfo` para confirmar a superfície Flutter ativa; porém, nessa execução, os contadores retornados não formaram uma série comparável de frames para calcular erro de FPS. Então o ADB entra como evidência complementar de rastreabilidade e coerência, não como benchmark nem como base para afirmar precisão estatística.

### Se perguntarem: "Profiler e Perfetto foram usados na validação?"

> Na versão final documentada, Profiler e Perfetto aparecem como referências conceituais e ferramentas oficiais de aprofundamento. Eles não foram usados como fonte quantitativa comparativa no resultado apresentado.

### Se perguntarem: "Isso é benchmark?"

> Não. É uma avaliação funcional em cenários controlados. Um benchmark exigiria múltiplas rodadas, amostra maior, diferentes dispositivos, cálculo de média, desvio padrão e erro em relação a ferramentas de referência.

### Se perguntarem: "O que faltaria para uma validação cruzada formal?"

> Seria necessário executar os mesmos cenários em múltiplas rodadas, com e sem o coletor, em diferentes dispositivos, registrando séries comparáveis em ferramentas externas como Profiler, Perfetto e ADB. Aí seria possível calcular erro percentual, variação e intervalo de confiança.

## Perguntas prováveis da banca

### 1. Qual é a principal contribuição técnica?

> A principal contribuição é integrar coleta embarcada, análise heurística, dashboard, recomendações, exportação e testes em um pacote Flutter publicado para a comunidade.

### 2. Por que não usar apenas Flutter DevTools?

> DevTools é excelente para investigação profunda, mas exige sair do fluxo do app. O pacote atua antes, como uma primeira triagem técnica integrada à aplicação.

### 3. O pacote substitui Android Profiler ou Perfetto?

> Não. Ele ajuda no primeiro diagnóstico. Profiler e Perfetto continuam úteis para análise profunda, séries temporais e tracing de baixo nível.

### 4. O que há de diferente em relação a logs?

> Logs mostram eventos isolados. O pacote agrega métricas, calcula sintomas, classifica recomendações, apresenta dashboard e exporta os dados.

### 5. Como os frames são coletados?

> A coleta usa mecanismos do Flutter, como `SchedulerBinding.addTimingsCallback` e `FrameTiming`, para receber tempos de frame e calcular FPS, P95 e frames longos.

### 6. Por que P95 é importante?

> Porque a média pode esconder engasgos. O P95 mostra o comportamento dos frames mais lentos relevantes, que afetam a percepção de fluidez.

### 7. Toda requisição HTTP do app é capturada automaticamente?

> Não. O pacote registra as chamadas feitas pelo cliente instrumentado. Essa escolha torna a implementação menos invasiva e mais controlável.

### 8. Como a memória é observada?

> O pacote usa `vm_service` e informações do processo. Na evidência do cenário de memória, a leitura complementar por ADB confirmou aumento real de RSS e PSS.

### 9. Por que o painel mostrou 0,0 MB no cenário de memória?

> Esse foi um limite observado no snapshot capturado. Por isso a monografia documenta também a leitura complementar por ADB, que mostrou crescimento real do processo durante a alocação.

### 10. Como CPU é medida?

> No Android, a CPU é obtida por platform channel, com leitura de informações do processo. Quando o canal não está disponível, o pacote usa valor sentinela para evitar erro.

### 11. Como bateria é medida?

> A bateria é lida por platform channel no Android, usando `BatteryManager` para nível de carga e estado de carregamento.

### 12. O pacote mede consumo elétrico real?

> Não. Ele observa proxies técnicos associados ao consumo, como CPU, rede, frames e memória. Medição elétrica direta exigiria outro tipo de instrumentação.

### 13. Como as recomendações são geradas?

> O `Analyzer` identifica sintomas e o `Recommender` transforma esses sintomas em mensagens por severidade. As regras são heurísticas, explicáveis e leves.

### 14. Por que não usar machine learning?

> Porque o escopo exigia uma solução leve, explicável e adequada ao uso embarcado no app. Machine learning exigiria base de dados, treinamento e validação bem mais ampla.

### 15. As recomendações podem gerar falso positivo?

> Sim. Elas indicam sintomas prováveis, não diagnóstico definitivo. Por isso servem como orientação inicial para investigação.

### 16. Qual é o papel da exportação?

> A exportação preserva sessões em JSON e timings de frame em CSV, permitindo inspecionar dados fora do painel e documentar execuções.

### 17. O que os 60 testes comprovam?

> Eles comprovam contratos internos da implementação: cálculos, recomendações, serialização, exportação e fallback dos canais nativos. Eles não substituem validação experimental de desempenho.

### 18. Por que publicar no pub.dev é importante?

> Porque o pacote fica instalável pelo ecossistema oficial Dart/Flutter, aumenta a reprodutibilidade e permite que outros desenvolvedores testem e evoluam a ferramenta.
>
> No momento documentado nos slides, ele aparece como versão 0.1.3 e com 32 pessoas usando no pub.dev.

### 19. O pacote pode ser usado em produção?

> O foco principal é desenvolvimento, depuração, ensino e pesquisa. Em produção, seria necessário controlar ativação, retenção de dados, privacidade e custo de coleta.

### 20. Qual seria o próximo passo técnico?

> Eu priorizaria uma validação quantitativa formal, com múltiplos dispositivos, rodadas repetidas, comparação sistemática com ferramentas externas e avaliação com desenvolvedores Flutter.

## Plano se estiver atrasada

Se chegar no slide 10 com mais de 10min40s:

- No slide 10, cite um número por cenário e avance.
- No slide 11, diga apenas que as evidências são capturas, logs, ADB, exportação e testes.
- No slide 12, cite "60 testes" e a distribuição geral.
- Preserve dashboard, publicação e conclusão, mesmo que mais curtos.

## Plano se sobrar tempo

Se chegar no slide 13 com menos de 12min30s:

- Explique melhor a diferença entre validação funcional e benchmark.
- Explique P95 com calma.
- Relacione o dashboard com a dimensão humana apresentada no início.
- Reforce que a publicação no pub.dev amplia reprodutibilidade.
- Dê um exemplo de recomendação gerada pelo pacote.

## Frases de segurança

Use quando a banca tentar puxar para algo que não foi feito:

> Esse ponto não foi medido de forma estatística neste trabalho; ele ficou como trabalho futuro.

> A evidência aqui é funcional e qualitativa, não uma comparação formal de precisão.

> Profiler e Perfetto são ferramentas de aprofundamento. O pacote atua antes, na triagem integrada ao app.

> O resultado mostra operacionalidade e coerência dos sinais nos cenários controlados, dentro do escopo definido na monografia.

## Fechamento para ensaio

Última fala para repetir no treino:

> A biblioteca desenvolvida não promete resolver automaticamente todos os problemas de desempenho. Ela reduz a distância entre desenvolver e perceber que existe algo a investigar. A contribuição é trazer o primeiro diagnóstico para dentro do fluxo Flutter, com coleta, análise, dashboard, recomendações, exportação, evidências funcionais e testes automatizados.
