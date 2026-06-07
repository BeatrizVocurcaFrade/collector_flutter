# Roteiro de apresentação e guia de estudo - 20 minutos

Este roteiro acompanha o arquivo `slides/main.tex`. Ele não é um texto para decorar palavra por palavra. A ideia é ensaiar a narrativa, saber o que precisa ficar claro em cada slide e ter respostas preparadas para perguntas prováveis da banca.

## Tese em uma frase

O `collector_flutter` aproxima o primeiro diagnóstico de desempenho do fluxo real de desenvolvimento Flutter ao coletar métricas dentro do próprio aplicativo, interpretar sintomas de degradação e exibir recomendações em um dashboard integrado.

Versão curta para falar:

> O meu trabalho propõe um termômetro embarcado para aplicativos Flutter: ele observa sinais vitais do app, interpreta esses sinais e ajuda o desenvolvedor a saber onde investigar primeiro.

## Linha narrativa

1. Flutter facilita criar apps multiplataforma, mas apps modernos ficaram mais complexos.
2. Desempenho ruim afeta experiência, bateria, inclusão digital e sustentabilidade.
3. Ferramentas como DevTools, Android Profiler e Perfetto são fortes, mas externas ao fluxo do app.
4. A lacuna não é falta de dado; é transformar dado em ação durante o desenvolvimento.
5. O `collector_flutter` atua nessa lacuna com coleta embarcada, dashboard e recomendações.
6. A avaliação foi funcional e qualitativa, com quatro cenários controlados, imagens reais, leituras ADB e 60 testes automatizados.
7. A principal conclusão é que diagnóstico de desempenho pode ser mais contínuo, acessível e acionável, sem substituir ferramentas especializadas.

## Ritmo recomendado

Tempo total: cerca de 20 minutos.

- Capa e roteiro: 1 minuto.
- Contexto, problema e objetivos: 4 minutos.
- Base científica, lacuna e humanidades: 4 minutos.
- Proposta, arquitetura e dashboard: 4 minutos.
- Metodologia e cenários: 3 minutos.
- Resultados, ADB, testes e fechamento: 4 minutos.

Como controlar o tempo:

- Não leia listas inteiras. Use cada lista como apoio visual.
- Em tabelas, fale a mensagem principal, não cada célula.
- Em resultados, seja honesta: “evidência funcional”, “apoio qualitativo”, “sem cálculo de erro percentual”.
- Se a banca interromper, responda direto e volte para a frase-chave do slide.

## Conceitos que você precisa dominar

### Flutter

Flutter é um framework para criar aplicações multiplataforma com uma única base de código. Ele aumenta produtividade, mas aplicações Flutter modernas podem ter listas dinâmicas, animações, chamadas de rede, estado reativo e reconstruções frequentes de widgets. Tudo isso pode afetar fluidez, memória, CPU e bateria.

Fala natural:

> Flutter acelera o desenvolvimento, mas isso não elimina a necessidade de observar desempenho. Como o mesmo app roda em celulares muito diferentes, o diagnóstico contínuo fica ainda mais importante.

### FPS e jank

FPS mede fluidez. Em uma meta de 60 FPS, cada quadro precisa ser desenhado em aproximadamente 16,67 ms. Quando alguns quadros passam muito desse tempo, o usuário percebe engasgos. Esse efeito é chamado de `jank`.

Fala natural:

> O usuário não precisa saber o número do FPS. Ele sente quando a tela engasga.

### Percentis P50, P95 e P99

A média pode esconder picos ruins. Percentis ajudam a olhar a cauda da distribuição.

- P50: comportamento típico.
- P95: valor alto que aparece nos piores 5% dos quadros.
- P99: picos mais extremos.

Fala natural:

> Eu uso percentis porque a média pode parecer boa mesmo quando alguns frames estão ruins o suficiente para o usuário perceber.

### Rebuilds

Em Flutter, rebuild é normal. O problema aparece quando reconstruções são muito frequentes, atingem uma árvore grande ou acontecem sem necessidade.

Fala natural:

> Rebuild não é vilão. O problema é rebuild excessivo ou amplo demais.

### ADB, Android Profiler e Perfetto

ADB foi usado na avaliação como apoio qualitativo, principalmente com `dumpsys meminfo` e `dumpsys gfxinfo`. Android Profiler e Perfetto foram tratados como ferramentas de referência conceitual, mas não geraram séries quantitativas comparáveis neste trabalho.

