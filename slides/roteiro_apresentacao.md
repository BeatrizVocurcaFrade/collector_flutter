# Roteiro de apresentação e guia de estudo - 30 minutos

Este arquivo é para estudar, ensaiar e responder perguntas da banca. Ele não é um texto para decorar palavra por palavra. A ideia é você entender a história do trabalho e conseguir explicar com naturalidade.

## Tese em uma frase

O `collector_flutter` aproxima o diagnóstico de desempenho do fluxo real de desenvolvimento Flutter ao coletar métricas dentro do próprio aplicativo, analisar sintomas de degradação e mostrar recomendações acionáveis em um dashboard integrado.

Versão mais curta para falar:

> O meu trabalho propõe um termômetro embarcado para aplicativos Flutter: ele coleta sinais vitais do app, interpreta esses sinais e ajuda o desenvolvedor a agir antes que o problema chegue ao usuário.

## Linha narrativa da defesa

1. Flutter facilita criar apps multiplataforma, mas apps modernos ficaram mais complexos.
2. Desempenho ruim afeta experiência, bateria, inclusão digital e sustentabilidade.
3. Ferramentas como DevTools, Android Profiler e Perfetto são fortes, mas externas e exigem interpretação manual.
4. A literatura mostra que métricas de software ajudam a entender energia, desempenho e gargalos.
5. A lacuna é transformar dados em ação dentro do fluxo diário do desenvolvedor Flutter.
6. O `collector_flutter` resolve essa lacuna com coleta embarcada, análise heurística, dashboard e recomendações.
7. O protótipo foi organizado em três camadas, validado qualitativamente em cenários controlados e coberto por 48 testes.
8. A principal conclusão é que diagnóstico de desempenho pode ser mais contínuo, acessível e acionável.

## Ritmo geral

- Tempo total: cerca de 30 minutos.
- Abertura, contexto, problema e objetivos: 6 minutos.
- Trabalhos relacionados e lacuna: 6 minutos.
- Humanidades e proposta: 4 minutos.
- Arquitetura, fluxo, métricas e integração: 6 minutos.
- Metodologia e cenários: 4 minutos.
- Resultados, evolução, contribuições e conclusão: 4 minutos.

Como não estourar o tempo:

- Não leia tabelas linha por linha.
- Em slides de autores, diga o que cada grupo de trabalhos ensinou.
- Em slides técnicos, explique o fluxo com palavras simples.
- Em resultados, não prometa o que ainda não foi validado estatisticamente.
- Se a banca interromper, responda direto e volte para a narrativa.

## Conceitos que você precisa dominar

### Flutter

Flutter é um framework aberto para criar aplicações multiplataforma com uma única base de código. A vantagem é produtividade. O desafio é que interfaces reativas, animações, estado, rede e widgets reconstruídos com frequência podem gerar custo de renderização, uso de memória e consumo de energia.

Fala simples:

> Flutter acelera o desenvolvimento, mas isso não elimina a necessidade de observar desempenho. Pelo contrário: como o app roda em aparelhos muito diferentes, o diagnóstico contínuo fica ainda mais importante.

### Desempenho

Desempenho no trabalho não é só velocidade. É a combinação de:

- fluidez da interface;
- estabilidade de FPS;
- ausência de `jank`;
- uso controlado de memória;
- rede sem excesso de requisições;
- CPU e bateria em níveis aceitáveis;
- capacidade de funcionar em aparelhos mais simples.

### FPS

FPS significa frames por segundo. Em geral, 60 FPS indica que a interface entrega um quadro a cada aproximadamente 16,67 ms. Quando os frames demoram demais, o usuário percebe engasgos.

Fala simples:

> FPS é uma forma de medir a fluidez. Se a interface demora para desenhar quadros, o usuário não precisa saber o número: ele sente a travada.

### Jank

`Jank` é a percepção de travamento ou engasgo. Tecnicamente, ocorre quando frames excedem o tempo esperado de renderização.

Fala simples:

> Jank é quando o app quebra a sensação de continuidade. A tela ainda funciona, mas a experiência parece pesada.

### Percentis P50, P95 e P99

A média pode esconder problemas. Um app pode ter média aceitável, mas alguns frames muito lentos. Percentis ajudam a enxergar a cauda ruim.

- P50: comportamento típico.
- P95: situação ruim que acontece em 5% dos casos.
- P99: picos mais extremos.

Fala simples:

> Eu uso percentis porque a média pode ser educada demais. Ela esconde aqueles picos que o usuário realmente percebe.

### Rebuilds

Em Flutter, widgets podem ser reconstruídos quando o estado muda. Isso é normal. O problema aparece quando reconstruções acontecem em excesso ou atingem subárvores grandes sem necessidade.

Fala simples:

> Rebuild não é vilão. O problema é rebuild desnecessário ou amplo demais.

### Overhead

`Overhead` é o custo que a própria ferramenta de monitoramento adiciona ao app. Se o coletor for pesado, ele altera aquilo que tenta medir.

Fórmula usada no TCC:

```text
Overhead (%) = ((T_com - T_sem) / T_sem) * 100
```

Onde:

- `T_com`: tempo médio com o coletor ligado;
- `T_sem`: tempo médio sem o coletor.

Como responder:

> O objetivo é que o coletor seja leve o suficiente para não distorcer a aplicação monitorada. Por isso o TCC define overhead máximo de 5% como requisito e trata medições quantitativas formais como etapa que exige repetição, comparação e análise estatística.

### Métricas diretas e proxies de energia

O trabalho não mede corrente elétrica com equipamento físico. Ele usa proxies, isto é, sinais indiretos associados ao consumo:

- CPU;
- memória;
- rede;
- tempo de frame;
- rebuilds;
- eventos de execução;
- bateria como estado do dispositivo.

Fala simples:

> Eu não afirmo que o `collector_flutter` é um medidor elétrico. Ele é uma ferramenta de diagnóstico que usa sinais de software ligados ao consumo e ao desempenho.

## Roteiro por slide

### Slide 1 - Capa - 30s

Objetivo do slide:

- Apresentar você, o tema e o nome do pacote.
- Começar com segurança e sem pressa.

Fala sugerida:

