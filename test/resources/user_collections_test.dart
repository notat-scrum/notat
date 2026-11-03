import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/resources/user_collections.dart';

void main() {
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
  });

  test('notesOf aponta para users/{uid}/notes', () {
    expect(db.notesOf('u1').path, 'users/u1/notes');
  });

  test('foldersOf aponta para users/{uid}/folders', () {
    expect(db.foldersOf('u1').path, 'users/u1/folders');
  });

  test('cada usuario tem as suas proprias colecoes', () async {
    await db.notesOf('u1').doc('a').set({'title': 'De u1'});
    await db.notesOf('u2').doc('b').set({'title': 'De u2'});

    final doUm = await db.notesOf('u1').get();

    expect(doUm.docs.map((d) => d.data()['title']), ['De u1']);
  });
}