Fala natural:

> O ponto aqui não é dizer que o `collector_flutter` substitui o Profiler. Ele tem outro papel: dar um primeiro diagnóstico integrado ao app. Para análise profunda, ferramentas como Profiler e Perfetto continuam importantes.

### Validação funcional e qualitativa

A validação mostrou que o pacote permanece operável e que os sinais do painel acompanham os sintomas induzidos. Ela não mede precisão estatística, erro percentual, overhead formal ou intervalos de confiança.

Fala natural:

> Essa evidência mostra operacionalidade, não precisão estatística. Para precisão, eu precisaria de mais rodadas, múltiplos dispositivos e séries comparáveis com ferramentas externas.

## Roteiro por slide

### Slide 1 - Capa - 30s

Objetivo:

- Apresentar o tema, o pacote e o recorte do trabalho.

Fala sugerida:

> Boa tarde. Eu sou a Beatriz Vocurca Frade e vou apresentar meu trabalho sobre monitoramento e otimização de recursos em aplicativos Flutter. O foco é o `collector_flutter`, uma ferramenta embarcada que busca aproximar o diagnóstico de desempenho do dia a dia do desenvolvimento.

Frase-chave:

> O objeto do trabalho é uma ferramenta concreta para diagnóstico de desempenho em Flutter.

Transição:

> Para organizar a defesa, começo pelo problema e chego depois na solução, nos cenários de validação e nos resultados.

O que a banca precisa entender:

- O trabalho não é só teórico. Existe um pacote implementado.

### Slide 2 - Roteiro da defesa - 30s

Objetivo:

- Mostrar controle da apresentação e preparar a banca para a estrutura.

Fala sugerida:

> A apresentação está dividida em seis partes. Primeiro eu contextualizo o problema e a pergunta de pesquisa. Depois trago a base científica e a lacuna. Em seguida apresento a solução, a arquitetura, o método, os resultados e o fechamento com limitações e trabalhos futuros.

Frase-chave:

> A defesa segue a mesma lógica da monografia: problema, solução, método, evidência e conclusão.

Transição:

> O ponto de partida é o próprio contexto de desenvolvimento Flutter.

O que a banca precisa entender:

- Você sabe onde está indo e não vai se perder.

### Slide 3 - Ponto de partida - 1min

Objetivo:

- Explicar por que desempenho é relevante em Flutter.

Fala sugerida:

> Flutter facilita criar aplicativos multiplataforma, mas os aplicativos atuais fazem muita coisa ao mesmo tempo: interface reativa, animações, chamadas de rede, listas dinâmicas e estados mudando com frequência. Em dispositivos móveis, isso pressiona CPU, memória, rede e bateria. Quando algo degrada, o usuário percebe como travamento, queda de fluidez ou sensação de aplicativo pesado.

Expressões úteis:

- “Desempenho deixa de ser detalhe técnico e passa a fazer parte da experiência.”
- “O mesmo aplicativo precisa funcionar em dispositivos muito diferentes.”

Frase-chave:

> Performance em Flutter precisa ser observada durante o desenvolvimento, não só no fim.

Transição:

> O problema é que o diagnóstico ainda costuma depender de ferramentas externas.

O que a banca precisa entender:

- O problema é real e aparece no ciclo cotidiano de desenvolvimento.

### Slide 4 - Problema de pesquisa - 1min15s

Objetivo:

- Delimitar a lacuna prática.

Fala sugerida:

> As ferramentas atuais são muito boas tecnicamente. DevTools, Android Profiler, Perfetto e Instruments entregam dados ricos. A dificuldade é o uso contínuo. Elas ficam fora do aplicativo, exigem configuração, conexão, troca de tela e interpretação manual. Então muitas equipes deixam performance para o fim, quando o problema já pode ter chegado ao usuário.

Pergunta central:

> Como tornar o diagnóstico de desempenho mais acessível, contínuo e acionável em Flutter?

Frase-chave:

> A lacuna não é falta de dado; é transformar dado em ação no momento certo.

Transição:

> A partir dessa pergunta, defini os objetivos do pacote.

O que a banca precisa entender:

- Você não está atacando as ferramentas existentes. Está propondo uma camada complementar.

