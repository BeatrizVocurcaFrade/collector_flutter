# Roteiro de apresentação - 30 minutos

Este roteiro foi escrito para soar como fala, não como leitura da monografia. A ideia é usar os slides como apoio visual e manter uma linha narrativa simples: problema, base científica, solução, método, resultados e fechamento.

## Ritmo geral

- Tempo total: cerca de 30 minutos.
- Se a banca parecer apressada, reduza exemplos e mantenha os pontos centrais.
- Se sobrar tempo, aprofunde os trabalhos relacionados e a parte de resultados qualitativos.
- Evite ler tabelas linha por linha. Escolha duas ou três mensagens por slide.

## Bloco 1 - Abertura, contexto e objetivos - 6 min

### Slide 1 - Capa - 30s

Fala sugerida:

> Boa tarde. Eu sou a Beatriz Vocurca Frade e vou apresentar meu trabalho sobre monitoramento e otimização de recursos em aplicativos Flutter. O foco do trabalho é o `collector_flutter`, uma ferramenta embarcada que busca aproximar o diagnóstico de desempenho do dia a dia do desenvolvimento.

Transição:

> Para organizar a apresentação, começo pelo problema e depois caminho até a solução, metodologia e resultados.

### Slide 2 - Visão geral da defesa - 45s

Fala sugerida:

> A apresentação está dividida em seis partes. Primeiro eu contextualizo o problema e os objetivos. Depois passo pelos trabalhos relacionados e pela lacuna que encontrei. Em seguida, trago a parte de humanidades, porque desempenho também tem impacto social e ambiental. Depois entro na solução, na metodologia, nos resultados e nas conclusões.

Ênfase:

- Mostrar que a defesa segue a estrutura do TCC.
- Não gastar muito tempo aqui.

### Slide 3 - Introdução - 1min

Fala sugerida:

> O ponto de partida do trabalho é o crescimento do Flutter e a complexidade cada vez maior das aplicações móveis. Hoje, um aplicativo não é só uma tela simples: ele tem animações, chamadas de rede, listas dinâmicas, estados reativos e precisa rodar bem em aparelhos muito diferentes. Nesse cenário, desempenho deixa de ser um detalhe técnico e passa a ser parte da experiência do usuário.

Transição:

> O problema é que diagnosticar desempenho ainda costuma ser mais difícil do que deveria.

### Slide 4 - Problema de pesquisa - 1min

Fala sugerida:

> As ferramentas atuais são muito boas tecnicamente. Flutter DevTools, Android Profiler e Perfetto entregam dados ricos. A dificuldade está no uso contínuo: elas ficam fora do aplicativo, exigem configuração, conexão, troca de tela e interpretação manual. Na prática, isso cria atrito. O desenvolvedor percebe que existe uma ferramenta, mas nem sempre usa durante o ciclo normal de implementação.

Frase-chave:

> A pergunta que guia o trabalho é: como tornar esse diagnóstico mais acessível, contínuo e acionável em Flutter?

### Slide 5 - Motivação - 1min15s

Fala sugerida:

> A motivação tem três camadas. A primeira é a experiência: `jank`, queda de FPS e uso alto de memória tornam o aplicativo menos confiável. A segunda é energia: se o app faz mais trabalho do que precisa, ele consome mais bateria e pode aquecer mais o dispositivo. A terceira é inclusão: um app pesado pode funcionar bem em um celular topo de linha, mas ser quase inutilizável em um aparelho de entrada.

Ênfase:

- Performance aqui vira desempenho, energia e acesso.
- Essa ponte prepara o capítulo de humanidades.

### Slide 6 - Objetivos - 1min30s

Fala sugerida:

> O objetivo geral foi desenvolver e avaliar o `collector_flutter`, uma biblioteca Dart e Flutter para monitorar desempenho em tempo real dentro do próprio aplicativo. A ferramenta coleta métricas como FPS, `jank`, memória, rede, eventos customizados e reconstruções de widgets. Depois, processa essas métricas e gera recomendações heurísticas organizadas por severidade.

