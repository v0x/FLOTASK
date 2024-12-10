import 'package:flutter/foundation.dart';
import 'cryption.dart';
import 'dart:math';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await testFB();
  await testLocal();
}

//Creating classes for the dum dums

class User {
  final String userId;
  final String name;
  User({required this.userId, required this.name});
}

class Note {
  final String noteId;
  final String userId; //Important for FireBase Storage
  final String note; //not to be confused for the class, this is the note, the text/message itself

  Note({required this.noteId, required this.userId, required this.note});
}

//Creating the dummies themselves~

int numberOfUsers = 2;
int notesPerUser = 2;

class UserDumDums{
  int num = numberOfUsers;
  static List<User> generateUsers(num) {
    return List<User>.generate(num, (index){
      return User(userId: 'user_$index', name: 'User #$index');
    });
  }
}

List<Note> generateNotes(){
  final List<Note> notes = [];
  for (int i=0; i<numberOfUsers; i++){
    for (int j=0; j<notesPerUser; j++) {
      notes.add(Note(noteId: 'note_${i}_${j}', userId: 'user_$i', note: 'Note $j created by User $i',));
    }
  }
  return notes;
}

//Save all the notes to Local
Future<void> testLocal() async {
  print('LOCAL TESTING');
  print('-----------------------------');
  print('Saving Notes Locally...');
  print('-----------------------------');
  for (Note note in generateNotes()){
    //Cryption().saveNoteLocal(note.noteId, note.note);
    final encryptedNote = Cryption.encrypt(note.note);
    print('NoteID: ${note.noteId}, Note: ${note.note}, Encrypted: ${encryptedNote}');
    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString(note.noteId, encryptedNote);
  }
  print('-----------------------------');
  print('Fetching Notes Locally...');
  print('-----------------------------');
  for (Note note in generateNotes()){
    //Cryption().fetchNoteLocal(note.noteId);
    final sharedPref = await SharedPreferences.getInstance();
    final encryptedNote = sharedPref.getString(note.noteId);
    if(encryptedNote != null) {
      final decryptedNote =  Cryption.decrypt(encryptedNote);
      print('NoteID: ${note.noteId}, Note: ${note.note}, Decrypted: ${decryptedNote}');
    }
    print('<!> Nothing found for NoteID: ${note.noteId}');
  }
  print('-----------------------------');
  print('Local Testing Complete...');
  print('-----------------------------');
}

Future<void> testFB() async{
  print('FIREBASE TESTING...');
  print('-----------------------------');
  print('Saving Notes To FireBase...');
  print('-----------------------------');
  for (Note note in generateNotes()){
    //Cryption().saveNoteFB(note.userId, note.noteId, note.note);
    final encryptedNote = Cryption.encrypt(note.note);
    await FirebaseFirestore.instance
      .collection('users')
      .doc(note.userId)
      .collection('notes')
      .doc(note.noteId)
      .set({'content': encryptedNote});
  }
  print('-----------------------------');
  print('Fetching Notes From FireBase...');
  print('-----------------------------');
  for (Note note in generateNotes()){
    //Cryption().fetchNoteFB(note.userId, note.noteId);
    final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(note.userId)
    .collection('notes')
    .doc(note.noteId)
    .get();

    if(doc.exists) {
      final encryptedNote = doc.get('content');
      final decryptedNote = Cryption.decrypt(encryptedNote);
      print('NoteID: ${note.noteId}, Note: ${note.note}, Fetched Encrypted Note: ${encryptedNote}, Decrypted: ${decryptedNote}');
    }
    print('<!> Nothing found for NoteID: ${note.noteId}');
  }

  print('-----------------------------');
  print('FireBase Testing Complete...');
  print('-----------------------------');
}