### Slide 5 - Objetivos - 1min

Objetivo:

- Explicar o escopo do que foi entregue.

Fala sugerida:

> O objetivo geral foi desenvolver e avaliar funcionalmente uma biblioteca embarcada para aplicações Flutter. A biblioteca deveria coletar métricas como FPS, jank, memória, rede, CPU, bateria, eventos e rebuilds. Também deveria analisar esses sinais, mostrar recomendações por severidade, exportar dados e ser validada em cenários controlados.

Expressões úteis:

- “O foco é diagnóstico inicial e integrado.”
- “A ferramenta orienta uma primeira investigação.”

Frase-chave:

> O pacote junta coleta, análise, visualização e recomendação em uma única experiência.

Transição:

> Para fundamentar essas decisões, a revisão bibliográfica olhou três grupos de trabalhos.

O que a banca precisa entender:

- O escopo é implementável e mensurável, mas não promete substituir profiling profundo.

### Slide 6 - Base científica - 1min15s

Objetivo:

- Mostrar que as métricas escolhidas têm base na literatura.

Fala sugerida:

> A literatura ajudou a organizar três ideias. Primeiro, estudos sobre energia mostram que CPU, rede, tempo de execução e memória têm relação com consumo. Segundo, trabalhos de performance móvel reforçam que o comportamento precisa ser visto por múltiplos sinais, não por uma métrica isolada. Terceiro, trabalhos de diagnóstico mostram que sintomas observáveis podem orientar hipóteses de otimização.

Expressões úteis:

- “O pacote não mede corrente elétrica diretamente; ele usa sinais de software associados a desempenho e consumo.”
- “A proposta nasce dessa leitura conjunta de métricas.”

Frase-chave:

> Desempenho móvel é multidimensional, então o coletor observa vários sinais ao mesmo tempo.

Transição:

> Mesmo com essa base e com ferramentas maduras, ainda existe uma lacuna no fluxo do desenvolvedor.

O que a banca precisa entender:

- As métricas não foram escolhidas aleatoriamente.

### Slide 7 - Lacuna identificada - 1min

Objetivo:

- Explicar a posição do `collector_flutter` em relação às ferramentas existentes.

Fala sugerida:

> O ponto aqui não é substituir DevTools, Android Profiler ou Perfetto. Essas ferramentas continuam essenciais para investigação profunda. O espaço do `collector_flutter` é outro: oferecer um primeiro diagnóstico com baixa fricção, dentro do próprio app, durante o ciclo normal de desenvolvimento.

Expressões úteis:

- “Menos ferramenta externa para o primeiro alerta, mais feedback no fluxo real.”
- “O Profiler entra quando eu quero aprofundar. O `collector_flutter` entra antes, para sinalizar onde olhar.”

Frase-chave:

> A contribuição está entre medir e agir.

Transição:

> Essa discussão também tem impacto além da técnica.

O que a banca precisa entender:

- O trabalho é complementar, não concorrente direto com Profiler/Perfetto.

### Slide 8 - Humanidades - 1min

Objetivo:

- Relacionar performance a impacto social, ambiental e ético.

Fala sugerida:

> Performance também tem uma dimensão social. Um app pesado funciona pior em aparelhos de entrada, consome mais bateria e pode contribuir para obsolescência percebida. Além disso, monitoramento precisa ter cuidado ético. Por isso, o pacote coleta métricas técnicas de desempenho e não dados pessoais ou conteúdo do usuário.

Expressões úteis:

- “Otimizar recursos é respeitar o dispositivo e o contexto de uso.”
- “Eficiência também é acessibilidade.”

Frase-chave:

> Diagnóstico de desempenho apoia qualidade técnica, mas também inclusão, sustentabilidade e privacidade.

Transição:

> Com esse contexto, entro na solução proposta.

O que a banca precisa entender:

- O capítulo de humanidades não é enfeite; ele conecta performance a impacto.

### Slide 9 - Proposta: `collector_flutter` - 1min

Objetivo:

- Apresentar a ferramenta em termos simples.

Fala sugerida:

> O `collector_flutter` é um pacote Dart/Flutter de código aberto que funciona dentro da aplicação monitorada. Ele coleta métricas, analisa sintomas por heurísticas, mostra recomendações em um dashboard e permite exportar a sessão. Eu costumo resumir como um termômetro embarcado: ele observa sinais vitais do app e mostra onde investigar primeiro.