> Boa tarde. Eu sou a Beatriz Vocurca Frade e vou apresentar meu trabalho sobre monitoramento e otimização de recursos em aplicativos Flutter. O foco do trabalho é o `collector_flutter`, uma ferramenta embarcada que busca aproximar o diagnóstico de desempenho do dia a dia do desenvolvimento.

O que precisa ficar claro:

- O objeto do trabalho é uma ferramenta concreta.
- O domínio é Flutter.
- O problema é monitoramento de desempenho e recursos.

Transição:

> Para organizar a apresentação, começo pelo problema, passo pela base científica e depois entro na solução, na metodologia, nos resultados e nas conclusões.

### Slide 2 - Visão geral da defesa - 45s

Objetivo do slide:

- Mostrar o mapa da apresentação.
- Dar sensação de controle.

Fala sugerida:

> A defesa está dividida em seis partes. Primeiro eu contextualizo o problema e os objetivos. Depois apresento os trabalhos relacionados e a lacuna de pesquisa. Em seguida, trago a parte de humanidades, porque desempenho também tem impacto social e ambiental. Depois entro na solução, na metodologia, nos resultados e no fechamento.

O que memorizar:

- Problema.
- Base científica.
- Humanidades.
- Solução.
- Método.
- Resultados.

Se a banca perguntar por que humanidades aparece:

> Porque desempenho não é só uma questão técnica. Um app pesado consome mais recursos, funciona pior em aparelhos de entrada e pode contribuir para obsolescência percebida.

### Slide 3 - Introdução - 1min

Objetivo do slide:

- Explicar o contexto Flutter.
- Mostrar por que desempenho importa.

Fala sugerida:

> O ponto de partida do trabalho é o crescimento do Flutter e a complexidade das aplicações móveis modernas. Hoje um aplicativo normalmente tem listas dinâmicas, animações, chamadas de rede, estado reativo e precisa rodar em aparelhos muito diferentes. Então desempenho deixa de ser um detalhe técnico e passa a fazer parte da experiência do usuário.

Explicação didática:

- Apps modernos fazem muita coisa ao mesmo tempo.
- Em dispositivos móveis, recurso é limitado.
- O mesmo app precisa rodar em celular forte e em celular de entrada.
- Pequenas ineficiências viram travamentos, consumo de bateria e sensação de app pesado.

Transição:

> O problema é que diagnosticar isso ainda costuma exigir ferramentas externas e bastante interpretação manual.

### Slide 4 - Problema de pesquisa - 1min

Objetivo do slide:

- Delimitar a pergunta central.
- Mostrar que o problema não é falta de ferramenta, mas atrito de uso.

Fala sugerida:

> As ferramentas atuais são muito boas tecnicamente. Flutter DevTools, Android Profiler, Perfetto e Instruments entregam dados ricos. A dificuldade está no uso contínuo: elas ficam fora do aplicativo, exigem configuração, conexão, troca de tela e interpretação manual. Na prática, isso cria atrito. O desenvolvedor sabe que a ferramenta existe, mas nem sempre usa durante o ciclo normal de implementação.

Pergunta guia:

> Como tornar o diagnóstico de desempenho mais acessível, contínuo e acionável em Flutter?

Palavras-chave:

- acessível;
- contínuo;
- acionável;
- dentro do fluxo do desenvolvedor.

Se perguntarem "mas DevTools já não resolve?":

> Resolve parte importante do problema. O DevTools continua sendo uma ferramenta essencial. A lacuna do meu trabalho é outra: reduzir o atrito para feedback rápido dentro do próprio app e transformar sintomas em recomendações.

### Slide 5 - Motivação - 1min15s

Objetivo do slide:

- Mostrar que o problema tem peso técnico, social e ambiental.

Fala sugerida:

> A motivação tem três camadas. A primeira é experiência: `jank`, queda de FPS e memória alta tornam o aplicativo menos confiável. A segunda é energia: se o app faz mais trabalho do que precisa, ele tende a consumir mais bateria e aquecer mais o dispositivo. A terceira é inclusão: um app pesado pode funcionar bem em um celular topo de linha, mas ser ruim em um aparelho de entrada.

Explicação mastigada:

- Experiência: usuário percebe travamento.
- Energia: software ineficiente exige mais processamento, rede e memória.
- Inclusão: desempenho ruim afeta mais quem usa aparelhos com menos recursos.

Frase forte:

> Desempenho também é uma forma de respeito ao usuário, ao dispositivo e ao contexto de acesso.

### Slide 6 - Objetivos - 1min30s

Objetivo do slide:

- Apresentar o objetivo geral e os objetivos específicos.

Fala sugerida:

> O objetivo geral foi desenvolver e avaliar o `collector_flutter`, uma biblioteca Dart/Flutter para monitorar desempenho em tempo real dentro do próprio aplicativo. A ferramenta coleta FPS, `jank`, percentis de tempo de frame, memória, rede, eventos customizados, reconstruções, CPU e bateria. Depois, analisa essas métricas e gera recomendações heurísticas organizadas por severidade.

Objetivos específicos em fala simples:

- revisar literatura sobre desempenho, energia e profiling móvel;
- comparar ferramentas existentes;
- projetar arquitetura modular;
- implementar coleta, análise, dashboard e exportação;
- validar o protótipo em cenários controlados;
- manter preocupação com overhead e reprodutibilidade.

Se perguntarem "o que foi entregue?":

> Foi entregue um protótipo funcional, aberto, com módulos de coleta, análise, recomendação, dashboard, exportação JSON/CSV e 48 testes automatizados.

Transição:

> Para sustentar essas escolhas, organizei a revisão bibliográfica em três grupos de trabalhos.

### Slide 7 - Trabalhos relacionados I: energia e métricas - 2min

Objetivo do slide:

- Explicar por que métricas de software podem indicar custo energético e desempenho.

Fala sugerida:

> O primeiro grupo trata de energia e métricas observáveis. Pathak e coautores mostram que chamadas de sistema e uso de componentes do smartphone podem ser relacionados ao consumo de energia. Hao e coautores reforçam essa ideia ao estimar energia por análise de programa. Li e coautores mostram, em aplicações Android reais, que comportamento de software influencia consumo. Hoque e coautores organizam esse campo em uma revisão sobre modelagem, profiling e depuração de energia.

O que cada trabalho te deu:

- Pathak: energia pode ser modelada a partir de eventos do sistema.
- Hao: análise de programa pode estimar consumo.
- Li: apps reais mostram padrões mensuráveis de energia.
- Hoque: visão ampla dos métodos e limites da área.