> Os objetivos específicos cobrem a revisão bibliográfica, a comparação com ferramentas existentes, a arquitetura em camadas, a implementação dos módulos e a validação por cenários controlados.

Transição:

> Para sustentar essas escolhas, a revisão bibliográfica foi organizada em três grupos de trabalhos.

## Bloco 2 - Trabalhos relacionados e lacuna - 6 min

### Slide 7 - Trabalhos relacionados I: energia e métricas - 2min

Fala sugerida:

> O primeiro grupo trata de energia e métricas observáveis. Pathak e coautores mostram que chamadas de rede e renderização de interface respondem por uma parte importante do consumo energético em smartphones. Hao e também Li e Halfond reforçam uma ideia importante para este trabalho: mesmo sem instrumentação física dedicada, é possível estimar consumo energético a partir de sinais do próprio software.

> Isso é importante porque o `collector_flutter` não nasce como um medidor elétrico. Ele trabalha com proxies: tempo de frame, memória, rede e eventos de execução.

Ênfase:

- Não tentar explicar todos os artigos.
- O ponto é: métricas de software dizem algo sobre energia.

### Slide 8 - Trabalhos relacionados II: profiling e Flutter - 2min

Fala sugerida:

> O segundo grupo aproxima a discussão do desenvolvimento móvel e do Flutter. Liu e coautores relacionam eventos de sistema e renderização com métricas percebidas pelo usuário, como FPS e responsividade. He e Meyer e Krause discutem diferenças de desempenho entre frameworks multiplataforma. Zhang e coautores entram diretamente no ecossistema Flutter e apontam o impacto dos `rebuilds` frequentes.

> Essa parte da literatura ajudou a definir quais sinais deveriam aparecer no protótipo: não só memória ou rede isoladas, mas também frames, percentis, `jank` e reconstruções.

### Slide 9 - Trabalhos relacionados III: automação e recomendações - 1min30s

Fala sugerida:

> O terceiro grupo olha para automação e adoção. Banerjee discute monitoramento em tempo de execução. Johnson destaca a importância de recomendações automáticas. Kumar e Gupta organizam estratégias de otimização em renderização, memória, rede e energia. Rodrigues mostra que soluções embutidas tendem a ser mais adotadas do que ferramentas externas. Santos e Silva reforçam a ligação entre reconstruções, CPU e consumo.

Frase-chave:

> Aqui aparece a peça que mais interessa ao meu trabalho: não basta medir. A ferramenta precisa ajudar o desenvolvedor a interpretar.

### Slide 10 - Lacuna de pesquisa - 30s

Fala sugerida:

> A lacuna fica nesse encontro entre disponibilidade de dados e capacidade de agir. Existem métricas, existem ferramentas maduras e existe literatura sobre energia e desempenho. O que falta é uma solução que rode dentro do app, tenha baixo atrito de uso e traduza sinais técnicos em recomendações práticas.

Transição:

> Antes de entrar na solução, eu queria situar por que isso importa além da parte técnica.

## Bloco 3 - Humanidades e proposta - 4 min

### Slide 11 - Contextualização em humanidades - 2min

Fala sugerida:

> A parte de humanidades do TCC trata de três dimensões. A primeira é sustentabilidade digital: se um aplicativo desperdiça CPU, rede e memória em escala, esse desperdício também vira consumo energético. A segunda é inclusão: um app mais leve tem mais chance de funcionar bem em aparelhos de entrada ou mais antigos. A terceira é ética: uma ferramenta de monitoramento precisa coletar o mínimo necessário.

> Por isso, o `collector_flutter` foi pensado para trabalhar com métricas técnicas de desempenho, sem coletar dados pessoais, conteúdo de comunicação ou identificação do usuário.

Ênfase:

- Soar humano, não moralista.
- Mostrar que humanidades conversa com a decisão técnica.

### Slide 12 - Proposta - 2min