Expressões úteis:

- “Termômetro embarcado.”
- “Primeiro diagnóstico.”
- “Recomendação acionável, não só número solto.”

Frase-chave:

> A ferramenta mora dentro do app e transforma telemetria em orientação inicial.

Transição:

> Para sustentar isso, a implementação foi organizada em três camadas.

O que a banca precisa entender:

- A solução tem um formato claro: pacote, dashboard, heurísticas e exportação.

### Slide 10 - Arquitetura - 1min15s

Objetivo:

- Explicar a organização técnica sem entrar em excesso de detalhe.

Fala sugerida:

> A arquitetura segue três camadas. A camada Data concentra as fontes de dados: frames, memória, rede, eventos, CPU e bateria. A camada Domain contém as entidades, casos de uso, Analyzer e Recommender. A camada Presentation exibe o dashboard e gerencia o estado com Bloc. Essa separação ajudou a adicionar CPU, bateria e exportação sem bagunçar a estrutura central.

Expressões úteis:

- “Cada camada tem uma responsabilidade clara.”
- “A arquitetura facilitou extensão e testes.”

Frase-chave:

> Separar coleta, análise e apresentação foi essencial para evoluir o pacote.

Transição:

> A parte mais visível dessa arquitetura é o dashboard integrado.

O que a banca precisa entender:

- A arquitetura não é só desenho. Ela explicou a evolução do pacote.

### Slide 11 - Dashboard integrado - 1min

Objetivo:

- Mostrar que a ferramenta existe visualmente e como o usuário percebe o diagnóstico.

Fala sugerida:

> Aqui estão duas telas do painel. À esquerda, uma condição estável, com indicadores em faixas aceitáveis e recomendação informativa. À direita, uma condição com gargalos, mostrando eventos de rede, alertas e recomendações. A ideia é que o desenvolvedor não precise interpretar só logs: ele vê o estado do app em tempo real.

Expressões úteis:

- “O painel traduz sinais técnicos em leitura rápida.”
- “O desenvolvedor olha e entende se precisa investigar.”

Frase-chave:

> O dashboard é o ponto em que métrica vira diagnóstico visual.

Transição:

> Depois da implementação, o pacote foi avaliado em cenários controlados.

O que a banca precisa entender:

- Há uma interface concreta, não apenas classes internas.

### Slide 12 - Metodologia - 1min

Objetivo:

- Deixar claro o tipo de avaliação realizada.

Fala sugerida:

> A metodologia foi aplicada e funcional. O pacote foi desenvolvido em ciclo iterativo, com revisão bibliográfica, requisitos, implementação e validação. A avaliação usou execuções controladas no aplicativo de exemplo. Importante: os resultados foram tratados como evidência funcional e qualitativa. Não é um experimento estatístico com amostra grande.

Expressões úteis:

- “Aqui eu prefiro ser metodologicamente conservadora.”
- “Eu não transformo evidência funcional em precisão estatística.”

Frase-chave:

> A validação mostra operacionalidade e coerência dos sintomas, não precisão formal.

Transição:

> Os cenários foram desenhados para provocar cargas específicas.

O que a banca precisa entender:

- Você sabe exatamente o alcance da validação.

### Slide 13 - Cenários testados - 1min

Objetivo:

- Apresentar as quatro cargas controladas.

Fala sugerida:

> Foram quatro cenários. O primeiro força rebuilds para observar renderização. O segundo dispara chamadas de rede simultâneas. O terceiro faz alocação intensiva de memória. O quarto combina as cargas para observar o pacote sob múltiplos sinais ao mesmo tempo. Cada cenário provoca um sintoma esperado, e o painel precisa tornar esse sintoma visível.

Expressões úteis:

- “Cada cenário foi pensado para provocar um tipo de sintoma.”
- “A pergunta era: o painel acompanha o comportamento esperado?”

Frase-chave:

> Os cenários validam comportamento funcional, não benchmark estatístico.

Transição:

> Para documentar isso, foram geradas imagens reais do aplicativo.

O que a banca precisa entender:

- Os cenários têm intenção clara e relação com as métricas.

### Slide 14 - Evidências dos cenários - 1min

Objetivo:

- Mostrar evidências visuais reais.

