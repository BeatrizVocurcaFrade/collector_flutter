# Roteiro literal de apresentação - treino para 20 minutos

Este arquivo acompanha `slides/main.tex` e foi escrito para ser lido em voz alta no ensaio. A ideia aqui é ter um texto quase palavra por palavra, com marcação de tempo, transições e respostas preparadas para a banca.

Use este roteiro como base, mas fale com naturalidade. Se uma frase ficar estranha na sua voz, troque por uma frase equivalente, mantendo a ideia.

## Como treinar

- Treine com cronômetro e slides abertos.
- No primeiro treino, leia tudo sem tentar acelerar.
- No segundo treino, marque onde passou do tempo.
- No terceiro treino, fale olhando mais para a banca do que para o texto.
- Meta realista: terminar entre 19min30s e 20min30s.
- Se a banca interromper, responda direto e volte para a transição do slide.

## Como usar este roteiro no dia

- O texto da seção "Roteiro falado" é a versão para ensaio literal.
- As seções de apoio depois do roteiro não são para ler na apresentação; elas servem para ganhar segurança.
- Se travar, volte para a frase de memorizar do slide. Ela sempre resume o ponto principal.
- Se uma pergunta vier no meio da fala, responda em três passos: resposta direta, evidência do trabalho e limite metodológico.
- Se perceber que está acelerando, diminua no começo da frase seguinte. A banca entende pausa; o que atrapalha é perder clareza.
- Se esquecer um número, não tente improvisar outro. Diga a ordem de grandeza ou retome o conceito.
- Não peça desculpas pelas limitações. Trate-as como delimitação honesta do estudo.
- Sempre que falar de Profiler, Perfetto ou ADB, reforce que o trabalho é complementar a essas ferramentas.
- Sempre que falar dos resultados, use "evidência funcional e qualitativa", não "benchmark".
- Termine a conclusão com firmeza, mesmo que precise encurtar slides anteriores.

## Resposta-padrão para perguntas difíceis

Use este formato quando a banca fizer uma pergunta longa ou crítica:

> A resposta curta é: [sim/não/depende]. No trabalho, eu tratei isso da seguinte forma: [evidência concreta]. O limite é que [limitação]. Então eu não afirmo [superinterpretação]; eu afirmo [conclusão segura].

Exemplo:

> A resposta curta é: não, eu não medi overhead de forma estatística. No trabalho, eu tratei overhead como requisito e mantive o pacote operável no aplicativo de exemplo. O limite é que não houve comparação repetida com e sem o coletor em múltiplos dispositivos. Então eu não afirmo um percentual medido; eu afirmo que a medição formal de overhead é o próximo passo experimental.

## Mapa de tempo

| Slide | Tema | Tempo alvo | Acumulado |
| --- | --- | ---: | ---: |
| 1 | Capa | 0min35s | 0min35s |
| 2 | Roteiro da defesa | 0min35s | 1min10s |
| 3 | Ponto de partida | 1min05s | 2min15s |
| 4 | Problema de pesquisa | 1min10s | 3min25s |
| 5 | Objetivos | 1min00s | 4min25s |
| 6 | Base científica | 1min15s | 5min40s |
| 7 | Lacuna identificada | 1min00s | 6min40s |
| 8 | Humanidades | 0min55s | 7min35s |
| 9 | Proposta | 1min10s | 8min45s |
| 10 | Arquitetura | 1min15s | 10min00s |
| 11 | Dashboard integrado | 1min05s | 11min05s |
| 12 | Metodologia | 1min10s | 12min15s |
| 13 | Cenários testados | 1min10s | 13min25s |
| 14 | Evidências dos cenários | 1min00s | 14min25s |
| 15 | Resultados observados | 1min45s | 16min10s |
| 16 | ADB, Profiler e limites | 1min25s | 17min35s |
| 17 | Testes automatizados | 1min00s | 18min35s |
| 18 | Limitações e trabalhos futuros | 0min50s | 19min25s |
| 19 | Conclusão | 0min40s | 20min05s |
| 20 | Perguntas | 0min10s | 20min15s |

Se você estiver 1 minuto atrasada no slide 15, reduza a fala dos slides 16, 17 e 18. Não corte a conclusão.

## Marcos de controle de tempo

Use estes pontos para saber se a apresentação está dentro do ritmo:

| Momento | Onde você deve estar | Se estiver atrasada | Se estiver adiantada |
| --- | --- | --- | --- |
| 5 minutos | Entre slides 5 e 6 | Encurte exemplos da base científica. | Respire mais nas transições. |
| 10 minutos | Fechando arquitetura | Não detalhe demais Data/Domain/Presentation. | Explique melhor o fluxo do pacote. |
| 15 minutos | Meio do slide 15 | Cite um número por cenário. | Diferencie funcional de estatístico. |
| 18 minutos | Slide 17 ou 18 | Corte detalhes de testes e futuros. | Reforce limites sem parecer defensiva. |
| 20 minutos | Conclusão/perguntas | Vá direto para a frase final. | Não invente conteúdo novo. |

Regra simples:

> Se estiver atrasada, corte explicações; não corte evidências nem conclusão.

## Tese em uma frase

> O `collector_flutter` aproxima o primeiro diagnóstico de desempenho do fluxo real de desenvolvimento Flutter ao coletar métricas dentro do próprio aplicativo, interpretar sintomas de degradação e exibir recomendações em um dashboard integrado.