Fala sugerida:

> A proposta é o `collector_flutter`: um pacote Dart e Flutter que funciona de forma embarcada. Ele não substitui ferramentas avançadas como DevTools ou Android Profiler. A ideia é outra: oferecer um termômetro contínuo dentro do app, para que o desenvolvedor perceba regressões e gargalos durante o desenvolvimento.

> Ele coleta métricas, analisa padrões e mostra recomendações no dashboard integrado. A vantagem é reduzir a distância entre notar o problema e saber qual ação tentar primeiro.

Transição:

> Para deixar claro esse espaço da proposta, o próximo slide compara com ferramentas já existentes.

## Bloco 4 - Solução e arquitetura - 6 min

### Slide 13 - Ferramentas atuais: comparação - 1min

Fala sugerida:

> Esta tabela resume o cenário. As ferramentas existentes são fortes, mas cada uma tem uma limitação para o caso de diagnóstico contínuo. DevTools é poderoso, mas externo. Perfetto é detalhado, mas baixo nível. Android Profiler e Instruments dependem do ecossistema da plataforma. Firebase Performance é voltado a produção. O `collector_flutter` entra no espaço do feedback rápido, dentro do app, durante o desenvolvimento.

### Slide 14 - Arquitetura geral - 1min

Fala sugerida:

> A arquitetura segue três camadas. A camada Data cuida das fontes de dados: frames, memória, rede e eventos. A camada Domain contém a lógica de análise e recomendação. A camada Presentation apresenta o dashboard e gerencia o estado. Essa separação foi importante para manter a ferramenta testável e extensível.

### Slide 15 - Fluxo do sistema - 1min

Fala sugerida:

> O fluxo é simples: primeiro o app em execução gera sinais. O coletor captura esses sinais. O analisador transforma os dados em indicadores e anomalias. O recomendador converte esses sintomas em sugestões. Por fim, o dashboard mostra tudo de forma visual.

Frase natural:

> Eu costumo pensar nisso como sinais vitais do aplicativo: o coletor escuta, interpreta e devolve uma orientação.

### Slide 16 - Métricas coletadas - 1min

Fala sugerida:

> As métricas principais são FPS, `jank`, percentis de tempo de frame, memória, rede, eventos customizados e `rebuilds`. Os percentis são importantes porque a média pode esconder picos ruins. Um app pode ter média aceitável, mas ainda apresentar frames muito lentos que o usuário percebe.

### Slide 17 - Módulos principais - 1min

Fala sugerida:

> Em termos de implementação, o `ResourceCollector` é a fachada pública. As fontes de dados coletam os eventos. O `Analyzer` resume e detecta problemas. O `Recommender` gera sugestões. O `DashboardPage` apresenta as métricas e o `ExportService` permite exportar a sessão para análise externa.

### Slide 18 - Integração no app - 1min

Fala sugerida:

> A integração foi pensada para ser curta. O desenvolvedor cria o coletor, inicia a coleta e abre o dashboard como uma tela comum do aplicativo. Para rede, pode usar o cliente instrumentado. Para eventos, registra pontos importantes do fluxo da aplicação.

Ênfase:

- Não explicar cada linha do código.
- A mensagem é facilidade de adoção.

## Bloco 5 - Protótipo e metodologia - 4 min

### Slide 19 - Protótipo visual - 1min

Fala sugerida:

> Aqui estão duas telas do protótipo. A primeira representa um estado saudável, com indicadores estáveis. A segunda mostra uma condição com gargalos detectados. A proposta do dashboard é mostrar rapidamente onde está o sintoma: frame, memória, rede ou reconstrução.

### Slide 20 - Metodologia - 1min

Fala sugerida:

> A metodologia combina pesquisa aplicada e abordagem experimental. Aplicada porque o trabalho constrói uma ferramenta concreta. Experimental porque avalia a ferramenta por meio de cenários controlados e métricas observáveis. O ciclo foi iterativo: revisão, requisitos, implementação e validação.