Fala sugerida:

> Essas imagens foram geradas no próprio projeto, usando o aplicativo de exemplo. Elas aparecem na monografia no Apêndice B, junto das leituras ADB. O objetivo é deixar rastreável o que foi observado em cada cenário: rebuilds, rede, memória e carga combinada.

Expressões úteis:

- “Aqui não são imagens ilustrativas; são capturas do projeto.”
- “As evidências estão preservadas no apêndice para conferência.”

Frase-chave:

> As imagens tornam a validação mais concreta e auditável.

Transição:

> Além das imagens, os logs e leituras ADB deram valores para discutir.

O que a banca precisa entender:

- A monografia não inventa cenários; ela mostra capturas do app real.

### Slide 15 - Resultados observados - 1min30s

Objetivo:

- Explicar os principais números sem exagerar o significado.

Fala sugerida:

> Nos rebuilds, o log registrou 30 reconstruções, FPS estimado de 55,4, P95 de 20,4 ms e 2 frames longos. Em rede, foram 9 requisições, P95 de 139,5 ms e 4 frames longos. No cenário de memória, o ADB mostrou RSS de 236.480 KB e PSS de 222.232 KB. Na carga combinada, apareceram 17 requisições, 54 rebuilds, FPS de 44,6 e CPU de 75,3%. Esses dados indicam que o painel e os logs acompanham os sintomas induzidos.

Expressões úteis:

- “Esses números dão lastro à observação, mas não são uma análise estatística.”
- “O resultado principal é operacionalidade com sinais coerentes.”

Frase-chave:

> Essa evidência mostra operacionalidade, não precisão estatística.

Transição:

> Para não superinterpretar esses resultados, é importante falar do papel do ADB e dos limites.

O que a banca precisa entender:

- Você sabe ler seus próprios resultados com cuidado.

### Slide 16 - ADB, Profiler e limites - 1min30s

Objetivo:

- Evitar a pergunta crítica sobre Android Profiler/Perfetto e comparação quantitativa.

Fala sugerida:

> A avaliação usou ADB como apoio qualitativo, especialmente `dumpsys meminfo` e `dumpsys gfxinfo`. O `meminfo` trouxe leituras úteis de memória. O `gfxinfo` confirmou a superfície Flutter, mas retornou contadores HWUI zerados nessa execução, então não foi possível calcular erro percentual de FPS. Android Profiler e Perfetto ficaram como referências conceituais neste trabalho, não como fonte de série quantitativa comparável.

Expressões úteis:

- “Eu mantive essa limitação no texto em vez de esconder.”
- “O correto metodologicamente foi não inventar comparação formal.”

Frase-chave:

> A comparação foi qualitativa e apoiada por ADB; Profiler e Perfetto ficam como evolução futura.

Transição:

> Além da execução manual, o pacote tem testes automatizados.

O que a banca precisa entender:

- Você resolveu a crítica do professor sobre ferramentas de referência com honestidade metodológica.

### Slide 17 - Testes automatizados - 1min

Objetivo:

- Explicar o papel dos 60 testes.

Fala sugerida:

> A suíte automatizada tem 60 testes em quatro arquivos: 24 para análise e estatísticas, 17 para CPU e bateria, 12 para recomendações e 7 para exportação. Esses testes verificam cálculos internos, serialização, regras de recomendação e comportamento de fallback dos canais nativos. Eles não substituem experimento de desempenho em dispositivo real, mas aumentam a confiança na lógica interna do pacote.

Expressões úteis:

- “Teste unitário prova contrato interno, não performance final.”
- “A validação manual e os testes automatizados se complementam.”

Frase-chave:

> Os 60 testes dão confiança na lógica, enquanto os cenários mostram o pacote em uso.

Transição:

> Com isso, ficam claros também os limites e próximos passos.

O que a banca precisa entender:

- Os testes têm papel correto e não estão sendo vendidos como validação total.

### Slide 18 - Limitações e trabalhos futuros - 1min20s

Objetivo:

- Mostrar maturidade e continuidade.

Fala sugerida:

> As principais limitações são: validação funcional sem análise estatística, foco principal em Android, ausência de estudo formal de usabilidade e comparação ADB apenas como apoio qualitativo. Como trabalhos futuros, eu proponho rodadas quantitativas com múltiplos dispositivos, séries comparáveis com Profiler, Perfetto e ADB, suporte mais completo no iOS e avaliação com desenvolvedores Flutter.

