import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notat/resources/user_collections.dart';

class FirestoreFolderService {
  FirestoreFolderService(this._firestore, this.userUid);

  final FirebaseFirestore _firestore;
  final String userUid;

  /// O id do documento e o proprio nome da pasta, que e o que as notas guardam
  /// em folderId. Por isso o nome nao pode conter barra: ela dividiria o
  /// caminho no Firestore.
  CollectionReference<Map<String, dynamic>> get folders =>
      _firestore.foldersOf(userUid);

  CollectionReference<Map<String, dynamic>> get _notes =>
      _firestore.notesOf(userUid);

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
      final notasDaPasta = await _notes
          .where('folderId', isEqualTo: name)
          .get(const GetOptions(source: Source.cache));

      final lote = _firestore.batch();
      lote.delete(folders.doc(name));
      for (final doc in notasDaPasta.docs) {
        lote.delete(doc.reference);
      }
      await lote.commit();
    } on FirebaseException catch (e) {
      return e.message;
    }
    return null;
  }
}
