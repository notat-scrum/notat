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