### Slide 21 - Requisitos do sistema - 1min

Fala sugerida:

> Os requisitos funcionais dizem o que a ferramenta deve fazer: coletar métricas, correlacionar degradações, gerar recomendações, exibir o dashboard e simular cargas. Os não funcionais dizem como ela deve se comportar: operar em Dart, ter baixo overhead, manter interface fluida e ser modular.

### Slide 22 - Procedimentos de teste - 1min

Fala sugerida:

> Os testes foram planejados para execução em modo profile, com preparação do ambiente, coleta estruturada e comparação com ferramentas de referência. Um cuidado importante é não transformar observação pontual em resultado definitivo. Por isso, resultados quantitativos exigem repetição, comparação e análise estatística.

## Bloco 6 - Cenários, resultados e fechamento - 4 min

### Slide 23 - Cenários experimentais - 45s

Fala sugerida:

> Foram definidos quatro cenários: reconstruções intensivas, chamadas de rede simultâneas, alocação intensiva de memória e carga combinada. Cada cenário provoca um tipo de sintoma para verificar se o sistema percebe e comunica o problema.

### Slide 24 - Resultados implementados - 1min

Fala sugerida:

> Como resultado de implementação, o pacote já reúne coleta de frames, memória, rede, eventos e reconstruções. O dashboard está funcional e há exportação em JSON e CSV. Também existem testes automatizados para o analisador, o recomendador e o serviço de exportação. Além disso, durante o desenvolvimento foram corrigidos problemas de gráfico, sincronização de memória, exibição de URLs e histórico de métricas.

### Slide 25 - Resultados qualitativos - 1min

Fala sugerida:

> Nos cenários qualitativos, o sistema detectou queda de FPS e frames longos durante rebuilds, registrou requisições de rede com dados úteis, acompanhou tendências de memória e priorizou recomendações quando havia carga combinada. Esses resultados mostram que o protótipo é operacional, embora a validação quantitativa ampla ainda dependa de mais execuções e dispositivos.

### Slide 26 - Limitações e evolução - 45s

Fala sugerida:

> As limitações principais são métricas de CPU e energia direta. Para isso, seria necessário usar integrações nativas por plataforma. Também há espaço para ampliar testes, comparar estatisticamente com ferramentas oficiais e avaliar usabilidade com desenvolvedores Flutter.

### Slide 27 - Contribuições - 45s

Fala sugerida:

> As contribuições podem ser vistas em três níveis. No nível técnico, há uma biblioteca aberta e modular. No nível científico, há arquitetura, requisitos, cenários e protocolo de avaliação. No nível social, o trabalho reforça que desempenho também se conecta a sustentabilidade, inclusão e privacidade.

### Slide 28 - Conclusão - 45s

Fala sugerida:

> A conclusão principal é que o diagnóstico de desempenho pode ficar mais próximo do fluxo real de desenvolvimento. O `collector_flutter` não tenta substituir ferramentas profundas, mas reduz o atrito para perceber problemas cedo e agir sobre eles. Em outras palavras, desempenho não é só fazer o app correr mais rápido. É fazer o app respeitar melhor o dispositivo, a bateria e a pessoa que usa.

### Slide 29 - Perguntas - 15s

Fala sugerida:

> Obrigada. Fico à disposição para perguntas.

## Dicas para a fala

- Quando falar de trabalhos relacionados, use “o que esse trabalho me ensinou” em vez de listar artigo por artigo.
- Quando falar de humanidades, conecte com exemplos concretos: celular de entrada, bateria, aquecimento e acesso.
- Quando falar de limitações, seja tranquila: reconhecer limite técnico passa segurança.
- Se perguntarem sobre overhead, responda como critério de projeto e validação planejada, evitando prometer um número que não foi medido com protocolo estatístico completo.
- Se perguntarem por que não usar só DevTools, responda: DevTools continua importante; a proposta é diminuir atrito e dar feedback contínuo dentro do app.
