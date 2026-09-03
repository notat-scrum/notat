import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notat/resources/firestore_methods.dart';
import 'package:notat/utils/auth_errors.dart';
import 'package:notat/resources/firstore_folder_methods.dart';

class AuthService {
  AuthService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? get currentUid => _auth.currentUser?.uid;

  /// Devolve null quando a conta e criada. Qualquer string e mensagem de erro.
  Future<String?> createUser({
    required String email,
    required String password,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // o uid vem da credencial recem-criada, nao de currentUser, que ainda
      // pode nao ter propagado
      await FirestoreFolderService(
        _firestore,
        credencial.user!.uid,
      ).createMainFolder();
      return null;
    } on FirebaseException catch (e) {
      return traduzErroDeAuth(e);
    }
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    String? feedback;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (e) {
      feedback = traduzErroDeAuth(e);
    }
    return feedback;
  }

  Future<String?> restPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      return traduzErroDeAuth(e);
    }
    return null;
  }

  Future<String?> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      return traduzErroDeAuth(e);
    }
    return null;
  }

  Future<String?> deleteAccount() async {
    final usuario = _auth.currentUser;
    if (usuario == null) {
      return 'Nenhum usuário conectado.';
    }
    try {
      await FirestoreService(_firestore, usuario.uid).deleteAllDocs();
      await usuario.delete();
    } on FirebaseException catch (e) {
      return traduzErroDeAuth(e);
    }
    return null;
  }

  Future<String?> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } on FirebaseException catch (e) {
      return traduzErroDeAuth(e);
    }
    return null;
  }

  Future<String?> reauthentication(String password) async {
    final usuario = _auth.currentUser;
    if (usuario?.email == null) {
      return 'Nenhum usuário conectado.';
    }
    try {
      final credencial = EmailAuthProvider.credential(
        email: usuario!.email!,
        password: password,
      );
      await usuario.reauthenticateWithCredential(credencial);
    } on FirebaseException catch (e) {
      return traduzErroDeAuth(e);
    }
    return null;
  }

  Future<void> sendEmailVerification() =>
      _auth.currentUser?.sendEmailVerification() ?? Future.value();

  bool get isVerified => _auth.currentUser?.emailVerified ?? false;
}
