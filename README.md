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

Vídeo da demonstração: _a preencher._

### Sprint Goal

Excluir uma pasta e escrever uma nota sem internet não deixam mais nota fantasma, duplicada ou perdida
sem aviso, e cada um desses comportamentos fica provado por teste automatizado e revisado em PR.

### Histórias de usuário da Sprint 2

A fala da cliente para o Sprint 2:

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

Parte do que a cliente pediu já tinha sido resolvido na Sprint 1, e entra no backlog como pronto.

O sintoma da US01 vinha do código herdado. Ao excluir uma pasta, o app disparava a exclusão das notas
sem esperar por ela e apagava uma nota de cada vez. O método avisava que tinha terminado antes de apagar
qualquer coisa, e a lista ia esvaziando aos poucos. A [#27](https://github.com/notat-scrum/notat/issues/27)
passou a apagar tudo num lote só e a esperar o lote terminar, e a
[#25](https://github.com/notat-scrum/notat/issues/25) deixou a pasta só no campo `folderId` da nota. Os
critérios 1, 2 e 5 da US01 já são cobertos pelos testes `excluir a pasta leva junto as notas de dentro`
e `limpar as notas preserva as pastas`. Sem internet, a pasta vazia ainda fica na tela até a conexão
voltar, e o erro da exclusão não aparece para o usuário: são os critérios 3 e 4, que ficaram para a
Sprint 2.

A gravação sem internet da US02 entrou na [#28](https://github.com/notat-scrum/notat/issues/28). Os
critérios 1 a 3 funcionam, mas nenhum teste prova isso. O critério 4 é um bug encontrado na
investigação: quando o servidor recusa a gravação, a nota some sem aviso.

### Backlog da Sprint 2

Estimativas em pontos de Planning Poker, na sequência de Fibonacci.

| Item                                                          | Origem            | Issue                                                 | Pontos | MoSCoW | Justificativa                                                                                         | Estado                  |
| ------------------------------------------------------------- | ----------------- | ----------------------------------------------------- | ------ | ------ | ----------------------------------------------------------------------------------------------------- | ----------------------- |
| US01, critérios 1, 2 e 5: excluir pasta apaga tudo de uma vez | pedido da cliente | [#27](https://github.com/notat-scrum/notat/issues/27) | 5      | Must   | É a fala da cliente na Sprint 2                                                                       | pronto, adiantado na N1 |
| Desfazer a dependência circular entre os serviços             | code smell        | [#46](https://github.com/notat-scrum/notat/issues/46) | 3      | Must   | Smell do catálogo, e pré-requisito da #47                                                             |                         |
| US01, critério 3: excluir pasta sem internet                  | pedido da cliente | [#47](https://github.com/notat-scrum/notat/issues/47) | 5      | Must   | Sem isso a pasta vazia continua na tela, que é o sintoma relatado                                     |                         |
| US02: provar a sincronização offline e avisar a falha         | pendência da N1   | [#48](https://github.com/notat-scrum/notat/issues/48) | 5      | Must   | A professora pediu prova de que a nota sobe uma vez só, e a falha hoje passa em silêncio              |                         |
| Extrair a montagem da nota repetida                           | code smell        | [#49](https://github.com/notat-scrum/notat/issues/49) | 2      | Should | Quarto smell do catálogo. O mínimo de três já está coberto pela #46, #48 e #50                        |                         |
| Centralizar o caminho das coleções do usuário                 | code smell        | [#50](https://github.com/notat-scrum/notat/issues/50) | 3      | Must   | Smell do catálogo, e põe sob teste os três providers que hoje não têm nenhum                          |                         |
| US01, critério 4: mostrar o erro da exclusão                  | pedido da cliente | [#51](https://github.com/notat-scrum/notat/issues/51) | 3      | Must   | Critério de aceite da US01, e o primeiro teste de widget do projeto                                   |                         |
| Preencher a seção da entrega N2 no README                     | entrega           | [#52](https://github.com/notat-scrum/notat/issues/52) | 2      | Must   | O README é o documento avaliado                                                                       |                         |
| Regras do Firestore exigirem e-mail verificado                | validação da N1   | sem issue                                             | 3      | Could  | Hoje só a tela barra quem não verificou o e-mail. Fica para depois porque não foi pedido nesta sprint |                         |
| Abrir a verificação de e-mail já no cadastro                  | validação da N1   | sem issue                                             | 2      | Won't  | Muda o fluxo de cadastro, e é decisão de produto que não entra nesta sprint                           |                         |

A Sprint 2 compromete 23 pontos, das issues #46 a #52.

### Papéis e issues da Sprint 2

| Papel             | Integrante                                                        |
| ----------------- | ----------------------------------------------------------------- |
| Product Owner     | Vinícius Bonatti Benner                                           |
| Scrum Master      | _a preencher_                                                     |
| Revisão de código | Vinícius Bueno de Oliveira                                        |
| Dev               | Eduardo Hoeft, Vinícius Leitempergher, Vinicius Pedroso Schoeffel |

#### [Marco 4: Sprint 2](https://github.com/notat-scrum/notat/milestone/4)

As issues de código foram sorteadas em pares. Cada par toca os mesmos arquivos, para que dois PRs
abertos ao mesmo tempo não entrem em conflito.

| Issue                                                 | O que muda                                                          | Responsável                |
| ----------------------------------------------------- | ------------------------------------------------------------------- | -------------------------- |
| [#46](https://github.com/notat-scrum/notat/issues/46) | Dependência circular entre os serviços do Firestore desfeita        | Eduardo Hoeft              |
| [#47](https://github.com/notat-scrum/notat/issues/47) | Pasta e notas excluídas de uma vez, mesmo sem internet              | Eduardo Hoeft              |
| [#48](https://github.com/notat-scrum/notat/issues/48) | Sincronização offline provada por teste e falha de gravação avisada | Vinícius Leitempergher     |
| [#49](https://github.com/notat-scrum/notat/issues/49) | Montagem da nota extraída para um lugar só                          | Vinícius Leitempergher     |
| [#50](https://github.com/notat-scrum/notat/issues/50) | Caminho das coleções do usuário centralizado                        | Vinicius Pedroso Schoeffel |
| [#51](https://github.com/notat-scrum/notat/issues/51) | Erro da exclusão mostrado ao usuário                                | Vinicius Pedroso Schoeffel |
| [#52](https://github.com/notat-scrum/notat/issues/52) | Seção da entrega N2 no README preenchida                            | Vinícius Bueno de Oliveira |

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

| Smell                                                                | Onde está                                                                                                        | Refatoração aplicada | Teste de regressão | Tipo            |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | -------------------- | ------------------ | --------------- |
| Dependência circular entre os serviços                               | `lib/resources/firestore_methods.dart`, construtor; `lib/resources/firstore_folder_methods.dart`, `deleteFolder` | _a preencher_        | _a preencher_      | refatoração     |
| `try/catch` que nunca captura, em volta de um `Future` não aguardado | `lib/resources/firestore_methods.dart`, `addDocument` e `updateDocument`                                         | _a preencher_        | _a preencher_      | correção de bug |
| Código duplicado na montagem da nota                                 | `lib/resources/firestore_methods.dart`, `addDocument` e `updateDocument`                                         | _a preencher_        | _a preencher_      | refatoração     |
| Caminho das coleções repetido em cinco lugares                       | `lib/providers/note_provider.dart`, `lib/providers/folders_provider.dart`, `lib/resources/`                      | _a preencher_        | _a preencher_      | refatoração     |

### Pull requests e CI

Pipeline: [CI no GitHub Actions](https://github.com/notat-scrum/notat/actions/workflows/ci.yml), que
roda formatação, `flutter analyze`, `dart analyze` e `flutter test` a cada push na `master` e a cada PR.
Os comandos para rodar os testes localmente estão em [Desenvolvimento](#desenvolvimento).

| PR  | O que entrega | Revisão |
| --- | ------------- | ------- |
|     |               |         |

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