Como amarrar com o seu trabalho:

> Esses trabalhos justificam o uso de proxies. O `collector_flutter` não mede energia com hardware dedicado, mas monitora sinais ligados ao custo de execução: frame, memória, rede, CPU e eventos.

### Slide 8 - Trabalhos relacionados II: profiling e Flutter - 2min

Objetivo do slide:

- Mostrar como a literatura e as ferramentas existentes influenciam a solução.

Fala sugerida:

> O segundo grupo aproxima a discussão do monitoramento móvel. Ravindranath e coautores, com o AppInsight, mostram a importância de observar desempenho em aplicações reais, durante a execução. Rua e Saraiva reforçam que desempenho móvel deve ser visto em conjunto: energia, tempo de execução e memória. Nawrocki e coautores situam o debate entre frameworks nativos e multiplataforma. E o Flutter DevTools mostra quais métricas são relevantes no ecossistema Flutter.

Diferença importante entre AppInsight e seu trabalho:

- AppInsight: monitora desempenho "in the wild", rastreia transações e caminhos críticos, com foco em observação em campo.
- `collector_flutter`: roda dentro do app Flutter, foca feedback durante desenvolvimento, dashboard integrado e recomendações acionáveis.

Fala pronta:

> O AppInsight me inspira na ideia de aproximar a análise do uso real da aplicação. A diferença é que o meu trabalho traz isso para o contexto Flutter, com foco no desenvolvedor durante a implementação e não apenas na análise posterior de traces.

### Slide 9 - Trabalhos relacionados III: automação e recomendações - 1min30s

Objetivo do slide:

- Mostrar que medir não basta; é preciso interpretar.

Fala sugerida:

> O terceiro grupo trata de diagnóstico e ação. Sun e coautores revisam formas de diagnosticar ineficiências energéticas em apps Android. Bangash e coautores mostram que o uso de APIs pode ser analisado como indício de consumo energético. As ferramentas oficiais, como Android Profiler, Perfetto, Instruments e Firebase, mostram que existem dados ricos, mas nem sempre transformados em orientação simples para o desenvolvedor.

Frase-chave:

> Aqui aparece a peça que mais interessa ao meu trabalho: não basta medir. A ferramenta precisa ajudar o desenvolvedor a interpretar e priorizar o que fazer primeiro.

Se perguntarem "as recomendações são inteligentes?":

> Elas são heurísticas, não IA. Isso é uma escolha consciente: regras explícitas são auditáveis, previsíveis e fáceis de validar.

### Slide 10 - Lacuna de pesquisa - 30s

Objetivo do slide:

- Dizer exatamente onde está a contribuição.

Fala sugerida:

> A lacuna fica no encontro entre dados e ação. Existem métricas, ferramentas maduras e literatura sobre energia e desempenho. O que falta, especialmente no fluxo Flutter, é uma solução embarcada, de baixo atrito, que colete sinais técnicos e os traduza em recomendações práticas.

Lacuna em uma frase:

> A lacuna não é ausência de dados; é a distância entre medir e agir.

### Slide 11 - Humanidades - 2min

Objetivo do slide:

- Mostrar que o trabalho tem dimensão social, ambiental e ética.

Fala sugerida:

> A parte de humanidades do TCC tem três dimensões. A primeira é sustentabilidade digital: software ineficiente desperdiça CPU, memória, rede e bateria. A segunda é inclusão: um app mais leve tem mais chance de funcionar bem em aparelhos de entrada ou mais antigos. A terceira é ética: uma ferramenta de monitoramento deve coletar apenas o necessário.

Pontos importantes:

- Não diga que a ferramenta sozinha resolve sustentabilidade.
- Diga que ela apoia práticas de desenvolvimento mais conscientes.
- Privacidade: coleta métricas técnicas, não dados pessoais.
- Código aberto: permite auditoria.

Fala segura:

> O `collector_flutter` não é uma solução ambiental por si só. Ele é uma ferramenta técnica que torna visíveis custos computacionais que normalmente ficam escondidos.

### Slide 12 - Proposta - 2min

Objetivo do slide:

- Apresentar o `collector_flutter` como solução.

Fala sugerida:

> A proposta é o `collector_flutter`: um pacote Dart/Flutter que funciona de forma embarcada. Ele não substitui ferramentas profundas como DevTools, Android Profiler ou Perfetto. A ideia é outra: oferecer um termômetro contínuo dentro do app, para que o desenvolvedor perceba regressões e gargalos durante o desenvolvimento.

O que ele faz:

- coleta métricas;
- analisa padrões;
- gera recomendações;
- mostra dashboard;
- exporta dados;
- permite estudo e reprodução.

Frase curta:

> O diferencial é reduzir a distância entre notar o problema e saber qual ação tentar primeiro.

### Slide 13 - Ferramentas atuais: comparação - 1min

Objetivo do slide:

- Posicionar sua ferramenta sem desmerecer as existentes.

Fala sugerida:

> Esta tabela mostra que as ferramentas existentes são fortes, mas cada uma tem uma limitação para diagnóstico contínuo. DevTools é poderoso, mas externo. Perfetto é detalhado, mas baixo nível. Android Profiler e Instruments dependem do ecossistema da plataforma. Firebase é mais voltado a produção. O `collector_flutter` entra no espaço do feedback rápido, dentro do app, durante o desenvolvimento.

Como responder "por que não usar só X?":

> Porque o objetivo não é substituir X. É complementar. Ferramentas profundas continuam úteis para investigação detalhada; o `collector_flutter` entra antes, como alerta e orientação contínua.

### Slide 14 - Arquitetura geral - 1min

Objetivo do slide:

- Explicar a divisão em três camadas.

Fala sugerida:

> A arquitetura segue três camadas. A camada Data cuida das fontes de dados: frames, memória, rede, eventos, CPU e bateria. A camada Domain contém a lógica de análise e recomendação. A camada Presentation apresenta o dashboard e gerencia o estado. Essa separação foi importante para testabilidade e extensibilidade.

Mapa mental:

- Data: coleta.
- Domain: interpreta.
- Presentation: mostra.

Por que isso importa:

- Novas métricas podem entrar sem bagunçar o restante.
- Testes ficam mais simples.
- Regras de negócio ficam separadas da interface.