Versão mais natural para falar:

> O meu trabalho propõe uma espécie de termômetro embarcado para aplicativos Flutter: ele observa sinais vitais do app, interpreta esses sinais e ajuda o desenvolvedor a saber onde investigar primeiro.

Versão de 10 segundos:

> Eu desenvolvi uma biblioteca Flutter que coleta sinais de desempenho dentro do app e mostra um primeiro diagnóstico para o desenvolvedor.

Versão de 30 segundos:

> O `collector_flutter` é uma biblioteca embarcada em aplicações Flutter. Ele coleta métricas como FPS, jank, memória, rede, CPU, bateria e rebuilds, analisa sintomas por heurísticas e apresenta recomendações em um dashboard integrado. A proposta é reduzir o atrito do primeiro diagnóstico, sem substituir DevTools, Profiler ou Perfetto.

Versão de 1 minuto:

> O trabalho parte de um problema prático: ferramentas de profiling são poderosas, mas muitas vezes ficam fora do fluxo cotidiano do desenvolvimento. O `collector_flutter` tenta aproximar esse primeiro diagnóstico do aplicativo em desenvolvimento. Para isso, ele coleta métricas de desempenho, processa sintomas, exibe recomendações e permite exportar sessões. A avaliação foi feita por cenários controlados no app de exemplo, com capturas reais, logs, apoio qualitativo por ADB e 60 testes automatizados. O resultado sustenta operacionalidade e coerência dos sinais, mas não uma validação estatística completa.

## Mapa mental da defesa

Se precisar reconstruir a apresentação de memória, siga esta linha:

1. Flutter aumenta produtividade, mas desempenho continua sendo parte da experiência.
2. Ferramentas externas existem e são fortes, mas têm atrito de uso contínuo.
3. A lacuna está entre coletar dados e transformar dados em ação inicial.
4. O `collector_flutter` entra como primeiro diagnóstico dentro do app.
5. A arquitetura separa coleta, análise e apresentação.
6. O dashboard torna sintomas visíveis.
7. A validação foi funcional: cenários induzidos, imagens reais, logs e ADB qualitativo.
8. Os testes automatizados verificam contratos internos.
9. A limitação central é não haver benchmark estatístico.
10. O próximo passo é validação quantitativa com múltiplos dispositivos e comparação formal.

## Roteiro falado

### Slide 1 - Capa - 0min35s

Fala literal:

> Boa tarde. Eu sou a Beatriz Vocurca Frade e vou apresentar o meu trabalho de conclusão de curso, com o tema "Monitoramento e otimização de recursos em aplicativos Flutter".
>
> O foco do trabalho é o `collector_flutter`, uma biblioteca que eu desenvolvi para coletar métricas de desempenho dentro de uma aplicação Flutter, analisar sinais de degradação e apresentar recomendações para o desenvolvedor.
>
> A ideia central é aproximar o diagnóstico de performance do fluxo real de desenvolvimento, sem substituir ferramentas especializadas.

Transição:

> Para guiar a apresentação, eu organizei a defesa em seis partes.

Se quiser soar mais natural:

> Eu vou tentar equilibrar aqui a parte técnica do pacote com os limites reais da avaliação, porque isso é importante para entender a contribuição do trabalho.

### Slide 2 - Roteiro da defesa - 0min35s

Fala literal:

> A apresentação começa com o contexto e o problema de pesquisa. Depois eu passo pela base científica e pela lacuna que motivou a solução.
>
> Em seguida, apresento o `collector_flutter`, a arquitetura e o dashboard. Na segunda metade, explico a metodologia, os cenários controlados, os resultados observados, os testes automatizados e, por fim, as limitações, os trabalhos futuros e a conclusão.
>
> Então a lógica da defesa é: problema, solução, método, evidência e fechamento.

Transição:

> O ponto de partida é o próprio cenário de desenvolvimento Flutter.

### Slide 3 - Ponto de partida - 1min05s

Fala literal:

> Flutter se tornou uma opção muito forte para desenvolvimento mobile porque permite criar aplicações multiplataforma com uma única base de código. Isso aumenta produtividade, facilita manutenção e acelera entrega.
>
> Mas essa produtividade não elimina o desafio de desempenho. Aplicativos modernos combinam muita coisa ao mesmo tempo: listas dinâmicas, animações, chamadas de rede, estado reativo, processamento local e execução em dispositivos muito diferentes entre si.
>
> Quando o desempenho degrada, o usuário percebe de forma bem concreta: a tela engasga, o app demora para responder, a bateria acaba mais rápido ou o aparelho esquenta. Então performance deixa de ser apenas um detalhe técnico e passa a fazer parte da experiência de uso.
>
> Por isso, a pergunta que motivou o trabalho é como observar esses sinais enquanto o aplicativo ainda está sendo construído.

Transição:

> O problema é que, apesar de existirem ferramentas muito boas, o diagnóstico ainda costuma ficar fora do fluxo normal do app.

Frase para memorizar:

> Performance em Flutter precisa ser observada durante o desenvolvimento, não só no final.

### Slide 4 - Problema de pesquisa - 1min10s

Fala literal:

> Hoje já existem ferramentas fortes para profiling e diagnóstico. Flutter DevTools, Android Profiler, Perfetto, Instruments e outras soluções conseguem entregar dados detalhados sobre execução, renderização, memória e consumo.
>
> O problema não é falta de ferramenta. O problema é o atrito para usar essas ferramentas de forma contínua. Em geral, elas exigem conexão externa, configuração, troca de contexto, leitura de gráficos e interpretação manual dos dados.
>
> Na prática, isso faz com que a análise de desempenho muitas vezes aconteça tarde: quando o problema já ficou visível, quando o app já está pesado ou quando alguém finalmente decide abrir uma ferramenta externa para investigar.
>
> Então a pergunta de pesquisa ficou assim: como tornar o diagnóstico de desempenho mais acessível, contínuo e acionável em Flutter?
>
> A palavra "acionável" é importante, porque não basta mostrar número. O desenvolvedor precisa entender o que aquele número sugere.

Transição:

> A partir dessa pergunta, eu defini os objetivos do trabalho.

Frase para memorizar:

> A lacuna não é falta de dado; é transformar dado em ação no momento certo.

### Slide 5 - Objetivos - 1min00s

Fala literal:

> O objetivo geral foi desenvolver e avaliar funcionalmente o `collector_flutter`, uma biblioteca Dart e Flutter embarcada na própria aplicação.
>
> O pacote deveria coletar métricas como FPS, jank, memória, rede, CPU, bateria, eventos e rebuilds. Além da coleta, ele precisava organizar esses dados, analisar sintomas de degradação, exibir um dashboard integrado e gerar recomendações por severidade.
>
> Também fez parte do escopo exportar sessões em JSON e CSV, porque isso permite que o desenvolvedor leve os dados para uma análise externa quando quiser.
>
> E, por fim, a ferramenta foi validada em cenários controlados, com o objetivo de verificar se ela permanece operável e se os sinais exibidos acompanham os sintomas induzidos.

Transição:

> Para escolher essas métricas e organizar a proposta, a revisão bibliográfica foi essencial.

Frase para memorizar:

> O pacote junta coleta, análise, visualização e recomendação em uma única experiência.

### Slide 6 - Base científica - 1min15s

Fala literal:

> A literatura ajudou principalmente em três pontos.
>
> O primeiro ponto é energia. Trabalhos como os de Pathak, Hao, Li e Hoque mostram que consumo em dispositivos móveis está relacionado a fatores como CPU, rede, tempo de execução e memória. O `collector_flutter` não mede corrente elétrica diretamente, mas observa sinais de software que ajudam a levantar hipóteses sobre uso de recursos.
>
> O segundo ponto é performance móvel. Trabalhos como AppInsight e estudos sobre comportamento de aplicações móveis reforçam que olhar uma métrica isolada costuma ser insuficiente. FPS, frames longos, memória, rede e CPU precisam ser analisados em conjunto.
>
> O terceiro ponto é diagnóstico. A ideia não é só coletar telemetria, mas transformar sintomas observáveis em hipóteses de otimização. Por exemplo: muitos frames longos podem indicar gargalo de renderização; muitas requisições simultâneas podem sugerir problema de rede ou arquitetura.
>
> Então a revisão sustenta a decisão de observar vários sinais ao mesmo tempo.

Transição:

> Mesmo com essa base e com ferramentas maduras, ainda existe um espaço específico para a proposta deste trabalho.

Frase para memorizar:

> Desempenho móvel é multidimensional.

### Slide 7 - Lacuna identificada - 1min00s

Fala literal:

> A lacuna identificada fica entre medir e agir.
>
> As ferramentas de referência são excelentes para investigação profunda. Eu não estou dizendo que DevTools, Profiler ou Perfetto são insuficientes tecnicamente. Pelo contrário: elas são muito importantes.
>
> O espaço do `collector_flutter` é outro. Ele busca oferecer um primeiro diagnóstico com baixa fricção, dentro do próprio app, durante o ciclo normal de desenvolvimento.
>
> Então, em vez de o desenvolvedor precisar sair imediatamente para uma ferramenta externa, ele recebe um alerta inicial no próprio ambiente da aplicação. Depois, se o problema exigir análise mais profunda, aí sim faz sentido abrir Profiler, Perfetto ou outra ferramenta especializada.

Transição:

> Essa discussão também tem impacto além da técnica, e por isso aparece no capítulo de humanidades.

Frase para memorizar:

> O `collector_flutter` não substitui ferramentas externas; ele aponta onde vale investigar primeiro.

### Slide 8 - Humanidades - 0min55s

Fala literal:

> Performance também tem uma dimensão social, ambiental e ética.
>
> Um aplicativo pesado não prejudica todos os usuários da mesma forma. Em aparelhos de entrada, com menos memória, menos bateria ou processadores mais simples, a degradação aparece mais cedo e com mais impacto.
>
> Então otimizar recursos também significa melhorar acessibilidade prática, aumentar a vida útil percebida do dispositivo e reduzir desperdício de energia.
>
> Existe também uma preocupação com privacidade. O `collector_flutter` foi pensado para coletar métricas técnicas de desempenho, como frames, eventos, rede e uso de recursos. Ele não precisa coletar conteúdo pessoal do usuário para cumprir seu papel.
>
> Por isso, a discussão de humanidades reforça que eficiência não é só conveniência técnica.

Transição:

> Com esse contexto, eu entro na solução proposta.

