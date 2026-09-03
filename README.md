
# Getting Started
This project is a starting point for a Flutter application.
A few resources to get you started if this is your first Flutter project:
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, and guidance on mobile development
# Notat
 Notat is a simple note-taking app with a markdown editor and clean interface, it features: 
* creating, editing, and deleting notes
* markdown editor that allows making highly customizable notes
* organizing notes in folders and more
## Screenshots
<a href="https://ibb.co/3v31xpN"><img src="https://i.ibb.co/xYkhn1j/1-20221019-151648-0000.png" alt="1-20221019-151648-0000" border="0"></a>
<a href="https://ibb.co/TKgqFSC"><img src="https://i.ibb.co/q0rFPfZ/5-20221019-151648-0004.png" alt="5-20221019-151648-0004" border="0"></a>
<a href="https://ibb.co/gVPS1Lx"><img src="https://i.ibb.co/fvnkRzs/2-20221019-151648-0001.png" alt="2-20221019-151648-0001" border="0"></a>
<a href="https://ibb.co/Tkx1jsn"><img src="https://i.ibb.co/nbNBdFV/4-20221019-151648-0003.png" alt="4-20221019-151648-0003" border="0"></a>
<a href="https://ibb.co/ZT8cxWs"><img src="https://i.ibb.co/GP2CRcw/3-20221019-151648-0002.png" alt="3-20221019-151648-0002" border="0"></a>
## Planned features 🌱
* data encryption
* locking notes
* creating and editing notes offline[1]
##### [1] due to a bug caused by firebase firestore, users are only able to create and edit notes online, [for more info](https://community.flutterflow.io/c/discuss-and-get-help/navigate-action-not-working-if-device-offline)

## Used Packages List:
<details>
<summary>Expand</summary>


firebase_messaging: ^12.0.1 

uuid: ^3.0.6 

flutter_staggered_grid_view: ^0.6.2 

auto_size_text: ^3.0.0 

tab_indicator_styler: ^2.0.0 

flutter_quill: ^5.4.1 

loading_animation_widget: ^1.2.0+2 

google_fonts: ^3.0.1 

animated_text_kit: ^4.2.2

lottie: ^1.4.1

custom_timer: ^0.1.2

jiffy: ^5.0.0

focused_menu: ^1.0.5 

flutter_riverpod: ^1.0.4 

connectivity_plus: ^2.3.9 

flutter_launcher_icons: ^0.9.2 

flutter_native_splash: ^2.0.1+1 

firebase_storage: ^10.3.4 

cloud_firestore: ^3.4.2

firebase_auth: ^3.6.1 

firebase_core: ^1.20.0 

</details>

## Usage
* clone the project
```
https://github.com/Dev-Salem/notat.git
```
* Create a new Firebase project from the [console](https://console.firebase.google.com/).
* Configure the Firebase for each platform.
## Desenvolvimento

O projeto usa uma versao fixa do Flutter, declarada em `.fvmrc`. Rode sempre por `fvm`:

```
fvm flutter pub get
fvm flutter analyze --fatal-infos
fvm flutter test
```

### Firebase local

Por padrao o app fala com o projeto `notatmelhoria` na nuvem. Para desenvolver contra
emuladores locais, sem sujar os dados reais:

```
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 firebase emulators:start
fvm flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

Os emuladores exigem JDK 21 ou superior (`sudo apt install openjdk-21-jdk-headless`). O
`JAVA_HOME` do projeto aponta para o 17, que e o que o Gradle usa, por isso a variavel vai
na frente do comando em vez de trocar o padrao da maquina.

O painel dos emuladores fica em `http://localhost:4000`. O Auth emulado nao envia e-mail de
verdade: o link de verificacao aparece no log do `firebase emulators:start`.

Em aparelho fisico, `10.0.2.2` nao resolve. Passe o IP da maquina na rede local:

```
fvm flutter run --dart-define=USE_FIREBASE_EMULATOR=true --dart-define=FIREBASE_EMULATOR_HOST=192.168.0.10
```

### Regras de seguranca

`firestore.rules` e `firestore.indexes.json` sao a fonte de verdade. Depois de mudar,
publique com:

```
firebase deploy --only firestore:rules,firestore:indexes
```

## Installation
Notat isn't available on the app store yet, but you can try it by installing the apk from [here](https://www.mediafire.com/file/wuhhrx7jiali3pc/notat+v2.apk/file)
## Contributing
You can contribute by reporting bugs, suggesting improvements, and/or by helping out in code.
## License
[MIT](https://choosealicense.com/licenses/mit/)
## Acknowledgement
Special thanks for these designers for inspiring me [1](https://dribbble.com/shots/11875872-A-simple-and-lightweight-note-app), [2](https://dribbble.com/shots/14995291--Notes-App-Dark-Mode)