Se perguntarem sobre Clean Architecture:

> Usei o princípio de separar regras centrais dos detalhes externos. O dashboard e os data sources podem mudar, mas a lógica de análise e recomendação fica preservada.

### Slide 15 - Fluxo do sistema - 1min

Objetivo do slide:

- Mostrar o caminho da informação.

Fala sugerida:

> O fluxo é simples: o app em execução gera sinais. O coletor captura esses sinais. O analisador transforma dados brutos em indicadores e anomalias. O recomendador converte sintomas em sugestões. Por fim, o dashboard mostra tudo de forma visual.

Fala lúdica:

> Eu costumo pensar nisso como sinais vitais do aplicativo: o coletor escuta, o analisador interpreta e o recomendador devolve uma orientação.

Fluxo:

```text
Coleta -> análise -> recomendação -> dashboard -> ação do desenvolvedor
```

### Slide 16 - Métricas coletadas - 1min

Objetivo do slide:

- Explicar o que é monitorado.

Fala sugerida:

> As métricas principais são FPS, `jank`, percentis de tempo de frame, memória, rede, eventos customizados, rebuilds, CPU, bateria e exportação JSON/CSV. Os percentis são importantes porque a média pode esconder picos ruins. CPU e bateria ampliam a visão sobre custo de execução.

Detalhes técnicos para memorizar:

- Frames: `SchedulerBinding` e `FrameTiming`.
- Memória: RSS e heap.
- Rede: URL, método, status, latência e bytes.
- CPU: `platform channel` Android lendo `/proc/stat` em duas amostras.
- Bateria: `BatteryManager` no Android e `UIDevice` no iOS.
- Exportação: JSON da sessão e CSV de frames.

### Slide 17 - Módulos principais - 1min

Objetivo do slide:

- Nomear os componentes e suas responsabilidades.

Fala sugerida:

> Em termos de implementação, o `ResourceCollector` é a fachada pública. As fontes de dados coletam eventos. O `Analyzer` resume e detecta problemas. O `Recommender` gera sugestões. O `DashboardPage` apresenta as métricas. O `ExportService` permite exportar a sessão para análise externa.

Módulos que você deve saber:

- `FrameDataSource`: FPS e jank.
- `MemoryDataSource`: RSS e heap.
- `HttpClientWrapper`: rede.
- `EventDataSource`: eventos customizados.
- `CpuDataSource`: CPU via Android.
- `BatteryDataSource`: bateria.
- `Analyzer`: análise.
- `Recommender`: sugestões.
- `ExportService`: JSON/CSV.
- `CollectorBloc`: estado.
- `DashboardPage`: interface.
- `ResourceCollector`: entrada pública.

### Slide 18 - Integração no app - 1min

Objetivo do slide:

- Mostrar que a adoção é simples.

Fala sugerida:

> A integração foi pensada para ser curta. O desenvolvedor cria o coletor, inicia a coleta e abre o dashboard como uma tela comum do app. Para rede, pode usar o cliente instrumentado. Para eventos, registra pontos importantes do fluxo da aplicação.

Mensagem:

> A facilidade de adoção é parte da contribuição, porque uma ferramenta difícil de usar tende a ser ignorada.

### Slide 19 - Protótipo visual - 1min

Objetivo do slide:

- Mostrar que existe uma interface funcional.

Fala sugerida:

> Aqui estão duas telas do protótipo. A primeira representa um estado saudável, com indicadores estáveis. A segunda mostra uma condição com gargalos detectados. A proposta do dashboard é mostrar rapidamente onde está o sintoma: frame, memória, rede, CPU, bateria ou reconstrução.

Explique visualmente:

- Verde: situação saudável.
- Amarelo: atenção.
- Vermelho: crítico.
- Recomendações ajudam a transformar diagnóstico em ação.

### Slide 20 - Metodologia - 1min

Objetivo do slide:

- Mostrar rigor científico.

Fala sugerida:

> A metodologia combina pesquisa aplicada e abordagem experimental. Aplicada porque constrói uma ferramenta concreta. Experimental porque avalia a ferramenta com cenários controlados e métricas observáveis. O ciclo foi iterativo: revisão, requisitos, implementação e validação.

Fases:

1. Revisão bibliográfica.
2. Requisitos e escopo.
3. Projeto e implementação.
4. Avaliação experimental e validação.

Se perguntarem "por que não foi só um projeto de software?":

> Porque o trabalho tem problema de pesquisa, revisão crítica, hipóteses, requisitos, critérios de avaliação e validação experimental, ainda que parte da validação quantitativa ampla fique como evolução.

### Slide 21 - Requisitos do sistema - 1min

Objetivo do slide:

- Mostrar que o protótipo foi guiado por requisitos.

Fala sugerida:

> Os requisitos funcionais dizem o que a ferramenta deve fazer: coletar métricas, correlacionar degradações, gerar recomendações, exibir o dashboard e simular cargas. Os não funcionais dizem como ela deve se comportar: ter baixo overhead, manter interface fluida, ser modular e extensível.

Ponto delicado sobre código nativo:

O TCC inicialmente valoriza operar em Dart para reduzir dependências. A versão atual usa `platform channels` para CPU e bateria, porque essas métricas dependem de APIs do sistema operacional. A forma segura de explicar é:

> O núcleo da arquitetura e as métricas de Flutter/Dart permanecem em Dart. CPU e bateria foram adicionadas por canais nativos controlados, sem alterar as camadas superiores, justamente para preservar modularidade e extensibilidade.

### Slide 22 - Procedimentos de teste - 1min

Objetivo do slide:

- Mostrar como a validação foi pensada.

Fala sugerida:

> Os testes foram planejados para execução em modo profile, com ambiente preparado, coleta estruturada e comparação com ferramentas de referência. Um cuidado importante é não transformar uma observação pontual em resultado definitivo. Resultados quantitativos fortes exigem repetição, comparação e análise estatística.

Coisas que podem cair:

- Modo `profile` é mais próximo do comportamento real que `debug`.
- Foram definidos cenários controlados.
- Há exportação JSON/CSV para análise externa.
- Overhead e erro percentual são métricas de avaliação.
- A validação atual é qualitativa; a quantitativa formal é trabalho futuro.

### Slide 23 - Cenários experimentais - 45s

Objetivo do slide:

- Explicar as cargas usadas para testar sintomas.

Fala sugerida:

> Foram definidos quatro cenários: reconstruções intensivas, chamadas de rede simultâneas, alocação intensiva de memória e carga combinada. Cada cenário provoca um sintoma para verificar se o sistema percebe e comunica o problema.

Resumo:

- Rebuilds: testa renderização.
- Rede: testa interceptação HTTP.
- Memória: testa RSS, heap e tendência.
- Combinado: testa independência entre módulos.

### Slide 24 - Resultados implementados - 1min

Objetivo do slide:

- Mostrar entrega concreta.

Fala sugerida:

> Como resultado de implementação, o pacote reúne coleta de frames, memória, rede, eventos, reconstruções, CPU e bateria. A coleta de CPU usa um `platform channel` Android que lê `/proc/stat` em duas amostras e calcula percentual de uso. A bateria vem do `BatteryManager` no Android e do `UIDevice` no iOS. O dashboard exibe cartões para as métricas, há exportação em JSON e CSV, e 48 testes automatizados cobrem análise, recomendação, exportação e os novos data sources.

Dados importantes:

- 12 módulos principais implementados.
- 6 fontes de dados: frames, memória, rede, eventos, CPU, bateria.
- 48 testes automatizados.
- Exportação estruturada.
- Dashboard integrado.
- Código aberto.

### Slide 25 - Resultados qualitativos - 1min

Objetivo do slide:

- Apresentar evidência sem exagero.

Fala sugerida:

> Nos cenários qualitativos, o sistema detectou queda de FPS e frames longos durante rebuilds, registrou requisições de rede com URL, status e latência, acompanhou tendências de memória e priorizou recomendações quando havia carga combinada. Esses resultados confirmam a operacionalidade do protótipo.

Frase científica:

> Eu trato esses resultados como evidência qualitativa de funcionamento, não como prova estatística definitiva.

### Slide 26 - Evolução do protótipo - 45s

Objetivo do slide:

- Mostrar maturidade e reconhecer trabalhos futuros.

Fala sugerida:

> As limitações iniciais foram endereçadas: CPU via platform channel Android, bateria via BatteryManager e UIDevice, exportação JSON/CSV, 48 testes automatizados e publicação do pacote no pub.dev. O que fica como trabalho futuro são experimentos quantitativos formais, suporte completo de CPU no iOS e avaliação de usabilidade com desenvolvedores Flutter.

Trabalhos futuros:

- CPU completo no iOS por APIs adequadas.
- Mínimo de 30 repetições por cenário.
- Múltiplos dispositivos.
- Comparação estatística com ferramentas oficiais.
- Usabilidade com desenvolvedores.

### Slide 27 - Contribuições - 45s

Objetivo do slide:

- Organizar o valor do trabalho.

Fala sugerida:

> As contribuições aparecem em três níveis. No nível técnico, há uma biblioteca aberta, modular e embarcada. No nível científico, há arquitetura, requisitos, cenários e protocolo de avaliação. No nível social, o trabalho reforça que desempenho também conversa com sustentabilidade, inclusão e privacidade.

Contribuições detalhadas:

- revisão crítica da literatura;
- arquitetura modular;
- protótipo aberto;
- exportação JSON/CSV;
- testes automatizados;
- validação qualitativa;
- discussão socioambiental.

### Slide 28 - Conclusão - 45s

Objetivo do slide:

- Fechar a história com clareza.

Fala sugerida:

> A conclusão principal é que o diagnóstico de desempenho pode ficar mais próximo do fluxo real de desenvolvimento. O `collector_flutter` evoluiu para monitorar múltiplas métricas, com testes automatizados e exportação integrada. A arquitetura em camadas confirmou sua extensibilidade, porque CPU e bateria foram adicionadas sem alterar as camadas superiores. Desempenho não é só fazer o app correr mais rápido. É fazer o app respeitar melhor o dispositivo, a bateria e a pessoa que usa.

Mensagem final:

> Monitorar melhor é uma forma de projetar melhor.

### Slide 29 - Perguntas - 15s

Fala sugerida:

> Obrigada. Fico à disposição para perguntas.

Respire. Pegue água. Não responda rápido demais.

## Resumo dos módulos e dados técnicos

### `ResourceCollector`

É a fachada pública da biblioteca. Centraliza inicialização, parada e acesso às funcionalidades.

Como explicar:

> Ele é a porta de entrada. Em vez de o desenvolvedor lidar com vários módulos diretamente, ele usa o `ResourceCollector`.

### `FrameDataSource`

Coleta tempos de frame e permite estimar FPS e jank usando APIs do Flutter como `SchedulerBinding` e `FrameTiming`.

Por que importa:

- mede fluidez;
- identifica frames longos;
- fundamenta recomendações sobre renderização.

### `MemoryDataSource`

Observa uso de memória, incluindo RSS e heap. O TCC menciona suavização exponencial para evitar falsos positivos em picos transitórios.

Fórmula citada:

```text
memória_suavizada = 0,7 * valor_anterior + 0,3 * valor_novo
```

Por que importa:

- memória alta pode degradar app;
- tendências são mais importantes que picos isolados.

### `HttpClientWrapper`

Intercepta requisições HTTP e registra dados como URL, método, status e latência.

Por que importa:

- rede lenta afeta experiência;
- requisições em excesso indicam necessidade de cache, debounce ou paginação.

### `EventDataSource`

Permite registrar eventos customizados do desenvolvedor.

Exemplo:

```dart
collector.recordEvent('checkout_started', {'items': 3});
```

Por que importa:

- conecta métricas técnicas a momentos relevantes do app;
- ajuda a entender "quando" o problema aconteceu.

### `CpuDataSource`

Coleta CPU via `platform channel` Android, lendo `/proc/stat` em duas amostras espaçadas por 200 ms.

Fórmula citada na monografia:

```text
uso_cpu = (1 - delta_idle / delta_total) * 100
```

Limite:

- em iOS, a versão atual retorna valor sentinela e exibe "N/D" para CPU.

Resposta pronta:

> CPU exige acesso a informações do sistema operacional. Por isso, enquanto as métricas Flutter/Dart permanecem em Dart, CPU foi implementada via canal nativo controlado no Android.

### `BatteryDataSource`

Monitora nível de bateria e estado de carregamento.