Expressões úteis:

- “Essas limitações não invalidam o trabalho; elas delimitam o que ele afirma.”
- “A evolução natural é transformar a evidência funcional em experimento quantitativo.”

Frase-chave:

> O trabalho entrega uma base funcional e deixa claro o caminho para validação quantitativa.

Transição:

> Para concluir, volto à contribuição central.

O que a banca precisa entender:

- Você não está fugindo das limitações. Você as incorporou ao argumento.

### Slide 19 - Conclusão - 1min

Objetivo:

- Fechar com a contribuição principal.

Fala sugerida:

> O trabalho mostrou que é viável aproximar o primeiro diagnóstico de desempenho do fluxo real de desenvolvimento Flutter. O `collector_flutter` coleta sinais, interpreta sintomas e apresenta recomendações dentro do próprio app. A arquitetura permitiu evoluir o pacote com CPU, bateria, exportação e testes. E a validação funcional indicou que o sistema permanece operável e responde aos cenários induzidos, sempre respeitando os limites metodológicos da avaliação.

Expressões úteis:

- “Performance não é só fazer o app rodar mais rápido.”
- “É fazer o app respeitar melhor o dispositivo, a bateria e a pessoa que o usa.”

Frase-chave:

> Diagnóstico acessível ajuda performance a virar prática cotidiana.

Transição:

> Obrigada. Fico à disposição para perguntas.

O que a banca precisa entender:

- A contribuição técnica, acadêmica e prática está clara.

### Slide 20 - Perguntas - livre

Objetivo:

- Encerrar com calma e abrir a discussão.

Fala sugerida:

> Obrigada pela atenção. Fico à disposição para perguntas.

Se houver silêncio:

> Posso comentar mais detalhes sobre a arquitetura, sobre os cenários de validação ou sobre os limites da comparação com ADB.

Frase-chave:

> Encerrar com segurança, sem adicionar informações novas demais.

## Perguntas prováveis da banca

### 1. Por que não usar só Flutter DevTools ou Android Profiler?

Resposta:

> DevTools e Android Profiler são ferramentas excelentes, mas ficam fora do aplicativo e exigem uma etapa separada de análise. O `collector_flutter` não tenta substituir essas ferramentas. Ele atua antes, como um primeiro diagnóstico integrado ao app, para reduzir fricção e apontar onde vale investigar com mais profundidade.

### 2. O `collector_flutter` substitui o Perfetto?

Resposta:

> Não. Perfetto é uma ferramenta de tracing profunda, muito mais detalhada e de baixo nível. O `collector_flutter` tem outro objetivo: feedback rápido e acionável dentro do fluxo Flutter. Em trabalhos futuros, Perfetto pode ser usado para comparação quantitativa mais formal.

### 3. Por que a validação é qualitativa?

Resposta:

> Porque o protocolo executado avaliou operacionalidade e coerência dos sinais em cenários controlados, mas não teve amostra estatística suficiente, múltiplos dispositivos e séries temporais comparáveis para calcular erro, intervalo de confiança ou overhead formal. Então o texto usa uma afirmação conservadora: validação funcional e qualitativa.

### 4. O que significa dizer que a evidência mostra operacionalidade?

Resposta:

> Significa que o pacote executou, coletou sinais, atualizou o painel, gerou logs e respondeu aos cenários induzidos sem interromper o aplicativo de exemplo. Isso demonstra funcionamento integrado, mas ainda não mede precisão estatística.

### 5. Por que o `gfxinfo` retornou contadores zerados?

Resposta:

> Na execução registrada, o `dumpsys gfxinfo` confirmou a superfície Flutter, mas os agregados HWUI tradicionais vieram zerados. Isso pode ocorrer pela forma como o Flutter renderiza via superfície própria e pela combinação específica de emulador e modo de execução. Por isso eu não usei esse dado para calcular erro de FPS. Mantive a limitação explicitamente no texto.

### 6. Por que o painel mostrou 0,0 MB no cenário de memória?

Resposta:

> Essa foi uma limitação observada no snapshot do painel. Ao mesmo tempo, o ADB registrou RSS total de 236.480 KB e PSS total de 222.232 KB, mostrando que houve crescimento real de memória no processo. O correto foi documentar a divergência como limitação da leitura interna no emulador, não esconder o resultado.

