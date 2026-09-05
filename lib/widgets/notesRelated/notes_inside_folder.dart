import 'package:flutter/material.dart';
import 'package:notat/providers/note_provider.dart';
import 'package:notat/widgets/notesRelated/note_cards.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<dynamic> foldersBottomSheet(BuildContext context, String folder) {
  return showModalBottomSheet<dynamic>(
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(150)),
    ),
    context: context,
    builder: (BuildContext _) => InsideFolder(folder),
  );
}

class InsideFolder extends ConsumerWidget {
  final String folder;
  const InsideFolder(this.folder, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(45),
          topRight: Radius.circular(45),
        ),
      ),
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
        child: NoteCards(ref.watch(notesInFolderProvider(folder))),
      ),
    );
  }
}