- Android: `BatteryManager`.
- iOS: `UIDevice.batteryLevel`.
- Alerta de severidade média quando bateria está abaixo de 20% e o dispositivo não está carregando.

Cuidado na fala:

> Bateria aqui é estado do dispositivo e sinal contextual, não medição física precisa de consumo energético.

### `Analyzer`

Transforma métricas em análise.

Ele detecta:

- queda de FPS;
- frames longos;
- crescimento de memória;
- volume alto de rede;
- CPU elevada;
- bateria baixa;
- sintomas combinados.

### `Recommender`

Converte sintomas em recomendações.

Exemplos:

- muitos frames longos: usar `const`, `ValueNotifier`, `Selector`;
- rede intensa: cache e debounce;
- CPU alta: mover trabalho pesado para `Isolate`;
- bateria baixa: reduzir frequência de coleta ou tarefas em segundo plano.

### `DashboardPage`

Mostra métricas, gráficos e recomendações dentro do aplicativo.

Valor principal:

> O diagnóstico aparece onde o desenvolvedor já está testando o app.

### `ExportService`

Exporta:

- sessão completa em JSON;
- timings de frames em CSV.

Por que importa:

- reprodutibilidade;
- análise externa;
- comparação com ferramentas de referência.

## Trabalhos relacionados e como usar cada um

### 1. Pathak et al. (2011)

Tema: modelagem fina de energia em smartphones por chamadas de sistema.

Ponto principal:

- operações de software podem ser relacionadas a consumo energético.

Como usar na defesa:

> Pathak fundamenta a ideia de que eventos do sistema ajudam a entender custo energético.

### 2. Hao et al. (2013)

Tema: estimativa de energia por análise de programa.

Ponto principal:

- é possível estimar consumo a partir do comportamento do código.

Como usar:

> Hao ajuda a justificar o uso de análise e sinais de software, mesmo sem medidor físico.

### 3. Li et al. (2014)

Tema: estudo empírico sobre energia em apps Android.

Ponto principal:

- rede, APIs e padrões de execução afetam consumo.

Como usar:

> Li reforça que apps reais exibem padrões mensuráveis de consumo.

### 4. Ravindranath et al. (2012) - AppInsight

Tema: monitoramento de desempenho em campo.

Ponto principal:

- identificar gargalos em transações reais e assíncronas.

Como usar:

> O AppInsight inspira a aproximação entre monitoramento e execução real. A diferença é que meu trabalho foca Flutter, dashboard integrado e recomendações durante o desenvolvimento.

### 5. Hoque et al. (2015)

Tema: revisão sobre modelagem, profiling e depuração energética.

Ponto principal:

- organiza métodos e limites da área.

Como usar:

> Hoque ajuda a mostrar que energia em dispositivos móveis é um campo complexo, com métodos diferentes e limitações reais.

### 6. Rua e Saraiva (2024)

Tema: estudo em larga escala sobre energia, tempo de execução e memória.

Ponto principal:

- desempenho móvel precisa ser analisado de forma multidimensional.

Como usar:

> Rua e Saraiva justificam olhar para múltiplas métricas juntas, não só FPS.

### 7. Sun et al. (2023)

Tema: revisão sobre diagnóstico de ineficiências energéticas em Android.

Ponto principal:

- diagnóstico envolve causas, sintomas, métodos de detecção e correção.

Como usar:

> Sun ajuda a organizar a lógica de detectar sintomas e transformá-los em hipóteses de causa.

### 8. Bangash et al. (2023)

Tema: estimativa de energia a partir do uso de APIs.

Ponto principal:

- chamadas e padrões de APIs podem indicar custo energético.

Como usar:

> Bangash reforça que eventos e padrões de uso podem alimentar heurísticas.

### 9. Nawrocki et al. (2021)

Tema: comparação entre frameworks nativos e multiplataforma.

Ponto principal:

- escolhas de framework afetam desempenho e custo de execução.

Como usar:

> Nawrocki ajuda a situar Flutter no debate de desempenho cross-platform.

### 10. Flutter e Flutter DevTools

Tema: documentação oficial do ecossistema Flutter.

Ponto principal:

- define ferramentas, métricas e práticas oficiais.

Como usar:

> As métricas do protótipo foram alinhadas ao que o ecossistema Flutter já considera relevante.

### 11. Android Profiler, Perfetto, Instruments e Firebase

Tema: ferramentas oficiais e maduras de profiling e monitoramento.

Ponto principal:

- são fortes, mas externas ou voltadas a contextos específicos.

Como usar:

> Elas não são concorrentes diretas; são referências. O `collector_flutter` complementa essas ferramentas reduzindo o atrito do diagnóstico inicial.

### 12. UNITAR e ITU

Tema: lixo eletrônico e sustentabilidade.

Ponto principal:

- tecnologia tem impacto ambiental no ciclo de vida dos dispositivos.

Como usar:

> A parte de humanidades usa essa referência para conectar eficiência de software e vida útil percebida dos aparelhos.

### 13. Gil, Lakatos, Yin e Wohlin

Tema: metodologia científica, pesquisa aplicada, estudo de caso e experimentação.

Ponto principal:

- ajudam a justificar o desenho metodológico.

Como usar:

> Essas referências sustentam que o trabalho não é apenas implementação: ele tem problema, método, protocolo e critérios de avaliação.

### 14. Pressman, Sommerville e Martin

Tema: engenharia de software e arquitetura.

Ponto principal:

- requisitos, qualidade, modularidade, testabilidade e Clean Architecture.

Como usar:

> Essas obras justificam a organização em camadas, os requisitos e a preocupação com manutenção e extensão.

## Perguntas difíceis e respostas

### 1. Qual é a contribuição original do trabalho?

Resposta:

> A contribuição está na integração de coleta, análise heurística, dashboard embarcado, recomendações acionáveis e exportação em uma biblioteca Flutter aberta. Individualmente, existem ferramentas de profiling e estudos sobre métricas, mas o trabalho combina esses elementos em uma solução voltada ao fluxo diário do desenvolvedor Flutter.

### 2. O `collector_flutter` substitui o Flutter DevTools?

Resposta:

> Não. O DevTools continua sendo mais profundo para investigação detalhada. O `collector_flutter` atua antes e de forma complementar: ele reduz o atrito para perceber problemas durante o uso normal do app e sugere ações iniciais.

