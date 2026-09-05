# Notat

Aplicativo de notas em Flutter, com editor rich text e organização em pastas. Roda em Android.

Este repositório é um fork de [Dev-Salem/notat](https://github.com/Dev-Salem/notat), sob licença MIT.
O código original é de [@Dev-Salem](https://github.com/Dev-Salem); o texto da licença e o aviso de
copyright estão em [License.txt](License.txt).

## O que o app faz

Criar, editar e excluir notas com formatação, organizar notas em pastas, buscar por título e
conteúdo. Contas por e-mail e senha, com verificação de e-mail. Os dados ficam no Firestore, um
documento por nota, sob o usuário dono.

## Requisitos

| Ferramenta | Versão | Para quê |
|---|---|---|
| Git | qualquer | clonar |
| fvm | 4.x | instalar e fixar o Flutter |
| Flutter | 3.47.2 | fixado no `.fvmrc`, o fvm baixa sozinho |
| Android Studio | atual | SDK, emulador e drivers |
| Android SDK | API 24 ou maior | `minSdk` do app é 24 |
| JDK | 17 | build do Gradle |
| JDK | 21 | só para os emuladores do Firebase |
| Node | 18 ou maior | só para os emuladores do Firebase |

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