Frase para memorizar:

> Otimizar recursos é respeitar o dispositivo e o contexto de uso.

### Slide 9 - Proposta: `collector_flutter` - 1min10s

Fala literal:

> O `collector_flutter` é um pacote Dart e Flutter de código aberto que funciona dentro da própria aplicação monitorada.
>
> Ele coleta métricas durante a execução, analisa sintomas por heurísticas, classifica recomendações por severidade, exibe essas informações em um dashboard e permite exportar os dados.
>
> Eu gosto de resumir a proposta como um termômetro embarcado. Um termômetro não substitui um exame médico completo, mas ajuda a perceber rapidamente que existe algo errado e que vale investigar. O pacote tem essa mesma função no contexto de desempenho: ele observa sinais vitais do app e mostra onde olhar primeiro.
>
> A contribuição, então, não é criar mais um painel de números soltos. É integrar coleta, interpretação e orientação inicial dentro do fluxo Flutter.

Transição:

> Para que essa proposta fosse extensível, a implementação foi organizada em três camadas.

Frase para memorizar:

> A ferramenta mora dentro do app e transforma telemetria em orientação inicial.

### Slide 10 - Arquitetura - 1min15s

Fala literal:

> A arquitetura foi dividida em três camadas principais: Data, Domain e Presentation.
>
> A camada Data concentra as fontes de dados. É nela que ficam as leituras relacionadas a frames, memória, rede, eventos, CPU e bateria. Ela lida com a coleta e com a comunicação com recursos da plataforma quando necessário.
>
> A camada Domain contém as entidades, os casos de uso, o Analyzer e o Recommender. Essa é a parte que transforma dados brutos em informação mais útil. Por exemplo, ela calcula estatísticas, identifica sintomas e gera recomendações.
>
> A camada Presentation é a parte visual, com o dashboard e gerenciamento de estado com Bloc. Ela mostra os indicadores e recomendações para o desenvolvedor.
>
> Essa separação foi importante porque permitiu evoluir o pacote sem misturar responsabilidades. CPU, bateria e exportação puderam ser adicionadas de forma mais organizada.

Transição:

> A parte mais visível dessa arquitetura é o dashboard integrado.

Frase para memorizar:

> Separar coleta, análise e apresentação foi essencial para evoluir o pacote.

### Slide 11 - Dashboard integrado - 1min05s

Fala literal:

> Aqui aparecem duas telas reais do painel.
>
> À esquerda, temos uma condição mais estável. Os indicadores estão em faixas aceitáveis e a recomendação é mais informativa.
>
> À direita, aparece uma condição com gargalos. O painel mostra alertas, eventos de rede, sinais de degradação e recomendações mais severas.
>
> O ponto importante é que o desenvolvedor não precisa olhar apenas logs ou números isolados. Ele consegue bater o olho e entender se existe algo que merece investigação.
>
> O dashboard também ajuda na comunicação do diagnóstico, porque transforma dados técnicos em uma leitura visual mais direta.

Transição:

> Depois da implementação, a ferramenta foi avaliada por meio de cenários controlados.

Frase para memorizar:

> O dashboard é o ponto em que métrica vira diagnóstico visual.

### Slide 12 - Metodologia - 1min10s

Fala literal:

> A metodologia do trabalho foi aplicada e funcional.
>
> Ela começa com revisão bibliográfica e definição de requisitos. Depois vem a implementação do pacote, a criação do aplicativo de exemplo e a execução de cenários controlados.
>
> Um ponto metodológico importante é que eu trato os resultados como evidência funcional e qualitativa. Isso significa que eu verifico se o pacote executa, coleta sinais, atualiza o painel, gera logs e responde de forma coerente às cargas induzidas.
>
> Mas eu não afirmo que este trabalho fez uma validação estatística completa. Para isso, seriam necessárias várias rodadas, múltiplos dispositivos, séries comparáveis com ferramentas externas e cálculo formal de erro ou intervalo de confiança.
>
> Então a avaliação foi conservadora no que ela afirma.

Transição:

> Os cenários foram desenhados justamente para provocar sintomas específicos.

Frase para memorizar:

> A validação mostra operacionalidade e coerência dos sintomas, não precisão formal.

### Slide 13 - Cenários testados - 1min10s

Fala literal:

> Foram definidos quatro cenários controlados no aplicativo de exemplo.
>
> O primeiro cenário força rebuilds, ou seja, reconstruções intensivas da interface. Ele serve para observar impacto em renderização e frames.
>
> O segundo cenário dispara requisições HTTP simultâneas. Nesse caso, o foco é observar eventos de rede, latências e possível impacto na fluidez.
>
> O terceiro cenário provoca alocação intensiva de memória, para observar crescimento do processo e comportamento do painel.
>
> O quarto cenário combina várias cargas: interface, rede, memória e CPU. Ele é importante porque aplicações reais raramente têm um único gargalo isolado.
>
> Em todos os casos, a pergunta era: o painel acompanha o comportamento esperado?

Transição:

> Para tornar essa validação auditável, eu registrei imagens reais do aplicativo.

Frase para memorizar:

> Cada cenário provoca um sintoma esperado; o painel precisa tornar esse sintoma visível.

### Slide 14 - Evidências dos cenários - 1min00s

Fala literal:

> Essas capturas foram geradas no próprio projeto, usando o aplicativo de exemplo.
>
> Elas documentam os quatro cenários: rebuilds, rede, memória e carga combinada. A intenção foi evitar que a monografia ficasse apenas em descrição textual. Com as imagens, dá para conferir visualmente o estado do painel durante cada execução.
>
> Essas evidências também foram preservadas no Apêndice B da monografia, junto com leituras ADB e logs da aplicação.
>
> Então, quando eu falo que houve avaliação funcional, não estou falando de uma suposição. Houve execução real, captura do app e registro dos sinais observados.

Transição:

> A partir dessas execuções, alguns resultados apareceram nos logs, no painel e nas leituras ADB.

Frase para memorizar:

> As imagens tornam a validação mais concreta e rastreável.

### Slide 15 - Resultados observados - 1min45s

Fala literal:

> Este slide resume os principais sinais observados nos cenários.
>
> No cenário de rebuilds, o log registrou 30 reconstruções, FPS estimado de 55,4, P95 de 20,4 milissegundos e 2 frames longos. Isso indica que o painel reagiu à carga de interface.
>
> No cenário de rede, foram registradas 9 requisições, FPS de 42,9, P95 de 139,5 milissegundos e 4 frames longos. Aqui o interceptador conseguiu registrar eventos e latências, e o painel indicou degradação.
>
> No cenário de memória, o ADB registrou RSS total de 236.480 KB e PSS total de 222.232 KB. Esse dado mostra crescimento real de memória no processo, embora o snapshot interno do painel tenha apresentado limitação na leitura. Por isso essa divergência foi documentada como limitação.
>
> No cenário combinado, apareceram 17 requisições, 54 rebuilds, FPS de 44,6, P95 de 37,7 milissegundos e CPU de 75,3%. Esse foi o cenário em que vários sinais apareceram ao mesmo tempo, e o sistema conseguiu priorizar alertas.
>
> A leitura correta desses resultados é: eles mostram operacionalidade e coerência dos sintomas. Eles não devem ser interpretados como benchmark estatístico.

Transição:

> Para não superinterpretar esses números, é importante explicar o papel do ADB, do Profiler e dos limites da avaliação.

Frase para memorizar:

> O resultado principal é que os sinais acompanharam os sintomas induzidos.

### Slide 16 - ADB, Profiler e limites - 1min25s

Fala literal:

> A avaliação usou ADB como apoio qualitativo. Em especial, foram usados `adb shell dumpsys meminfo` e `adb shell dumpsys gfxinfo`, além dos logs do aplicativo e das capturas do emulador.
>
> O `meminfo` trouxe leituras úteis de memória, como RSS e PSS. Já o `gfxinfo` confirmou a superfície Flutter, mas retornou contadores HWUI zerados nessa execução.
>
> Por causa disso, eu não calculei erro percentual formal de FPS nem apresentei uma série quantitativa comparável com o Android Profiler ou com o Perfetto.
>
> Essa é uma limitação importante, e eu preferi mantê-la explícita na monografia. Android Profiler e Perfetto aparecem como ferramentas de referência conceitual e como caminho para trabalhos futuros, mas não como fonte de uma comparação estatística nesta versão.
>
> Metodologicamente, isso é importante: é melhor afirmar menos com segurança do que forçar uma conclusão que os dados não sustentam.

Transição:

> Além da validação manual, o pacote também foi verificado por testes automatizados.

Frase para memorizar:

> A comparação foi qualitativa; a comparação quantitativa formal fica como trabalho futuro.

### Slide 17 - Testes automatizados - 1min00s

Fala literal:

> A suíte automatizada possui 60 testes aprovados.
>
> Esses testes estão distribuídos em quatro grupos: 24 testes para análise e estatísticas, 17 para CPU e bateria, 12 para recomendações e 7 para exportação.
>
> Eles verificam cálculos internos, regras de recomendação, serialização, exportação em JSON e CSV e comportamento de fallback dos canais nativos.
>
> É importante dizer que esses testes não substituem um experimento de desempenho em dispositivo real. Eles provam contratos internos da implementação. A validação manual, por outro lado, mostra o pacote funcionando no aplicativo de exemplo.
>
> Então as duas coisas se complementam: testes dão confiança na lógica, e os cenários mostram o pacote em uso.

Transição:

> Com isso, ficam claros também os limites do trabalho e os próximos passos.

Frase para memorizar:

> Os 60 testes dão confiança na lógica interna, não uma prova estatística de performance.

### Slide 18 - Limitações e trabalhos futuros - 0min50s

Fala literal:

> As principais limitações são quatro.
>
> Primeiro, a validação foi funcional e qualitativa, sem análise estatística. Segundo, o foco principal foi Android. Terceiro, ainda não houve estudo formal de usabilidade com desenvolvedores Flutter. Quarto, a comparação com ADB foi usada como apoio qualitativo, não como benchmark completo.
>
> Como trabalhos futuros, eu proponho rodadas quantitativas com múltiplos dispositivos, séries comparáveis com Profiler, Perfetto e ADB, suporte mais completo para iOS e avaliação com desenvolvedores reais.
>
> Essas limitações não invalidam o trabalho. Elas delimitam exatamente o que ele entrega e o que ainda precisa evoluir.

Transição:

> Para concluir, eu volto à contribuição central.

Frase para memorizar:

> O trabalho entrega uma base funcional e deixa claro o caminho para validação quantitativa.

### Slide 19 - Conclusão - 0min40s

Fala literal:

> A conclusão principal é que é viável aproximar o primeiro diagnóstico de desempenho do fluxo real de desenvolvimento Flutter.
>
> O `collector_flutter` coleta sinais, interpreta sintomas e apresenta recomendações dentro do próprio aplicativo. A arquitetura em camadas permitiu evoluir o pacote com CPU, bateria, exportação e testes.
>
> A validação funcional mostrou que o sistema permanece operável e responde aos cenários induzidos, sempre respeitando os limites metodológicos da avaliação.
>
> Então a contribuição do trabalho é técnica, mas também prática: ajudar performance a virar uma preocupação mais contínua e acessível.

Transição:

> Obrigada pela atenção. Fico à disposição para perguntas.

Frase para memorizar:

> Diagnóstico acessível ajuda performance a virar prática cotidiana.

### Slide 20 - Perguntas - 0min10s

Fala literal:

> Obrigada pela atenção. Fico à disposição para perguntas.

Se houver silêncio:

> Posso comentar mais detalhes sobre a arquitetura, sobre os cenários de validação ou sobre os limites da comparação com ADB.

## Versão curta para repetir antes de dormir

> O `collector_flutter` nasce da ideia de que performance precisa ser observada continuamente durante o desenvolvimento. Ele não substitui DevTools, Profiler ou Perfetto, mas oferece um primeiro diagnóstico dentro do app. A validação mostrou funcionamento em quatro cenários controlados, com imagens reais, apoio qualitativo por ADB e 60 testes automatizados. O trabalho entrega uma base funcional e deixa claro o próximo passo: validação quantitativa formal.

## Números que você precisa saber de cabeça

| Item | Número | Como falar |
| --- | ---: | --- |
| Cenários controlados | 4 | Rebuilds, rede, memória e carga combinada. |
| Testes automatizados | 60 | Lógica interna, recomendações, CPU/bateria e exportação. |
| Rebuilds no cenário de interface | 30 | Indicam que a carga de interface foi registrada. |
| FPS no cenário de rebuilds | 55,4 | Queda moderada, com P95 de 20,4 ms. |
| Requisições no cenário de rede | 9 | O interceptador registrou eventos e latências. |
| P95 no cenário de rede | 139,5 ms | Indica frames mais longos sob carga. |
| Memória no ADB | RSS 236.480 KB e PSS 222.232 KB | Mostra crescimento real no processo. |
| Carga combinada | 17 requisições, 54 rebuilds, CPU 75,3% | Vários sinais apareceram juntos. |

## Perguntas prováveis da banca

### 1. Por que não usar apenas Flutter DevTools ou Android Profiler?

Resposta para falar:

> Porque DevTools e Android Profiler são ferramentas excelentes, mas ficam fora da aplicação e exigem uma etapa separada de análise. O `collector_flutter` não tenta substituir essas ferramentas. Ele atua antes, como um primeiro diagnóstico integrado ao app, para reduzir fricção e apontar onde vale investigar com mais profundidade.

Se insistirem:

> Eu vejo o pacote como complementar. O painel interno ajuda a perceber o sintoma. A ferramenta externa entra quando eu preciso aprofundar a causa.

### 2. O `collector_flutter` substitui o Perfetto?

Resposta para falar:

> Não. Perfetto é uma ferramenta de tracing profunda, muito mais detalhada e de baixo nível. O `collector_flutter` tem outro objetivo: feedback rápido, integrado e acionável durante o desenvolvimento Flutter. Em trabalhos futuros, Perfetto pode ser usado justamente para comparação quantitativa mais formal.

### 3. Qual é a principal contribuição do trabalho?

Resposta para falar:

> A principal contribuição é mostrar uma forma concreta de aproximar diagnóstico de desempenho do fluxo de desenvolvimento Flutter. O trabalho entrega coleta embarcada, dashboard, recomendações, exportação e testes, organizados em uma arquitetura extensível. A contribuição não é substituir profiling profundo, mas tornar o primeiro diagnóstico mais acessível.

### 4. O que existe de novo em relação a ferramentas já conhecidas?

Resposta para falar:

> A novidade está na integração dentro do próprio app Flutter e na combinação entre coleta, análise heurística, dashboard e recomendações. Ferramentas conhecidas medem com profundidade, mas normalmente fora do app. O `collector_flutter` tenta reduzir essa distância para o primeiro diagnóstico.

### 5. Por que a validação é qualitativa e não quantitativa?

Resposta para falar:

> Porque o protocolo executado avaliou operacionalidade e coerência dos sinais em cenários controlados, mas não teve amostra estatística suficiente, múltiplos dispositivos e séries temporais comparáveis para calcular erro, intervalo de confiança ou overhead formal. Então o texto usa uma afirmação conservadora: validação funcional e qualitativa.

### 6. O que significa dizer que a evidência mostra operacionalidade?

Resposta para falar:

> Significa que o pacote executou, coletou sinais, atualizou o painel, gerou logs e respondeu aos cenários induzidos sem interromper o aplicativo de exemplo. Isso demonstra funcionamento integrado, mas ainda não mede precisão estatística.

### 7. Por que o `gfxinfo` retornou contadores zerados?

Resposta para falar:

