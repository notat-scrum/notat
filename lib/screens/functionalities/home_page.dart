import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/screens/authentication/introduction_screen.dart';
import 'package:notat/screens/functionalities/create_note.dart';
import 'package:notat/widgets/delete_account_dialog.dart';
import 'package:notat/widgets/reusedComponents/animation_transition.dart';
import 'package:notat/widgets/foldersRelated/folders._tab.dart';
import 'package:notat/widgets/notesRelated/notes_tab.dart';
import 'package:notat/widgets/reusedComponents/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 15, bottom: 15),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                FadeTrans(
                  translateTo: const CreateNote(),
                  duration: Duration(milliseconds: 800),
                ),
              );
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add_outlined, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 35, right: 20),
                  child: Text(
                    "Notat",
                    style: GoogleFonts.philosopher(fontSize: 30),
                  ),
                ),
                const Expanded(child: SizedBox()),
                PopupMenuButton(
                  itemBuilder: ((context) => [
                    PopupMenuItem(
                      onTap: () async {
                        await ref
                            .read(firestoreServiceProvider)
                            .clearAllNotes();
                      },
                      value: 1,
                      child: const Text('Clear All notes'),
                    ),
                    PopupMenuItem(
                      onTap: () async {
                        final auth = ref.read(authServiceProvider);
                        await auth.reloadUser();
                        final erro = await auth.signOut();
                        if (!context.mounted) return;
                        if (erro != null) {
                          CustomSnackBar.show(
                            context,
                            erro,
                            Duration(seconds: 2),
                          );
                        }
                        FadeTrans(translateTo: IntroductionScreen());
                      },
                      value: 2,
                      child: const Text('Sign out'),
                    ),
                    PopupMenuItem(
                      onTap: () async {
                        Future.delayed(
                          Duration(seconds: 0),
                          (() => showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return const DeleteAccountDialog();
                            },
                          )),
                        );
                      },
                      value: 3,
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15, left: 5),
                    child: Icon(
                      Icons.more_horiz_outlined,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            TabBar(
              //isScrollable: true,
              //labelColor: Colors.white,

              unselectedLabelColor: Colors.white54,
              controller: _tabController,
              splashFactory: NoSplash.splashFactory,

              tabs: [
                Tab(
                  child: Text(
                    'All',
                    style: GoogleFonts.roboto(
                      letterSpacing: 1,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Folder',
                    style: GoogleFonts.roboto(
                      letterSpacing: 1,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 4,
                  color: Theme.of(context).tabBarTheme.labelColor!,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 75),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [NotesTab(), FoldersTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
