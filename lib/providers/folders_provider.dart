import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/user_collections_provider.dart';

/// Os nomes das pastas do usuario. O id de cada documento e o proprio nome, que
/// e o que a nota guarda em folderId.
final folderProvider = StreamProvider<List<String>>(
  (ref) => watchUserFolders<String>(
    ref,
    (folders) => folders.orderBy('createdAt'),
    (doc) => doc.id,
  ),
);
