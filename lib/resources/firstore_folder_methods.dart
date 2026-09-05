import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notat/resources/firestore_methods.dart';

class FirestoreFolderService {
  FirestoreFolderService(this._firestore, this.userUid);

  final FirebaseFirestore _firestore;
  final String userUid;

  /// O id do documento e o proprio nome da pasta, que e o que as notas guardam
  /// em folderId. Por isso o nome nao pode conter barra: ela dividiria o
  /// caminho no Firestore.
  CollectionReference<Map<String, dynamic>> get folders =>
      _firestore.collection('users').doc(userUid).collection('folders');

  static bool nomeValido(String name) =>
      name.isNotEmpty && !name.contains('/') && name.trim() == name;

  Future<String?> createMainFolder() => createFolder('All');

  Future<String?> createFolder(String name) async {
    if (!nomeValido(name)) {
      return 'Invalid folder name';
    }
    try {
      await folders.doc(name).set({'name': name, 'createdAt': Timestamp.now()});
    } on FirebaseException catch (e) {
      return e.message;
    }
    return null;
  }

  Future<String?> deleteFolder(String name) async {
    if (name == 'All') {
      return null;
    }
    try {
      await FirestoreService(_firestore, userUid).deleteDocsOfFolder(name);
      await folders.doc(name).delete();
    } on FirebaseException catch (e) {
      return e.message;
    }
    return null;
  }
}