> Na execução registrada, o `dumpsys gfxinfo` confirmou a superfície Flutter, mas os agregados HWUI tradicionais vieram zerados. Isso pode ocorrer pela forma como o Flutter renderiza via superfície própria e pela combinação específica de emulador e modo de execução. Por isso eu não usei esse dado para calcular erro de FPS. Mantive a limitação explicitamente no texto.

### 8. Por que o painel mostrou 0,0 MB no cenário de memória?

Resposta para falar:

> Essa foi uma limitação observada no snapshot do painel. Ao mesmo tempo, o ADB registrou RSS total de 236.480 KB e PSS total de 222.232 KB, mostrando que houve crescimento real de memória no processo. O correto foi documentar a divergência como limitação da leitura interna no emulador, não esconder o resultado.

### 9. Os 60 testes provam que o pacote mede desempenho corretamente?

Resposta para falar:

> Não sozinhos. Os 60 testes verificam lógica interna: estatísticas, recomendações, exportação e fallbacks dos canais nativos. Eles dão confiança na implementação, mas não substituem experimentos de desempenho em dispositivos reais. Por isso o trabalho combina testes automatizados com cenários manuais controlados.

### 10. O pacote mede consumo real de energia?

Resposta para falar:

> Não mede corrente elétrica nem consumo energético físico. Ele usa proxies de desempenho associados ao consumo, como CPU, memória, rede, tempo de frame e bateria. A análise energética é inferencial e qualitativa, não uma medição elétrica direta.

### 11. O overhead de 5% foi medido?

Resposta para falar:

> O limite de 5% aparece como requisito não funcional e alvo de projeto. Nesta versão, o overhead foi tratado funcionalmente: o coletor deveria permanecer operável sem bloquear o aplicativo de exemplo. A medição formal de overhead, com comparação com e sem coletor e repetição estatística, fica como trabalho futuro.

### 12. Por que usar heurísticas em vez de machine learning?

Resposta para falar:

> Porque o objetivo era construir uma ferramenta leve, explicável e fácil de integrar. Heurísticas são transparentes: o desenvolvedor entende por que um alerta apareceu. Machine learning exigiria base de dados, treinamento, validação e explicabilidade, o que ampliaria muito o escopo do TCC.

### 13. Como as recomendações são geradas?

Resposta para falar:

> O módulo `Analyzer` resume e identifica sintomas, como FPS baixo, frames longos, uso de CPU ou padrão de rede. O `Recommender` transforma esses sintomas em mensagens por severidade. A recomendação não é uma verdade absoluta; ela orienta a primeira investigação.

### 14. As recomendações podem gerar falso positivo?

Resposta para falar:

> Sim, podem. Como as recomendações são heurísticas, elas apontam sintomas prováveis, não diagnósticos definitivos. Por isso eu trato o pacote como apoio ao primeiro diagnóstico. A decisão final ainda depende da análise do desenvolvedor e, quando necessário, de ferramentas mais profundas.

### 15. O pacote pode ser usado em produção?

Resposta para falar:

> O foco principal é desenvolvimento, depuração e pesquisa. Como ele exibe dashboard e coleta telemetria local, o uso em produção exigiria cuidado com configuração, impacto de desempenho, privacidade e modo de ativação. A proposta do TCC é reduzir fricção durante desenvolvimento.

### 16. O próprio coletor pode alterar as métricas que ele mede?

Resposta para falar:

> Sim, esse risco existe em qualquer ferramenta de monitoramento. Observar o sistema também pode gerar custo. Neste trabalho, eu tratei isso como limitação e requisito de projeto, mas não fiz uma medição formal de overhead. Uma evolução importante seria comparar execuções com e sem o coletor em múltiplos dispositivos.

### 17. Por que usar Clean Architecture?

Resposta para falar:

> Porque separar Data, Domain e Presentation ajudou a manter coleta, regra de análise e interface com responsabilidades distintas. Isso facilitou testes e permitiu adicionar CPU, bateria e exportação sem alterar toda a estrutura. Para um pacote que pode crescer, essa separação ajuda bastante.

### 18. Por que usar Bloc na camada de apresentação?

Resposta para falar:

> O Bloc ajudou a organizar estados do dashboard e eventos de atualização de forma previsível. Como o painel recebe métricas continuamente, era importante ter uma separação clara entre evento, estado e interface. Isso também facilita testes e manutenção.

### 19. Por que escolher Flutter como foco?

Resposta para falar:

> Porque Flutter tem grande adoção, permite desenvolvimento multiplataforma e usa um modelo reativo em que rebuilds, frames e renderização são pontos importantes para a experiência. Além disso, o ecossistema se beneficia de ferramentas que se integrem ao fluxo do desenvolvedor Flutter.

### 20. Como o pacote lida com privacidade?

Resposta para falar:

> A proposta é coletar métricas técnicas de desempenho, não conteúdo pessoal do usuário. O pacote observa sinais como frames, eventos, rede, memória, CPU e bateria. Para uso fora de ambiente de desenvolvimento, ainda seria necessário configurar coleta, exportação e retenção de dados com cuidado.

### 21. O suporte a iOS está completo?

Resposta para falar:

> Não completamente. O foco principal da validação foi Android. O pacote foi pensado com arquitetura que permite evolução multiplataforma, mas CPU, energia e validação em iOS precisam de aprofundamento em trabalhos futuros.