### 3. Por que não usar só Android Profiler?

Resposta:

> O Android Profiler é excelente, mas é externo, restrito ao ecossistema Android e exige interpretação manual. O `collector_flutter` busca feedback integrado ao app, com recomendações e foco no fluxo Flutter.

### 4. Qual a diferença entre o seu trabalho e o AppInsight?

Resposta:

> O AppInsight monitora desempenho de apps móveis em campo e identifica caminhos críticos de transações assíncronas. O meu trabalho é específico para Flutter, roda como biblioteca embarcada, mostra dashboard no app e gera recomendações durante o desenvolvimento. O AppInsight inspirou a ideia de observar execução real, mas a proposta e o público-alvo são diferentes.

### 5. O trabalho mede energia de verdade?

Resposta:

> Não mede corrente elétrica diretamente. Ele usa proxies de energia, como CPU, rede, memória, tempo de frame e padrões de uso. Isso é coerente com a literatura quando não há instrumentação física dedicada. A bateria aparece como métrica contextual, não como medição precisa de consumo.

### 6. Por que usar heurísticas em vez de machine learning?

Resposta:

> Porque as heurísticas são auditáveis, previsíveis e adequadas ao escopo do trabalho. Para uma ferramenta de desenvolvimento, é importante que o desenvolvedor entenda por que uma recomendação apareceu. Machine learning poderia ser uma evolução futura, mas exigiria base de dados maior e validação própria.

### 7. As recomendações são garantidas?

Resposta:

> Não são garantias absolutas. Elas são recomendações baseadas em sintomas. Por exemplo, muitos frames longos podem indicar reconstruções excessivas, trabalho pesado na UI thread ou layout complexo. A ferramenta orienta uma primeira investigação.

### 8. Como você evita falsos positivos?

Resposta:

> O sistema usa limiares, severidade e suavização em algumas métricas, como memória, para evitar reagir a picos isolados. Além disso, as recomendações são tratadas como sinais de atenção, não como diagnóstico definitivo.

### 9. Por que a validação é qualitativa?

Resposta:

> Porque o trabalho atual confirmou a operacionalidade do protótipo e a pertinência das heurísticas em cenários controlados. Uma validação quantitativa formal exige mais repetições, múltiplos dispositivos, comparação sistemática e análise estatística. Isso foi delimitado como trabalho futuro.

### 10. O que falta para uma validação quantitativa forte?

Resposta:

> Repetir cada cenário pelo menos 30 vezes, usar múltiplos dispositivos, comparar com Android Profiler e `adb shell dumpsys gfxinfo`, calcular erro percentual, overhead e intervalos de confiança.

### 11. O que significa overhead inferior a 5%?

Resposta:

> Significa que o coletor não deve aumentar o tempo médio de renderização em mais de 5%. Esse é um limite de requisito. O ideal é ficar abaixo disso, porque uma ferramenta de monitoramento não pode degradar muito o app que está observando.

### 12. Existe contradição entre "sem código nativo" e CPU/bateria por platform channel?

Resposta:

> A proposta inicial prioriza Dart para reduzir dependências. No entanto, CPU e bateria dependem de APIs do sistema operacional. Por isso, elas foram adicionadas por `platform channels` isolados, sem alterar as camadas superiores. O núcleo da arquitetura continua modular e as métricas Flutter/Dart continuam independentes de código nativo.

### 13. Por que CPU no iOS ainda não está completa?

Resposta:

> Porque iOS tem restrições de sandbox e exige integração específica com APIs como Mach. A arquitetura já prevê esse caminho, mas a implementação completa de CPU no iOS ficou como evolução.

### 14. Por que bateria baixa gera recomendação se isso não é culpa do app?

Resposta:

> Porque bateria baixa muda o contexto de execução. A recomendação não diz que o app causou a bateria baixa; ela sugere reduzir tarefas ou frequência de coleta quando o dispositivo está em condição sensível.

### 15. Por que coletar dados dentro do app pode ser melhor?

Resposta:

> Porque reduz troca de contexto. O desenvolvedor vê o sintoma no mesmo ambiente em que está testando a funcionalidade. Isso aumenta a chance de diagnóstico precoce.

### 16. Isso não aumenta o risco de overhead?

Resposta:

> Sim, por isso overhead é um requisito central. A arquitetura usa coleta periódica, dados resumidos e dashboard reativo para controlar o impacto. A validação quantitativa futura deve medir esse custo formalmente.

### 17. Por que usar Clean Architecture?

Resposta:

> Porque separa coleta, regra de análise e apresentação. Isso facilita testes, manutenção e extensão. A adição de CPU e bateria sem alterar as camadas superiores é evidência prática dessa escolha.

### 18. Por que usar Bloc?

Resposta:

> Porque o dashboard precisa reagir a streams de métricas ao longo do tempo. O Bloc ajuda a organizar estados e eventos de forma previsível.

### 19. Por que exportar JSON e CSV?

Resposta:

> JSON preserva a sessão completa com estrutura rica. CSV facilita análise tabular, especialmente de timings de frames. Isso apoia reprodutibilidade e comparação externa.

### 20. O sistema pode ser usado em produção?

Resposta:

> A proposta principal é desenvolvimento e validação. Uso em produção exigiria cuidados adicionais de privacidade, overhead, amostragem e consentimento. Como o foco é diagnóstico no desenvolvimento, a ferramenta evita servidores externos e dados pessoais.

### 21. O que é minimização de dados?

Resposta:

> É coletar apenas o necessário para o objetivo. O `collector_flutter` coleta métricas técnicas de desempenho, não identificação do usuário, conteúdo de mensagens ou dados pessoais.

### 22. Como o trabalho se relaciona com inclusão digital?

Resposta:

> Apps pesados prejudicam mais usuários com aparelhos de entrada. Ao facilitar a identificação de gargalos, a ferramenta ajuda desenvolvedores a produzir apps mais acessíveis a dispositivos de menor capacidade.

### 23. Como o trabalho se relaciona com sustentabilidade?

Resposta:

> Software ineficiente pode consumir mais recursos e contribuir para obsolescência percebida. A ferramenta não resolve o problema ambiental sozinha, mas apoia práticas que reduzem desperdício computacional.

### 24. Qual é o maior limite atual do trabalho?

Resposta:

> A principal limitação é a ausência de validação quantitativa ampla com análise estatística em múltiplos dispositivos. Também há espaço para suporte completo de CPU no iOS e avaliação de usabilidade com desenvolvedores.

### 25. Por que 48 testes não provam tudo?

Resposta:

> Testes unitários provam comportamento esperado de módulos isolados. Eles não substituem experimentos de desempenho em dispositivos reais. Por isso, eles são uma evidência de corretude interna, não a validação final de precisão e overhead.

### 26. Quais foram os quatro cenários experimentais?

Resposta:

> Rebuilds intensivos, chamadas de rede simultâneas, alocação intensiva de memória e carga combinada. Cada cenário provoca um tipo de sintoma para verificar se o sistema detecta e comunica o problema.

### 27. O que acontece no cenário de rebuilds?

Resposta:

> O app força reconstruções frequentes. O sistema detecta queda de FPS e aumento de frames longos, e recomenda usar `const`, isolar reconstruções e aplicar padrões reativos como `ValueNotifier` ou `Selector`.

### 28. O que acontece no cenário de rede?

Resposta:

> O app dispara várias requisições HTTP. O coletor registra URL, método, status e latência. Quando há alto volume, recomenda cache e debounce.

### 29. O que acontece no cenário de memória?

Resposta:

> O app aloca objetos grandes continuamente. O sistema acompanha crescimento de RSS e usa suavização para evitar alerta por pico transitório.

### 30. O que acontece no cenário combinado?

Resposta:

> Interface, rede e memória são pressionadas ao mesmo tempo. O objetivo é verificar se os módulos processam métricas independentes sem interferência e se as recomendações são priorizadas por severidade.

### 31. Por que severidade nas recomendações?

Resposta:

> Porque nem todo sintoma tem o mesmo impacto. A severidade ajuda o desenvolvedor a priorizar o que corrigir primeiro.

### 32. Por que o app usa dashboard em vez de só log?

Resposta:

> Logs são úteis, mas exigem leitura técnica. O dashboard reduz custo cognitivo, mostra tendências e organiza recomendações visualmente.

### 33. Como você garante reprodutibilidade?

Resposta:

> Com código aberto, documentação, cenários controlados, exportação JSON/CSV, testes automatizados e descrição do protocolo experimental.

### 34. O que você faria se tivesse mais tempo?

Resposta:

> Executaria a validação quantitativa formal em múltiplos dispositivos, completaria CPU no iOS, faria avaliação de usabilidade com desenvolvedores Flutter e ampliaria a documentação e a adoção do pacote já publicado.

### 35. Qual é a resposta mais curta para "por que esse trabalho importa?"

Resposta:

> Porque ele transforma desempenho em algo observável e acionável no momento em que o desenvolvedor ainda consegue corrigir o problema com baixo custo.

## Respostas-relâmpago

- O que é `jank`? Engasgo perceptível causado por frames que demoram demais.
- O que é FPS? Frames por segundo, indicador de fluidez.
- O que é P95? Valor abaixo do qual 95% das amostras ficam; ajuda a ver picos ruins.
- O que é overhead? Custo introduzido pela própria ferramenta.
- Qual o limite de overhead? Requisito de até 5%.
- O que foi implementado? Coleta, análise, recomendações, dashboard, exportação, CPU, bateria e testes.
- Quantos testes? 48 testes automatizados.
- Quais métricas? FPS, jank, percentis, memória, rede, eventos, rebuilds, CPU e bateria.
- Qual arquitetura? Data, Domain e Presentation.
- Principal lacuna? Dados existem, mas falta feedback embarcado e acionável no fluxo Flutter.
- Principal contribuição? Biblioteca aberta que integra coleta, análise, dashboard e recomendações.
- Principal limitação? Validação quantitativa ampla ainda é trabalho futuro.

## Como estudar este roteiro

1. Leia a "tese em uma frase" até conseguir falar sem olhar.
2. Treine os slides 1 a 6 como história, não como lista.
3. Para os slides 7 a 9, decore o papel de cada grupo de referências, não todos os detalhes.
4. Para os slides 14 a 18, desenhe o fluxo em uma folha: Data -> Domain -> Presentation.
5. Para os slides 24 a 26, memorize os números: 6 fontes de dados, 12 módulos principais, 48 testes, 4 cenários.
6. Treine as perguntas difíceis em voz alta.
7. Se travar na defesa, volte para esta frase: "o objetivo é reduzir o atrito entre perceber um problema de desempenho e saber qual ação tentar primeiro".

## Versão de 2 minutos da apresentação

> O trabalho parte do problema de que aplicativos Flutter modernos são cada vez mais complexos, mas o diagnóstico de desempenho ainda depende muito de ferramentas externas, configuração manual e interpretação especializada. Isso faz com que equipes deixem performance para o fim do projeto, quando o problema já pode ter afetado o usuário.

> A proposta é o `collector_flutter`, uma biblioteca Dart/Flutter embarcada que coleta métricas como FPS, jank, memória, rede, eventos, rebuilds, CPU e bateria. Essas métricas são analisadas por heurísticas e apresentadas em um dashboard integrado, junto com recomendações por severidade.

> A solução foi projetada com arquitetura em três camadas: Data para coleta, Domain para análise e recomendação, e Presentation para dashboard. Essa separação permitiu adicionar CPU e bateria sem alterar as camadas superiores, reforçando a extensibilidade.

> A validação qualitativa usou quatro cenários controlados: rebuilds intensivos, rede simultânea, memória intensiva e carga combinada. O sistema detectou sintomas esperados, registrou dados úteis e priorizou recomendações. Além disso, o protótipo possui exportação JSON/CSV e 48 testes automatizados.

> A principal conclusão é que diagnóstico de desempenho pode ser mais acessível, contínuo e acionável em Flutter. O trabalho não substitui ferramentas como DevTools ou Android Profiler, mas complementa essas ferramentas ao trazer um termômetro de desempenho para dentro do próprio aplicativo.

## Versão de 30 segundos da contribuição

> A contribuição do trabalho é uma biblioteca Flutter aberta que integra coleta de métricas, análise heurística, recomendações e dashboard embarcado. Ela reduz o atrito do diagnóstico de desempenho e ajuda o desenvolvedor a identificar cedo problemas de FPS, memória, rede, CPU, bateria e reconstruções.
