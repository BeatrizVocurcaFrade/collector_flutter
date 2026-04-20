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

> O primeiro grupo trata de energia e métricas observáveis. Pathak e coautores mostram que é possível relacionar chamadas de sistema e componentes do smartphone ao consumo de energia. Hao e coautores reforçam essa ideia ao estimar consumo energético por análise de programa. Já Li, Hao, Gui e Halfond fazem um estudo empírico em aplicações Android e mostram que o comportamento do software influencia diretamente o gasto energético.

> Isso é importante porque o `collector_flutter` não nasce como um medidor elétrico. Ele trabalha com proxies: tempo de frame, memória, rede, eventos de execução e reconstruções. A literatura ajuda a defender que esses sinais são úteis para observar sintomas de ineficiência.

Ênfase:

- Não tentar explicar todos os artigos.
- O ponto é: métricas de software dizem algo sobre energia.

### Slide 8 - Trabalhos relacionados II: profiling e Flutter - 2min

Fala sugerida:

> O segundo grupo aproxima a discussão do monitoramento móvel. Ravindranath e coautores, com o AppInsight, mostram a importância de observar desempenho em aplicações reais, durante a execução. Hoque e coautores organizam o campo de modelagem, profiling e depuração de energia em dispositivos móveis. Rua e Saraiva trazem uma visão empírica em larga escala sobre energia, tempo de execução e memória.

> Para o Flutter, a ponte vem também da documentação oficial e do DevTools, que mostram quais métricas são relevantes no ecossistema: frames, `jank`, uso de memória, eventos de rede e inspeção de reconstruções. Essa parte da literatura ajudou a definir que o protótipo não deveria olhar só para uma métrica isolada, mas para um conjunto de sinais.

### Slide 9 - Trabalhos relacionados III: automação e recomendações - 1min30s

Fala sugerida:

> O terceiro grupo trata de diagnóstico e ação. Sun e coautores revisam formas de diagnosticar ineficiências energéticas em apps Android. Bangash e coautores mostram que o uso de APIs pode ser analisado como indício de consumo energético. Nawrocki e coautores ajudam a situar o debate de frameworks nativos e multiplataforma, que é importante porque o Flutter busca produtividade sem ignorar desempenho.

Frase-chave:

> Aqui aparece a peça que mais interessa ao meu trabalho: não basta medir. A ferramenta precisa ajudar o desenvolvedor a interpretar e priorizar o que fazer primeiro.

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

## Resumo rápido das referências

Esta parte não é para ser lida inteira na apresentação. Ela serve como cola de estudo para responder perguntas da banca e lembrar por que cada fonte entrou no TCC.

1. Pathak et al. (2011) - Fine-grained Power Modeling for Smartphones Using System Call Tracing

Resumo: propõe uma modelagem fina de consumo energético em smartphones a partir do rastreamento de chamadas de sistema. O ponto mais importante é mostrar que ações de software, como rede, I/O e atividade de interface, podem ser relacionadas a consumo de energia.

Por que foi importante: ajudou a sustentar a ideia de usar sinais observáveis do software como aproximação para problemas de energia, mesmo quando o protótipo não mede corrente elétrica diretamente.

2. Hao et al. (2013) - Estimating Mobile Application Energy Consumption Using Program Analysis

Resumo: apresenta uma abordagem para estimar consumo energético de aplicações móveis usando análise de programa. O trabalho reforça que é possível estudar energia a partir da estrutura e do comportamento do código.

Por que foi importante: deu base para tratar métricas de execução como indícios defensáveis de consumo, principalmente quando combinadas com rede, memória e tempo de processamento.

3. Li, Hao, Gui e Halfond (2014) - An Empirical Study of the Energy Consumption of Android Applications

Resumo: investiga empiricamente o consumo de energia em aplicações Android e relaciona esse consumo a comportamentos de software. Mostra que diferentes padrões de uso de recursos afetam o gasto energético.

Por que foi importante: reforçou a escolha de observar rede, memória e execução como dimensões relevantes para o `collector_flutter`.

4. Ravindranath et al. (2012) - AppInsight: Mobile App Performance Monitoring in the Wild

Resumo: apresenta o AppInsight, uma solução de monitoramento de desempenho em aplicações móveis em uso real. O foco está em capturar gargalos fora de um laboratório totalmente controlado.

Por que foi importante: inspirou a ideia de aproximar o diagnóstico do contexto real de execução, em vez de depender apenas de ferramentas externas usadas ocasionalmente.

5. Hoque et al. (2015) - Modeling, Profiling, and Debugging the Energy Consumption of Mobile Devices

Resumo: é uma revisão ampla sobre modelagem, profiling e depuração do consumo energético em dispositivos móveis. Organiza técnicas, desafios e limitações da área.

Por que foi importante: ajudou a fundamentar a discussão sobre energia no TCC e também a reconhecer limites, como a dificuldade de medir CPU e bateria com precisão sem integração nativa.

6. Rua e Saraiva (2024) - A Large-scale Empirical Study on Mobile Performance: Energy, Run-time and Memory

Resumo: analisa desempenho móvel em larga escala considerando energia, tempo de execução e memória. O trabalho mostra que essas dimensões precisam ser observadas em conjunto.

Por que foi importante: fortaleceu a decisão de o protótipo não olhar apenas para FPS, mas combinar frames, memória, rede e outros sinais.

7. Sun et al. (2023) - Energy Inefficiency Diagnosis for Android Applications: A Literature Review

Resumo: revisa estudos sobre diagnóstico de ineficiência energética em aplicações Android. Mapeia causas, métodos de detecção e estratégias usadas na literatura.