### 22. Como os limiares das recomendações foram definidos?

Resposta para falar:

> Eles foram definidos de forma heurística, a partir de referências de desempenho, literatura e comportamento esperado em aplicações móveis. Esse é um ponto que pode evoluir. Em uma etapa futura, os limiares poderiam ser calibrados com dados reais de múltiplos dispositivos e tipos de aplicação.

### 23. Qual foi a principal limitação técnica encontrada?

Resposta para falar:

> A principal limitação foi obter uma comparação quantitativa confiável com ferramentas externas no ambiente disponível. O `gfxinfo` retornou contadores zerados e a leitura interna de memória apresentou divergência no snapshot. Por isso, a validação ficou funcional e qualitativa.

### 24. Se você tivesse mais tempo, qual seria o próximo passo?

Resposta para falar:

> Eu priorizaria uma validação quantitativa formal: múltiplos dispositivos, várias rodadas por cenário, comparação com e sem o coletor, séries comparáveis com Profiler, Perfetto e ADB, e análise de overhead. Isso transformaria a evidência funcional em um estudo experimental mais robusto.

### 25. Qual é o ponto mais fraco do trabalho?

Resposta para falar:

> O ponto mais fraco é a ausência de validação quantitativa ampla. O trabalho entrega uma solução funcional, testada e documentada, mas ainda não mede precisão, overhead e comportamento em múltiplos dispositivos de forma estatística. Por isso eu deixei essa limitação clara e propus como próximo passo.

### 26. O que você aprendeu tecnicamente com o trabalho?

Resposta para falar:

> Eu aprendi principalmente que monitoramento de desempenho não é só coletar métrica. É preciso pensar em arquitetura, custo da coleta, interpretação dos sinais, visualização, exportação e limites metodológicos. Também aprendi a importância de não exagerar conclusões quando os dados ainda são funcionais e qualitativos.

### 27. Como você defenderia o trabalho em uma frase?

Resposta para falar:

> Eu defenderia dizendo que o `collector_flutter` torna o primeiro diagnóstico de desempenho mais próximo, mais visível e mais acionável para quem desenvolve aplicativos Flutter.

## Perguntas difíceis com resposta curta

Use estas quando a banca fizer uma pergunta longa e você precisar ganhar clareza.

**"Isso é benchmark?"**

> Não. É validação funcional e qualitativa. Benchmark formal fica como trabalho futuro.

**"Isso substitui Profiler?"**

> Não. Ele ajuda antes, no primeiro alerta. Profiler entra na investigação profunda.

**"Você mediu overhead?"**

> Não de forma estatística. Eu tratei overhead como requisito e limitação, mas a medição formal é trabalho futuro.

**"Os dados são suficientes?"**

> São suficientes para sustentar operacionalidade. Não são suficientes para sustentar precisão estatística.

**"Por que vale como TCC?"**

> Porque há uma solução implementada, fundamentada, testada, documentada e avaliada funcionalmente, com limitações explicitadas.

## Frases de segurança

Use estas frases se precisar responder com cuidado:

- "Eu prefiro ser conservadora metodologicamente aqui."
- "Essa evidência sustenta operacionalidade, mas não precisão estatística."
- "O ponto aqui não é substituir ferramentas especializadas, e sim reduzir o atrito do primeiro diagnóstico."
- "Essa limitação foi mantida no texto justamente para não superinterpretar os dados."
- "Os testes automatizados verificam contratos internos; a validação experimental exige outro tipo de protocolo."
- "Como trabalho futuro, eu transformaria essa observação funcional em uma comparação quantitativa com múltiplas rodadas e dispositivos."

## Plano B se estiver atrasada

Se chegar no slide 12 com mais de 13 minutos:

- No slide 13, cite os quatro cenários em uma frase.
- No slide 14, diga só que as imagens são reais e estão no apêndice.
- No slide 15, cite apenas um número de cada cenário.
- No slide 16, diga direto: "ADB foi apoio qualitativo; Profiler e Perfetto ficaram como referência conceitual."
- Não corte a conclusão.

## Plano B se sobrar tempo

Se chegar no slide 18 com menos de 18 minutos:

- Explique melhor a diferença entre validação funcional e estatística.
- Reforce que o pacote é complementar a DevTools, Profiler e Perfetto.
- Comente que as imagens foram geradas no próprio projeto, não são ilustrativas.
- Diga que o próximo passo natural é medir overhead com e sem o coletor.

## Checklist final antes da defesa

- Abrir `slides/main.pdf` e conferir se as imagens aparecem.
- Treinar uma vez olhando para o roteiro e outra olhando para os slides.
- Memorizar a tese em uma frase.
- Memorizar os quatro cenários.
- Memorizar os 60 testes.
- Saber explicar por que a validação é funcional e qualitativa.
- Saber responder por que Profiler e Perfetto não foram usados como comparação quantitativa.
- Encerrar com segurança, sem pedir desculpas pelas limitações.

## Fechamento para ensaio

Última fala para repetir no treino:

> O `collector_flutter` não promete resolver todos os problemas de desempenho. Ele promete reduzir a distância entre desenvolver e perceber que existe algo a investigar. Essa é a contribuição: trazer o primeiro diagnóstico para dentro do fluxo Flutter, com coleta, análise, dashboard, recomendações e uma validação funcional honesta sobre seus limites.
