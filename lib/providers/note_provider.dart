import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/models/note.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/providers/user_collections_provider.dart';

final notesProvider = StreamProvider<List<Note>>(
  (ref) => watchUserNotes<Note>(
    ref,
    (notes) => notes.orderBy('date', descending: true),
    Note.fromFirestore,
  ),
);

final notesInFolderProvider = StreamProvider.family<List<Note>, String>(
  (ref, folder) => watchUserNotes<Note>(
    ref,
    (notes) => notes.where('folderId', isEqualTo: folder),
    Note.fromFirestore,
  ),
);

// autoDispose: sem ele a primeira leitura fica guardada enquanto o app estiver
// aberto, e a tela de edicao reabre a nota na versao anterior
final noteProvider = StreamProvider.autoDispose.family<Note?, String>(
  (ref, uid) => ref.watch(firestoreServiceProvider).watchNote(uid: uid),
);
