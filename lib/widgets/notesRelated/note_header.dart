import 'package:flutter/material.dart';
import 'package:notat/widgets/foldersRelated/folder_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';

class NoteHeader extends StatelessWidget {
  const NoteHeader({
    super.key,
    required this._titleController,
    this.editNoteMod = false,
    required this.selected,
    required this.snapshot,
  });

  final TextEditingController _titleController;
  final ValueNotifier<String?> selected;
  final dynamic snapshot;
  final bool editNoteMod;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        TextFormField(
          controller: _titleController,
          minLines: 1,
          autofocus: editNoteMod ? false : true,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.ubuntu(
            textStyle: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          decoration: InputDecoration(
            fillColor: Theme.of(context).primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            border: InputBorder.none,
            hintText: 'Title',
          ),
        ),
        SizedBox(
          height: 45,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  snapshot == null
                      ? 'Date: ${Jiffy.parseFromDateTime(DateTime.now()).yMMMEdjm} |'
                      : 'Last update: ${Jiffy.parseFromDateTime(snapshot['date'].toDate()).yMMMEdjm} |',
                  style: GoogleFonts.ubuntu(
                    fontSize: 14,
                    color: Colors.white30,
                  ),
                ),
              ),
              FolderMenu(selected: selected),
            ],
          ),
        ),
      ],
    );
  }
}