Por que foi importante: ajudou a organizar a noção de diagnóstico: detectar sintomas, interpretar causas prováveis e apontar caminhos de otimização.

8. Bangash et al. (2023) - Energy Consumption Estimation of API-usage in Mobile Apps via Static Analysis

Resumo: investiga como o uso de APIs em apps móveis pode ser analisado para estimar consumo de energia. O trabalho mostra que certas chamadas e padrões de uso podem sinalizar maior custo energético.

Por que foi importante: reforçou a ideia de que eventos e APIs usados pelo aplicativo podem alimentar heurísticas de recomendação.

9. Nawrocki et al. (2021) - A Comparison of Native and Cross-Platform Frameworks for Mobile Applications

Resumo: compara frameworks nativos e multiplataforma para aplicações móveis. Discute desempenho, desenvolvimento e implicações práticas dessa escolha.

Por que foi importante: situou o Flutter no debate de frameworks multiplataforma e ajudou a justificar por que monitoramento de desempenho é relevante nesse ecossistema.

10. Flutter (2026) - Flutter: Build Apps for Any Screen

Resumo: documentação oficial que apresenta o Flutter como framework para desenvolvimento multiplataforma.

Por que foi importante: serviu como fonte institucional para contextualizar o ecossistema em que o `collector_flutter` foi desenvolvido.

11. Flutter DevTools (2026) - Flutter and Dart DevTools

Resumo: documentação oficial das ferramentas de diagnóstico do Flutter e Dart, incluindo inspeção de desempenho, memória e outros recursos.

Por que foi importante: foi a principal referência para comparar a proposta com uma ferramenta oficial do ecossistema Flutter.

12. Android Developers (2024) - Profile Your App Performance

Resumo: documentação oficial do Android Profiler, ferramenta usada para observar CPU, memória, rede e energia em apps Android.

Por que foi importante: funcionou como referência de ferramenta madura de profiling, mostrando o que já existe e onde ainda há atrito para uso contínuo dentro do app.

13. Perfetto (2024) - Perfetto Tracing Documentation

Resumo: documentação oficial do Perfetto, plataforma de tracing detalhado para análise de desempenho.

Por que foi importante: ajudou a caracterizar ferramentas de baixo nível, muito completas, mas que exigem interpretação técnica mais especializada.

14. Apple (2024) - Profiling Apps Using Instruments

Resumo: documentação oficial do Instruments, ferramenta da Apple para profiling em apps iOS e macOS.

Por que foi importante: entrou na comparação para mostrar que o problema de diagnóstico não é só Android ou Flutter; cada plataforma tem ferramentas fortes, mas externas ao fluxo comum do app.

15. Firebase (2026) - Firebase Performance Monitoring

Resumo: documentação oficial do Firebase Performance Monitoring, voltado a acompanhar desempenho em aplicações, especialmente em produção.

Por que foi importante: ajudou a diferenciar o foco do `collector_flutter`: o protótipo busca feedback rápido durante desenvolvimento, não apenas monitoramento remoto em produção.

16. UNITAR e ITU (2024) - Global E-waste Monitor 2024

Resumo: relatório global sobre lixo eletrônico, ciclo de vida de dispositivos e impacto ambiental da tecnologia.

Por que foi importante: fundamentou a parte de humanidades, principalmente a relação entre software eficiente, vida útil percebida dos aparelhos e sustentabilidade digital.

17. Gil (2019) - Métodos e Técnicas de Pesquisa Social

Resumo: livro de metodologia que orienta classificação, planejamento e condução de pesquisas.

Por que foi importante: apoiou a caracterização do TCC como pesquisa aplicada, com objetivo prático e construção de uma solução.

18. Lakatos e Marconi (2021) - Fundamentos de Metodologia Científica

Resumo: obra clássica sobre método científico, estrutura de pesquisa e fundamentação acadêmica.

Por que foi importante: ajudou a sustentar a organização metodológica do trabalho, especialmente a relação entre problema, objetivos, procedimentos e análise.

19. Yin (2015) - Estudo de Caso: Planejamento e Métodos

Resumo: referência sobre planejamento de estudo de caso, coleta de evidências e organização de protocolos.

Por que foi importante: contribuiu para pensar a validação do protótipo de forma estruturada, com cenários, evidências e limites explícitos.

20. Wohlin et al. (2012) - Experimentation in Software Engineering

Resumo: obra central sobre experimentação em engenharia de software, incluindo planejamento, execução e interpretação de estudos experimentais.

Por que foi importante: sustentou os cenários controlados de teste e a cautela ao tratar resultados quantitativos como evidência científica.

21. Pressman e Maxim (2020) - Software Engineering: A Practitioner's Approach

Resumo: referência geral de engenharia de software, cobrindo processo, requisitos, projeto, qualidade e testes.

Por que foi importante: apoiou a organização do desenvolvimento do protótipo, dos requisitos e das atividades de validação.

22. Sommerville (2019) - Engenharia de Software

Resumo: obra de engenharia de software com foco em requisitos, arquitetura, projeto e manutenção de sistemas.

Por que foi importante: reforçou decisões de arquitetura modular e separação de responsabilidades no pacote.

23. Martin (2018) - Clean Architecture

Resumo: apresenta princípios de arquitetura limpa, separação de camadas e independência entre regras de negócio e detalhes externos.

Por que foi importante: ajudou a justificar a separação entre Data, Domain e Presentation no `collector_flutter`, deixando o protótipo mais testável e extensível.