### 7. Os 60 testes provam que o pacote mede desempenho corretamente?

Resposta:

> Não sozinho. Os 60 testes verificam lógica interna: estatísticas, recomendações, exportação e fallbacks dos canais nativos. Eles dão confiança na implementação, mas não substituem experimentos de desempenho em dispositivos reais. Por isso o trabalho combina testes automatizados com cenários manuais controlados.

### 8. O pacote mede consumo de energia real?

Resposta:

> Não mede corrente elétrica nem consumo energético físico. Ele usa proxies de desempenho associados ao consumo, como CPU, memória, rede, tempo de frame e bateria. A análise energética é inferencial e qualitativa.

### 9. O overhead de 5% foi medido?

Resposta:

> O limite de 5% aparece como requisito não funcional e alvo de projeto. Nesta versão, o overhead foi tratado funcionalmente: o coletor deveria permanecer operável sem bloquear o aplicativo de exemplo. A medição formal de overhead, com comparação com e sem coletor e repetição estatística, fica como trabalho futuro.

### 10. Por que usar heurísticas em vez de machine learning?

Resposta:

> Porque o objetivo era construir uma ferramenta leve, explicável e fácil de integrar. Heurísticas são transparentes: o desenvolvedor entende por que um alerta apareceu. Machine learning exigiria base de dados, treinamento, validação e explicabilidade, o que ampliaria muito o escopo do TCC.

### 11. Como as recomendações são geradas?

Resposta:

> O módulo `Analyzer` resume e identifica sintomas, como FPS baixo, frames longos, uso de CPU ou padrão de rede. O `Recommender` transforma esses sintomas em mensagens por severidade. A recomendação não é uma verdade absoluta; ela orienta a primeira investigação.

### 12. O pacote pode ser usado em produção?

Resposta:

> O foco principal é desenvolvimento, depuração e pesquisa. Como ele exibe dashboard e coleta telemetria local, o uso em produção exigiria cuidado com configuração, impacto de desempenho, privacidade e modo de ativação. A proposta do TCC é reduzir fricção durante desenvolvimento.

### 13. Por que Clean Architecture?

Resposta:

> Porque separar Data, Domain e Presentation ajudou a manter coleta, regra de análise e interface com responsabilidades distintas. Isso facilitou testes e permitiu adicionar CPU, bateria e exportação sem alterar toda a estrutura.

### 14. Qual foi a principal limitação técnica encontrada?

Resposta:

> A principal limitação foi a dificuldade de obter uma comparação quantitativa confiável com ferramentas externas no ambiente disponível. O `gfxinfo` retornou contadores zerados e a leitura interna de memória apresentou divergência no snapshot. Por isso, a validação ficou funcional e qualitativa.

### 15. Qual é a principal contribuição do trabalho?

Resposta:

> A principal contribuição é mostrar uma forma concreta de aproximar diagnóstico de desempenho do fluxo Flutter: coleta embarcada, dashboard, recomendações, exportação e testes, tudo organizado em uma arquitetura extensível.

## Frases de segurança

Use estas frases se precisar responder com cuidado:

- “Eu prefiro ser conservadora metodologicamente aqui.”
- “Essa evidência sustenta operacionalidade, mas não precisão estatística.”
- “O ponto aqui não é substituir ferramentas especializadas, e sim reduzir o atrito do primeiro diagnóstico.”
- “Essa limitação foi mantida no texto justamente para não superinterpretar os dados.”
- “Os testes automatizados verificam contratos internos; a validação experimental exige outro tipo de protocolo.”
- “Como trabalho futuro, eu transformaria essa observação funcional em uma comparação quantitativa com múltiplas rodadas e dispositivos.”

## Fechamento para ensaio

Última versão curta para memorizar:

> O `collector_flutter` nasce da ideia de que performance precisa ser observada continuamente durante o desenvolvimento. Ele não substitui DevTools, Profiler ou Perfetto, mas oferece um primeiro diagnóstico dentro do app. A validação mostrou funcionamento em quatro cenários controlados, com imagens reais, apoio qualitativo por ADB e 60 testes automatizados. O trabalho entrega uma base funcional e deixa claro o próximo passo: validação quantitativa formal.
