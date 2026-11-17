# Notat

Aplicativo de notas em Flutter, com editor rich text e organização em pastas. Roda em Android.

Este repositório é um fork de [Dev-Salem/notat](https://github.com/Dev-Salem/notat), sob licença MIT.
O código original é de [@Dev-Salem](https://github.com/Dev-Salem); o texto da licença e o aviso de
copyright estão em [License.txt](License.txt).

## O que o app faz

Criar, editar e excluir notas com formatação, organizar notas em pastas, buscar por título e
conteúdo. Contas por e-mail e senha, com verificação de e-mail. Os dados ficam no Firestore, um
documento por nota, sob o usuário dono.

## Entrega N1

### A história de usuário da Sprint 1

> Como usuário do aplicativo, quero que minhas notas sejam salvas com segurança mesmo quando eu estiver
> sem conexão com a internet e que todos os meus dados sejam excluídos definitivamente quando eu apagar
> minha conta, para que eu não perca o conteúdo que escrevi e tenha a garantia de que nenhuma
> informação, incluindo notas e pastas, permaneça armazenada após a exclusão da conta.

A equipe tirou quatro requisitos dessa história, estimou cada um em Planning Poker e priorizou por
MoSCoW. Os quatro ficaram como Must have.

Vídeo da demonstração: [assistir no OneDrive](https://catolicasc-my.sharepoint.com/:v:/g/personal/vinicius06_oliveira_catolicasc_edu_br/IQAs5xSztcn4TI-M4zIAMGObASfUQz1bU6-eL_vESUGDvGI?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=cyJe5I)

### Como cada requisito foi atendido

| Requisito                                 | Onde está                                                               | Issues que resolvem                                                                                                                                                                                                        | Como conferir                                                                                                    |
| ----------------------------------------- | ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| RF01: guardar a nota escrita sem internet | `lib/resources/firestore_methods.dart`                                  | [#28](https://github.com/notat-scrum/notat/issues/28), [#27](https://github.com/notat-scrum/notat/issues/27)                                                                                                               | Com o modo avião ligado, escreva uma nota. Ela aparece na lista na hora, em vez de sumir                         |
| RF02: apagar tudo junto com a conta       | `AuthService.deleteAccount`, que chama `FirestoreService.deleteAllDocs` | [#25](https://github.com/notat-scrum/notat/issues/25), [#27](https://github.com/notat-scrum/notat/issues/27), [#26](https://github.com/notat-scrum/notat/issues/26), [#42](https://github.com/notat-scrum/notat/issues/42) | O teste `deleteAllDocs limpa notas e pastas do usuario`, e o painel do Firestore vazio depois de excluir a conta |
| RF03: editar notas existentes             | `lib/screens/functionalities/`, `lib/models/note.dart`                  | [#24](https://github.com/notat-scrum/notat/issues/24), [#29](https://github.com/notat-scrum/notat/issues/29), [#33](https://github.com/notat-scrum/notat/issues/33), [#43](https://github.com/notat-scrum/notat/issues/43) | Abra uma nota, edite e volte. O texto e a busca continuam corretos                                               |
| RF04: sincronizar quando a internet volta | `lib/resources/firestore_methods.dart`                                  | [#28](https://github.com/notat-scrum/notat/issues/28)                                                                                                                                                                      | Desligue o modo avião. A nota escrita offline aparece no painel do Firestore                                     |

O RF01 e o RF04 saem da mesma correção. O app já usava o Firestore, que guarda um cache no aparelho e
mantém uma fila das escritas pendentes. O problema era o app brigar com isso: antes de gravar, o código
checava a conexão e recusava a escrita se não houvesse internet, e depois ficava esperando a confirmação
do servidor, que sem rede nunca chega. A [#28](https://github.com/notat-scrum/notat/issues/28) tirou a
checagem da camada de dados e parou de aguardar o `set()`. A nota entra no cache local na hora e sobe
sozinha quando a conexão volta. É a mesma "biblioteca pronta de persistência local" que a equipe citou
ao estimar o RF01 em 2 pontos.

O RF02 dependeu de mudar a estrutura dos dados. Antes, notas e pastas viviam em coleções globais, com o
dono guardado num campo. A [#25](https://github.com/notat-scrum/notat/issues/25) moveu tudo para
`users/{uid}/notes` e `users/{uid}/folders`, e é isso que torna a exclusão completa possível: apagar a
conta virou varrer duas coleções inteiras, em lote, sem depender de filtro. A
[#26](https://github.com/notat-scrum/notat/issues/26) versionou as regras que impedem um usuário de ler
ou escrever fora da própria subárvore.

O RF03 já existia no app herdado, e estava quebrado. As issues listadas não implementam a edição do
zero. Elas consertam a perda de dados na hora de editar: modelo tipado no lugar de `Map` cru,
controllers com ciclo de vida correto e o texto de busca gravado sem escape de JSON.

### Marcos, issues e PRs

O trabalho foi organizado em três marcos, com uma issue por tarefa e um commit por issue. Os três PRs
abaixo estão mergeados na `master`.

#### [Marco 1: o app compila e roda](https://github.com/notat-scrum/notat/milestone/1) · PR [#39](https://github.com/notat-scrum/notat/pull/39)

O projeto herdado não compilava. Este marco destrava o build e deixa um app que qualquer pessoa clona e
roda no aparelho.

| Issue                                                 | O que mudou                                                     |
| ----------------------------------------------------- | --------------------------------------------------------------- |
| [#1](https://github.com/notat-scrum/notat/issues/1)   | Versão do Flutter travada em 3.47.2 pelo `.fvmrc`               |
| [#2](https://github.com/notat-scrum/notat/issues/2)   | `flutter_lints` declarado e constraint do Dart atualizado       |
| [#3](https://github.com/notat-scrum/notat/issues/3)   | Plataforma iOS removida: o app é só Android                     |
| [#4](https://github.com/notat-scrum/notat/issues/4)   | Gradle migrado para o template atual do Flutter                 |
| [#5](https://github.com/notat-scrum/notat/issues/5)   | `applicationId` vazio corrigido para `br.com.notat.app`         |
| [#6](https://github.com/notat-scrum/notat/issues/6)   | Build de release parou de assinar com a chave de debug          |
| [#7](https://github.com/notat-scrum/notat/issues/7)   | Pacote Dart renomeado para `notat`                              |
| [#8](https://github.com/notat-scrum/notat/issues/8)   | Nome e ícone do app aplicados no Android                        |
| [#9](https://github.com/notat-scrum/notat/issues/9)   | Configuração do Firebase gerada e versionada                    |
| [#10](https://github.com/notat-scrum/notat/issues/10) | Firebase atualizado e inicializado por `DefaultFirebaseOptions` |
| [#11](https://github.com/notat-scrum/notat/issues/11) | Editor migrado do `flutter_quill` 5 para o 11                   |
| [#12](https://github.com/notat-scrum/notat/issues/12) | Demais dependências atualizadas                                 |
| [#13](https://github.com/notat-scrum/notat/issues/13) | Dependências sem uso removidas                                  |
| [#14](https://github.com/notat-scrum/notat/issues/14) | Pacotes abandonados substituídos por código próprio             |
| [#15](https://github.com/notat-scrum/notat/issues/15) | `exit()` que fechava o app na cara do usuário removido          |
| [#16](https://github.com/notat-scrum/notat/issues/16) | Teste de template quebrado trocado por testes dos validadores   |
| [#17](https://github.com/notat-scrum/notat/issues/17) | `flutter analyze` zerado                                        |
| [#18](https://github.com/notat-scrum/notat/issues/18) | Workflow de CI criado                                           |
| [#19](https://github.com/notat-scrum/notat/issues/19) | Validação no aparelho e correção das regressões visuais         |
| [#30](https://github.com/notat-scrum/notat/issues/30) | Uso de `context` depois de `await` protegido por `mounted`      |

#### [Marco 2: arquitetura e dados](https://github.com/notat-scrum/notat/milestone/2) · PR [#41](https://github.com/notat-scrum/notat/pull/41)

É o marco que entrega a história de usuário da Sprint 1. A coluna RF diz qual requisito cada issue
atende. As três que carregam a história são a #25, a #27 e a #28.

| Issue                                                 | O que mudou                                                              | RF         |
| ----------------------------------------------------- | ------------------------------------------------------------------------ | ---------- |
| [#20](https://github.com/notat-scrum/notat/issues/20) | Dados de desenvolvimento do projeto Firebase zerados                     |            |
| [#21](https://github.com/notat-scrum/notat/issues/21) | Testes da camada de dados, escritos antes da implementação               | RF02       |
| [#22](https://github.com/notat-scrum/notat/issues/22) | Riverpod migrado da versão 1 para a 3                                    |            |
| [#23](https://github.com/notat-scrum/notat/issues/23) | Serviços expostos como providers amarrados ao usuário logado             | RF02       |
| [#24](https://github.com/notat-scrum/notat/issues/24) | Modelo `Note` tipado no lugar de `Map` cru                               | RF03       |
| [#25](https://github.com/notat-scrum/notat/issues/25) | Coleções remodeladas para `users/{uid}/notes` e `users/{uid}/folders`    | RF02       |
| [#26](https://github.com/notat-scrum/notat/issues/26) | Regras de segurança e índices do Firestore versionados                   | RF02       |
| [#27](https://github.com/notat-scrum/notat/issues/27) | Erros engolidos na camada de dados, e exclusão em massa por lote         | RF02       |
| [#28](https://github.com/notat-scrum/notat/issues/28) | Bloqueio de escrita offline removido                                     | RF01, RF04 |
| [#29](https://github.com/notat-scrum/notat/issues/29) | Ciclo de vida dos controllers e editores corrigido                       | RF03       |
| [#31](https://github.com/notat-scrum/notat/issues/31) | Regra de senha forte aplicada só no cadastro, não no login               |            |
| [#32](https://github.com/notat-scrum/notat/issues/32) | Retorno de erro do cadastro corrigido e mensagens do Firebase traduzidas |            |
| [#33](https://github.com/notat-scrum/notat/issues/33) | Busca de notas implementada sobre o `searchableDocument`                 | RF03       |
| [#34](https://github.com/notat-scrum/notat/issues/34) | Peso dos assets reduzido de 2,4 MB para 175 KB                           |            |
| [#40](https://github.com/notat-scrum/notat/issues/40) | Emuladores locais do Firebase para desenvolvimento                       |            |
| [#42](https://github.com/notat-scrum/notat/issues/42) | Sair e excluir a conta voltam para a tela inicial                        | RF02       |
| [#43](https://github.com/notat-scrum/notat/issues/43) | `searchableDocument` gravado sem escape de JSON                          | RF03       |

#### [Marco 3: qualidade e documentação](https://github.com/notat-scrum/notat/milestone/3) · PR [#44](https://github.com/notat-scrum/notat/pull/44)

| Issue                                                 | O que mudou                                         |
| ----------------------------------------------------- | --------------------------------------------------- |
| [#35](https://github.com/notat-scrum/notat/issues/35) | Emulador do Firebase configurado                    |
| [#36](https://github.com/notat-scrum/notat/issues/36) | Cobertura de testes publicada como comentário no PR |
| [#37](https://github.com/notat-scrum/notat/issues/37) | README de setup reescrito                           |
| [#38](https://github.com/notat-scrum/notat/issues/38) | CONTRIBUTING com o fluxo do time                    |

### Estado do código na entrega

| Verificação                         | Resultado          |
| ----------------------------------- | ------------------ |
| `fvm flutter analyze --fatal-infos` | sem problemas      |
| `fvm dart analyze`                  | sem problemas      |
| `fvm flutter test`                  | 25 testes passando |
| CI no GitHub Actions                | verde nos três PRs |

## Entrega N2

Vídeo da demonstração: [assistir no OneDrive](https://catolicasc-my.sharepoint.com/:v:/g/personal/vinicius06_oliveira_catolicasc_edu_br/IQDgW__KKDNKTq3Kr4xIAFIOAWY7pM5ZOthyjg4VgE5j6Kk?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=Ro7Cgz)

### Sprint Goal

Excluir uma pasta e escrever uma nota sem internet não deixam mais nota fantasma, duplicada ou perdida
sem aviso, e cada um desses comportamentos fica provado por teste automatizado e revisado em PR.

### Histórias de usuário da Sprint 2

A fala da cliente para a Sprint 2:

> Reparei que às vezes uma pasta que eu esvaziei ainda aparece com notas por um tempo, antes de sumir
> de vez.

A US01 vem dessa fala. A US02 é a pendência da N1: a sincronização das notas escritas sem internet.

#### US01: esvaziar uma pasta sem notas fantasma

> Como usuário que organiza as notas em pastas, quero que, ao esvaziar uma pasta, as notas dela sumam
> na hora e de vez, para confiar que o que eu apaguei foi apagado.

Critérios de aceite:

1. **Dado** uma pasta com três notas, **quando** excluo a pasta com as notas de dentro, **então** a
   pasta e as três notas somem das abas All e Folders de uma vez, sem sumir uma a uma e sem reaparecer
   depois.
2. **Dado** notas em outras pastas, **quando** excluo uma pasta, **então** as notas das outras pastas
   continuam lá.
3. **Dado** que estou sem internet, **quando** excluo uma pasta, **então** a pasta e as notas dela somem
   na hora e não voltam quando a conexão volta.
4. **Dado** que a exclusão falha, **quando** tento excluir a pasta, **então** vejo uma mensagem de erro,
   em vez de a tela continuar como se nada tivesse acontecido.
5. **Dado** notas em várias pastas, **quando** uso o Clear All notes, **então** todas as notas somem de
   uma vez e as pastas continuam.

#### US02: nota escrita sem internet chega ao servidor uma única vez

> Como usuário que escreve notas sem internet, quero que cada nota seja enviada ao servidor uma única vez
> quando a conexão voltar, para não ficar com cópias duplicadas nem perder o que escrevi.

Critérios de aceite:

1. **Dado** que estou sem internet, **quando** salvo uma nota nova, **então** ela aparece na lista na
   hora.
2. **Dado** uma nota criada sem internet, **quando** a conexão volta, **então** existe exatamente um
   documento dela no Firestore, com o conteúdo que escrevi.
3. **Dado** uma nota editada duas vezes sem internet, **quando** a conexão volta, **então** o servidor
   guarda só a última versão, num documento só.
4. **Dado** que o servidor recusa a gravação, **quando** salvo a nota, **então** sou avisado, em vez de a
   nota sumir sem explicação.

#### Verificação INVEST

| Critério    | US01                                                | US02                                                |
| ----------- | --------------------------------------------------- | --------------------------------------------------- |
| Independent | não depende da US02                                 | não depende da US01                                 |
| Negotiable  | a história diz o resultado, não como apagar         | a história diz o resultado, não como sincronizar    |
| Valuable    | o usuário confia na exclusão                        | o usuário não perde nem duplica o que escreveu      |
| Estimable   | a exclusão de pasta fica em dois arquivos de dados  | a escrita da nota fica num arquivo só               |
| Small       | cabe numa sprint                                    | cabe numa sprint                                    |
| Testable    | cada critério vira um teste ou um passo no aparelho | cada critério vira um teste ou um passo no aparelho |

### Trabalho adiantado na N1

Parte do que a cliente pediu já tinha sido resolvido na Sprint 1. Esses itens entram no backlog como
prontos, cada um com o teste que comprova o comportamento.

O sintoma da US01 vinha do código herdado. Ao excluir uma pasta, o app disparava a exclusão das notas
sem esperar por ela e apagava uma nota de cada vez. O método avisava que tinha terminado antes de apagar
qualquer coisa, e a lista ia esvaziando aos poucos. A [#27](https://github.com/notat-scrum/notat/issues/27)
passou a apagar tudo num lote só e a esperar o lote terminar, e a
[#25](https://github.com/notat-scrum/notat/issues/25) deixou a pasta só no campo `folderId` da nota.

A gravação sem internet da US02 entrou na [#28](https://github.com/notat-scrum/notat/issues/28), mas
nenhum teste prova que ela funciona. Por isso a US02 continua no backlog da Sprint 2, na #48.

| Item pronto                                           | Resolvido em                                                                                                 | Teste que comprova                                                            |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------- |
| US01, critérios 1 e 2: a pasta sai com as notas dela  | [#25](https://github.com/notat-scrum/notat/issues/25), [#27](https://github.com/notat-scrum/notat/issues/27) | `excluir a pasta leva junto as notas de dentro`                               |
| US01, critério 5: Clear All notes preserva as pastas  | [#27](https://github.com/notat-scrum/notat/issues/27)                                                        | `limpar as notas preserva as pastas`                                          |
| Pipeline de CI com `flutter analyze` e `flutter test` | [#18](https://github.com/notat-scrum/notat/issues/18), [#36](https://github.com/notat-scrum/notat/issues/36) | o próprio [CI](https://github.com/notat-scrum/notat/actions/workflows/ci.yml) |

### Backlog da Sprint 2

O que faltava das histórias, mais os code smells encontrados na investigação. Estimativas em pontos de
Planning Poker, na sequência de Fibonacci. As issues estão no
[Marco 4: Sprint 2](https://github.com/notat-scrum/notat/milestone/4) e foram sorteadas em pares. Cada
par toca os mesmos arquivos, para que dois PRs abertos ao mesmo tempo não entrem em conflito.

| Issue                                                 | Item                                                      | Origem           | Pontos | MoSCoW | Justificativa                                                                                                                             | Responsável                | Estado                                                      |
| ----------------------------------------------------- | --------------------------------------------------------- | ---------------- | ------ | ------ | ----------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- | ----------------------------------------------------------- |
| [#46](https://github.com/notat-scrum/notat/issues/46) | Desfazer a dependência circular entre os serviços         | code smell       | 3      | Must   | Smell do catálogo, e toca os mesmos arquivos da #47                                                                                       | Eduardo Hoeft              | Pronto, [#58](https://github.com/notat-scrum/notat/pull/58) |
| [#47](https://github.com/notat-scrum/notat/issues/47) | Excluir a pasta e as notas de uma vez, mesmo sem internet | US01, critério 3 | 5      | Must   | Sem internet a pasta vazia continua na tela, que é o sintoma relatado                                                                     | Eduardo Hoeft              | Pronto, [#57](https://github.com/notat-scrum/notat/pull/57) |
| [#48](https://github.com/notat-scrum/notat/issues/48) | Provar a sincronização offline e avisar a falha           | US02             | 5      | Must   | A professora pediu prova de que a nota sobe uma vez só. Hoje a falha passa em silêncio, e reabrir uma nota editada traz a versão anterior | Vinícius Leitempergher     | Pronto, [#53](https://github.com/notat-scrum/notat/pull/53) |
| [#49](https://github.com/notat-scrum/notat/issues/49) | Extrair a montagem da nota repetida                       | code smell       | 2      | Should | Quarto smell do catálogo. O mínimo de três já está coberto pela #46, #48 e #50                                                            | Vinícius Leitempergher     | Pronto, [#54](https://github.com/notat-scrum/notat/pull/54) |
| [#50](https://github.com/notat-scrum/notat/issues/50) | Centralizar o caminho das coleções do usuário             | code smell       | 3      | Must   | Smell do catálogo, e põe sob teste os três providers que hoje não têm nenhum                                                              | Vinicius Pedroso Schoeffel | Pronto, [#55](https://github.com/notat-scrum/notat/pull/55) |
| [#51](https://github.com/notat-scrum/notat/issues/51) | Mostrar o erro da exclusão                                | US01, critério 4 | 3      | Must   | Critério de aceite da US01, e o primeiro teste de widget do projeto                                                                       | Vinicius Pedroso Schoeffel | Pronto, [#60](https://github.com/notat-scrum/notat/pull/60) |
| [#52](https://github.com/notat-scrum/notat/issues/52) | Preencher a seção da entrega N2 no README                 | entrega          | 2      | Must   | O README é o documento avaliado                                                                                                           | Vinícius Bueno de Oliveira | Pronto, [#61](https://github.com/notat-scrum/notat/pull/61) |

A Sprint 2 compromete 23 pontos. Na entrega, todas as issues estão em Pronto, e com elas a US01 e
a US02.

### Papéis na Sprint 2

| Papel             | Integrante                                                        |
| ----------------- | ----------------------------------------------------------------- |
| Product Owner     | Vinícius Bonatti Benner                                           |
| Scrum Master      | Vinícius Bueno de Oliveira                                        |
| Revisão de código | Vinícius Bueno de Oliveira                                        |
| Dev               | Eduardo Hoeft, Vinícius Leitempergher, Vinicius Pedroso Schoeffel |

### Definition of Done

Uma issue só está pronta quando:

- o comportamento que ela muda tem teste automatizado escrito antes da mudança: numa correção, o teste
  falha antes e passa depois; numa refatoração, o teste de regressão passa antes e depois, sem
  alteração;
- o que os arquivos tocados fazem e ainda não tinha teste ganhou teste no mesmo PR;
- os critérios de aceite da história que ela atende foram conferidos, e o que depende do aparelho tem
  print no PR;
- não introduz code smell conhecido, e o smell corrigido entrou no catálogo abaixo;
- `fvm dart format .`, `fvm flutter analyze --fatal-infos`, `fvm dart analyze` e `fvm flutter test`
  passam, e o CI está verde;
- o PR foi revisado e aprovado por um colega, com os comentários da revisão no próprio PR;
- está mergeada na `master`, a issue fechou e o card está em Pronto no quadro.

Uma história está pronta quando todas as issues dela estão.

### Catálogo de code smells

| Issue                                                 | Smell                                                                | Onde está                                                                                                        | Refatoração aplicada                                                                                                                                                                                                                                                                                             | Teste de regressão                                                                                                                                                                                                                                                                                                                                                                                                 | Tipo            |
| ----------------------------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------- |
| [#46](https://github.com/notat-scrum/notat/issues/46) | Dependência circular entre os serviços                               | `lib/resources/firestore_methods.dart`, construtor; `lib/resources/firstore_folder_methods.dart`, `deleteFolder` | os dois serviços deixaram de instanciar e importar um ao outro; `deleteFolder` apaga as notas direto por lote e `deleteAllDocs` busca as pastas pelo próprio caminho                                                                                                                                             | `excluir a pasta leva junto as notas de dentro`, `deleteAllDocs limpa notas e pastas do usuario`, `deleteDocsOfFolder apaga apenas as notas da pasta solicitada`, `deleteFolder All nao apaga nada`                                                                                                                                                                                                                | refatoração     |
| [#48](https://github.com/notat-scrum/notat/issues/48) | `try/catch` que nunca captura, em volta de um `Future` não aguardado | `lib/resources/firestore_methods.dart`, `addDocument` e `updateDocument`                                         | o `try/catch` saiu e a falha é tratada no próprio `Future` do `set()`, com `catchError`, e vai para o `falhaGravacaoProvider`, que o app inteiro escuta                                                                                                                                                          | `a falha ao criar a nota chega ao usuario depois que a tela fechou`, `a falha ao editar a nota chega ao usuario depois que a tela fechou`                                                                                                                                                                                                                                                                          | correção de bug |
| [#49](https://github.com/notat-scrum/notat/issues/49) | Código duplicado na montagem da nota                                 | `lib/resources/firestore_methods.dart`, `addDocument` e `updateDocument`                                         | a montagem e a normalização foram para o `Note.fromEditor`, em `lib/models/note.dart`, usado pela criação e pela edição                                                                                                                                                                                          | `o searchableDocument guarda o texto puro, sem escape de JSON`, `editar a nota normaliza o searchableDocument do mesmo jeito`, `criar a nota sem titulo grava untitled`, `editar a nota apagando o titulo grava untitled`                                                                                                                                                                                          | refatoração     |
| [#50](https://github.com/notat-scrum/notat/issues/50) | Caminho das coleções repetido em cinco lugares                       | `lib/providers/note_provider.dart`, `lib/providers/folders_provider.dart`, `lib/resources/`                      | o caminho `users/{uid}/...` foi para `notesOf` e `foldersOf`, em `lib/resources/user_collections.dart`, e o tratamento do deslogado para `watchUserNotes` e `watchUserFolders`, em `lib/providers/user_collections_provider.dart`; os três providers e os dois serviços passaram a usá-los, sem mudar construtor | `notesProvider devolve lista vazia em vez de ficar carregando`, `notesInFolderProvider devolve lista vazia em vez de ficar carregando`, `folderProvider devolve lista vazia em vez de ficar carregando`, `traz as notas do usuario da mais nova para a mais antiga`, `nao traz as notas de outro uid`, `traz so as notas da pasta pedida`, `traz as pastas na ordem de criacao`, `nao traz as pastas de outro uid` | refatoração     |

### Pull requests e CI

Pipeline: [CI no GitHub Actions](https://github.com/notat-scrum/notat/actions/workflows/ci.yml), que
roda formatação, `flutter analyze`, `dart analyze` e `flutter test` a cada push na `master` e a cada PR.
Os comandos para rodar os testes localmente estão em [Desenvolvimento](#desenvolvimento).

| PR                                                  | O que entrega                                                                  | Revisão                                                                                                                                                                    |
| --------------------------------------------------- | ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [#45](https://github.com/notat-scrum/notat/pull/45) | Seção da entrega N2 no README: histórias, backlog, papéis e Definition of Done | Vinícius Bonatti Benner, aprovado. A revisão achou o bug da versão antiga ao reabrir uma nota editada, que entrou na #48                                                   |
| [#53](https://github.com/notat-scrum/notat/pull/53) | Prova a sincronização offline e avisa quando a gravação falha (#48)            | Vinícius Bueno de Oliveira, aprovado depois de um pedido de alteração. A revisão rodou cada commit para conferir o teste vermelho antes da correção e o verde depois       |
| [#54](https://github.com/notat-scrum/notat/pull/54) | Extrai a montagem da nota para o `Note.fromEditor` (#49)                       | Vinícius Bueno de Oliveira, aprovado depois de um pedido de alteração. A revisão achou o PR apontado para a `master`, o que levaria junto os commits da #48 sem revisão    |
| [#55](https://github.com/notat-scrum/notat/pull/55) | Centraliza o caminho das coleções do usuário (#50)                             | Vinícius Bueno de Oliveira, aprovado depois de um pedido de alteração. O PR chegou só com os testes, e a revisão pediu a refatoração no mesmo PR, sem mexer neles          |
| [#56](https://github.com/notat-scrum/notat/pull/56) | Modelo de PR e ajuste do CONTRIBUTING                                          | Sem revisão. Mergeado pelo Scrum Master                                                                                                                                    |
| [#57](https://github.com/notat-scrum/notat/pull/57) | Exclui a pasta e as notas de uma vez, mesmo sem internet (#47)                 | Vinícius Bueno de Oliveira, aprovado depois de um pedido de alteração. A revisão tirou o `catch` das leituras do cache e fez o `deleteAllDocs` voltar a esperar o servidor |
| [#58](https://github.com/notat-scrum/notat/pull/58) | Desfaz a dependência circular entre os serviços do Firestore (#46)             | Vinícius Bueno de Oliveira, aprovado. A revisão conferiu que a pasta `test/` é a mesma antes e depois da refatoração e que os testes passam nos dois commits               |
| [#60](https://github.com/notat-scrum/notat/pull/60) | Mostra o erro da exclusão de pasta, de nota e do Clear All notes (#51)         | Vinícius Bueno de Oliveira, aprovado depois de um pedido de alteração. Faltava a terceira tela da issue, o Clear All notes, e a ligação do PR com a issue                  |
| [#61](https://github.com/notat-scrum/notat/pull/61) | Preenche a seção da entrega N2 no README (#52)                                 | Vinícius Bonatti Benner, aprovado sem apontamentos                                                                                                                         |

### Estado do código na entrega

| Verificação                         | Resultado                         |
| ----------------------------------- | --------------------------------- |
| `fvm dart format .`                 | sem alterações                    |
| `fvm flutter analyze --fatal-infos` | sem problemas                     |
| `fvm dart analyze`                  | sem problemas                     |
| `fvm flutter test`                  | 55 testes passando                |
| CI no GitHub Actions                | verde em todos os PRs da Sprint 2 |

## Entrega N3

Vídeo da demonstração: _a preencher._

### User Story

A fala da cliente para a Sprint 3:

> Escrevi uma nota no celular, sem internet, e quando abri o app em outro aparelho ela não estava lá.
> Em outro dia apareceu duplicada.

#### US03: a nota aparece em todos os aparelhos, uma vez só

> Como usuário que escreve notas no celular e abre a conta em outro aparelho, quero que cada nota
> apareça em todos os meus aparelhos uma única vez e completa, e saber quando ela ainda não foi
> enviada, para confiar que o que escrevi está guardado.

Critérios de aceite:

1. **Dado** que estou sem internet, **quando** salvo uma nota nova, **então** ela aparece na lista na
   hora, marcada como aguardando envio.
2. **Dado** uma nota aguardando envio, **quando** o aparelho em que ela foi escrita volta a ter
   internet, **então** a marca some e a nota aparece no outro aparelho da mesma conta, uma vez só e com
   o texto inteiro.
3. **Dado** a tela de nota nova, **quando** toco duas vezes seguidas em Save, **então** fica uma nota
   só e volto para a lista.
4. **Dado** uma nota editada duas vezes sem internet, **quando** a conexão volta, **então** o servidor
   guarda só a última versão, num documento só.
5. **Dado** que o servidor recusa gravar ou excluir uma nota ou uma pasta, **quando** isso acontece,
   **então** vejo uma mensagem que diz o que houve, e não o texto técnico do Firebase.

#### Origem do problema

A nota escrita sem internet fica guardada no aparelho que a escreveu e só sobe para o Firestore quando
esse aparelho volta a ter internet. Até lá, nenhum outro aparelho tem como recebê-la. O app não mostra
essa diferença: a consulta da lista (`lib/providers/user_collections_provider.dart`) não acompanha os
metadados do Firestore, e a nota pendente aparece igual a uma nota já enviada. Quem não acha a nota no
outro aparelho escreve de novo, e quando o primeiro aparelho reconecta a original sobe também: a
conta fica com duas notas iguais.

O envio em si está certo desde a N2. O id da nota é gerado uma vez e gravado com `set`, então reenviar
a mesma nota sobrescreve o mesmo documento ([#48](https://github.com/notat-scrum/notat/issues/48)). A
investigação também olhou o botão Save, porque o `addDocument` gera um id novo a cada chamada e dois
toques poderiam criar duas notas. Num teste com 0 a 200 ms entre os toques ficou uma nota só: quando o
segundo toque chega, a tela já está saindo. Esse teste entra no projeto pela
[#62](https://github.com/notat-scrum/notat/issues/62).

### Plano do release

Objetivo: a nota escrita em qualquer aparelho, com ou sem internet, aparece uma vez só e completa nos
outros aparelhos da conta, e o app mostra o que ainda não foi enviado e o que deu errado.

O MVP:

| Item                                                                   | Critério    | MoSCoW | Justificativa                                                                                               | Estado                                                        |
| ---------------------------------------------------------------------- | ----------- | ------ | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| Nota salva sem internet entra na lista na hora e sobe num documento só | US03, 1 e 2 | Must   | É o centro do pedido. A gravação já funciona e tem teste                                                    | Pronto, [#48](https://github.com/notat-scrum/notat/issues/48) |
| Edição repetida sem internet guarda só a última versão                 | US03, 4     | Must   | Sem isso a nota chega ao outro aparelho incompleta                                                          | Pronto, [#48](https://github.com/notat-scrum/notat/issues/48) |
| O card mostra se a nota foi enviada ou aguarda envio                   | US03, 1 e 2 | Must   | Responde às duas queixas: a pessoa sabe por que a nota ainda não está no outro aparelho e não escreve outra | [#63](https://github.com/notat-scrum/notat/issues/63)         |
| Dois toques no Save deixam uma nota só, com teste                      | US03, 3     | Should | Já funciona; falta o teste que prova                                                                        | [#62](https://github.com/notat-scrum/notat/issues/62)         |
| A falha do Firebase vira uma mensagem que a pessoa entende             | US03, 5     | Should | O aviso de falha já existe desde a #48, mas mostra o texto técnico do Firestore                             | [#64](https://github.com/notat-scrum/notat/issues/64)         |

O que fica para depois:

- **Exigir e-mail verificado nas regras do Firestore (Won't).** Está fora do pedido da cliente, e o
  projeto não tem teste automatizado de regras, que a Definition of Done exige.
- **Ajustar o ruleset da `master` (Won't).** É configuração da organização no GitHub, não do app.

### Sprint 3

#### Sprint Goal

Quem escreve uma nota sem internet vê no card se ela já foi enviada, e a nota aparece uma vez só,
completa, no outro aparelho da mesma conta.

#### Já pronto, com o teste que comprova

| Item pronto                                      | Resolvido em                                                                                                 | Teste que comprova                                                                                                                        |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Salvar sem internet não trava a tela             | [#28](https://github.com/notat-scrum/notat/issues/28), [#48](https://github.com/notat-scrum/notat/issues/48) | `addDocument retorna sem esperar o servidor confirmar`                                                                                    |
| Reenviar a mesma nota deixa um documento só      | [#48](https://github.com/notat-scrum/notat/issues/48)                                                        | `gravar a mesma nota duas vezes deixa um documento so`                                                                                    |
| Duas edições sem internet deixam a última versão | [#48](https://github.com/notat-scrum/notat/issues/48)                                                        | `duas edicoes seguidas deixam um documento so, com a ultima versao`                                                                       |
| A falha na gravação chega ao usuário             | [#48](https://github.com/notat-scrum/notat/issues/48)                                                        | `a falha ao criar a nota chega ao usuario depois que a tela fechou`, `a falha ao editar a nota chega ao usuario depois que a tela fechou` |

#### Backlog

Estimativas em pontos de Planning Poker, na sequência de Fibonacci. As issues estão no
[Marco 5: Sprint 3](https://github.com/notat-scrum/notat/milestone/5). É a última sprint, então cada
dev ficou com uma issue só, e os itens pequenos entraram junto de uma maior. Nenhuma issue depende de
outra: a #62 e a #63 mexem no mesmo arquivo, mas em trechos diferentes.

| Issue                                                 | Item                                                            | Origem                          | Pontos | MoSCoW | Justificativa                                                                                        | Responsável                |
| ----------------------------------------------------- | --------------------------------------------------------------- | ------------------------------- | ------ | ------ | ---------------------------------------------------------------------------------------------------- | -------------------------- |
| [#62](https://github.com/notat-scrum/notat/issues/62) | Provar o Save único e corrigir o erro ao segurar o card da nota | US03, critério 3; bug           | 3      | Should | O Save único já funciona e falta o teste. O erro do card aparece toda vez que alguém segura uma nota | Vinícius Bonatti Benner    |
| [#63](https://github.com/notat-scrum/notat/issues/63) | Mostrar no card se a nota já foi enviada                        | US03, critérios 1 e 2           | 5      | Must   | É o que resolve o pedido da cliente                                                                  | Eduardo Hoeft              |
| [#64](https://github.com/notat-scrum/notat/issues/64) | Aplicar o padrão Adapter nas mensagens de erro do Firebase      | item de reuso; US03, critério 5 | 5      | Must   | É o item de reuso da entrega, e o erro do Firestore hoje chega cru ao usuário                        | Vinícius Leitempergher     |
| [#65](https://github.com/notat-scrum/notat/issues/65) | Preencher a seção da entrega N3 no README                       | entrega                         | 3      | Must   | O README é o documento avaliado                                                                      | Vinícius Bueno de Oliveira |

A Sprint 3 compromete 16 pontos.

#### Definition of Done

Uma issue só está pronta quando:

- o comportamento que ela muda tem teste automatizado escrito antes da mudança: numa correção, o teste
  falha antes e passa depois; numa refatoração, o teste de regressão passa antes e depois, sem
  alteração;
- o que os arquivos tocados fazem e ainda não tinha teste ganhou teste no mesmo PR;
- os critérios de aceite da história que ela atende foram conferidos, e o que depende do aparelho tem
  print no PR;
- o que já funcionava na N1 e na N2 continua funcionando: o `fvm flutter test` inteiro passa;
- `fvm dart format .`, `fvm flutter analyze --fatal-infos`, `fvm dart analyze` e `fvm flutter test`
  passam, e o CI está verde;
- o PR foi revisado e aprovado por um colega, com os comentários da revisão no próprio PR;
- está mergeada na `master`, a issue fechou e o card está em Pronto no quadro.

A US03 está pronta quando todas as issues dela estão.

#### Papéis

| Papel         | Integrante                                                     |
| ------------- | -------------------------------------------------------------- |
| Product Owner | Vinícius Bueno de Oliveira                                     |
| Scrum Master  | Vinicius Pedroso Schoeffel                                     |
| Dev           | Eduardo Hoeft, Vinícius Leitempergher, Vinícius Bonatti Benner |

O PO e o SM também revisam os PRs.

### Item de reuso

Padrão escolhido: Adapter, na [#64](https://github.com/notat-scrum/notat/issues/64). Os erros do
Firebase Auth e do Firestore chegam ao app em formatos diferentes. Cada origem ganha um adapter que
converte o erro do SDK para a mensagem que o app mostra. O teste de regressão são os três testes de
`test/utils/auth_errors_test.dart`, que passam antes e depois da mudança.

Onde foi aplicado e o teste que protege: _a preencher depois do merge._

### Prints

Votação do Planning Poker: _a preencher._

Resultado do `flutter test`: _a preencher._

### Resultado

_A preencher na entrega:_ se o Sprint Goal foi atingido, o que ficou de fora e por quê, e o link do
vídeo.

## Pré-requisitos

| Ferramenta     | Versão          | Para quê                                |
| -------------- | --------------- | --------------------------------------- |
| Git            | qualquer        | clonar                                  |
| fvm            | 4.x             | instalar e fixar o Flutter              |
| Flutter        | 3.47.2          | fixado no `.fvmrc`, o fvm baixa sozinho |
| Android Studio | atual           | SDK, emulador e drivers                 |
| Android SDK    | API 24 ou maior | `minSdk` do app é 24                    |
| JDK            | 17              | build do Gradle                         |
| JDK            | 21              | só para os emuladores do Firebase       |
| Node           | 18 ou maior     | só para os emuladores do Firebase       |

Não é preciso criar projeto no Firebase. O `google-services.json` e o `firebase_options.dart` estão
versionados e apontam para o projeto `notatmelhoria`. Eles não são segredo: são identificadores
públicos, e quem controla o acesso são as Security Rules em `firestore.rules`.

## Instalação

### 1. Git

Linux: `sudo apt install git`. macOS: `xcode-select --install`. Windows:
[git-scm.com](https://git-scm.com/download/win).

### 2. fvm

Linux e macOS:

```
curl -fsSL https://fvm.app/install.sh | bash
```

Windows, no PowerShell:

```
choco install fvm
```

Confira com `fvm --version`.

### 3. Flutter

Dentro do repositório clonado, o fvm lê o `.fvmrc` e baixa a versão certa:

```
git clone https://github.com/notat-scrum/notat.git
cd notat
fvm install
fvm flutter --version
```

A saída tem que dizer `3.47.2`. Daqui em diante, todo comando do Flutter vai por `fvm flutter`, nunca
por `flutter` direto, senão você usa a versão da sua máquina em vez da do projeto.

### 4. Android Studio, SDK e JDK

Instale o [Android Studio](https://developer.android.com/studio). No SDK Manager, marque o
**Android SDK Platform 36**, o **Android SDK Command-line Tools** e o **Android SDK Platform-Tools**.

O Gradle precisa do JDK 17. O Android Studio já traz um, e o Flutter o encontra sozinho na maioria dos
casos. Se não encontrar, instale o Temurin 17 e aponte:

```
fvm flutter config --jdk-dir /caminho/para/jdk-17
```

Aceite as licenças do SDK:

```
fvm flutter doctor --android-licenses
```

E confira o resto:

```
fvm flutter doctor
```

### 5. Rodar

Com um emulador aberto ou um aparelho conectado por USB com depuração ligada:

```
fvm flutter pub get
fvm flutter run
```

Para criar um emulador pelo terminal, liste os que existem com `fvm flutter emulators` e suba com
`fvm flutter emulators --launch <id>`.

## Desenvolvimento

```
fvm flutter analyze --fatal-infos
fvm dart analyze
fvm flutter test
fvm dart format .
```

Os dois `analyze` não são redundantes. O `riverpod_lint` entra pelo `analysis_server_plugin`, que o
`flutter analyze` não carrega e o `dart analyze` carrega. O CI roda os dois.

Cobertura:

```
fvm flutter test --coverage
```

O CI publica o percentual como comentário no PR. Ele conta apenas os arquivos que algum teste
importa, então telas e widgets sem teste nem entram no denominador.

## Firebase local

Por padrão o app fala com o projeto `notatmelhoria` na nuvem. Para desenvolver contra emuladores
locais, sem tocar nos dados reais:

```
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 firebase emulators:start
fvm flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

O painel fica em `http://localhost:4000`. O Auth emulado não envia e-mail de verdade: o link de
verificação aparece no log do `firebase emulators:start` e na aba Logs do painel.

Os emuladores exigem JDK 21, enquanto o Gradle usa o 17. Por isso a variável vai na frente do comando,
em vez de trocar o padrão da máquina. No Linux, `sudo apt install openjdk-21-jdk-headless`.

Em aparelho físico o endereço `10.0.2.2` não resolve. Passe o IP da máquina na rede e acrescente esse
mesmo IP em `android/app/src/debug/res/xml/network_security_config.xml`, senão o Android bloqueia a
conexão por ser texto claro:

```
fvm flutter run --dart-define=USE_FIREBASE_EMULATOR=true --dart-define=FIREBASE_EMULATOR_HOST=192.168.0.10
```

Essa liberação existe só no source set de debug. O build de release continua exigindo HTTPS.

## Regras de segurança

`firestore.rules` e `firestore.indexes.json` são a fonte de verdade. Depois de mudar, publique:

```
firebase deploy --only firestore:rules,firestore:indexes
```

## Build de release

Sem o `android/key.properties`, o APK de release sai sem assinatura. É proposital: antes, o build
assinava com a chave de debug e gerava um APK que parecia publicável.

## Contribuindo

O fluxo de branch, commit, PR e quadro está em [CONTRIBUTING.md](CONTRIBUTING.md).

## Licença

MIT. Ver [License.txt](License.txt).
