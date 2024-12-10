import 'dart:math';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cryption {

  //Generating a random val to create a random key
  static String generateVal(){
    final rand = Random.secure();
    //Choosing a 16 bit key for AES, something secure is nice, but the app itself should still be quick.
    final vals = List<int>.generate(16, (i) => rand.nextInt(256));
    return base64UrlEncode(vals);
  }
  //Generating the key itself
  static final key = Key.fromUtf8(generateVal());
  //IV is another random value to introduce more random elements to the encryption, this makes finding paterns even more ridiculously complex ;)
  static final iv = IV.fromLength(16);

  //using Cipher Block Chaining, as each block is dependent on the next and if anything is slightly off, nothing can be recovered.
  static String encrypt(String text){
    return Encrypter(AES(key, mode: AESMode.cbc)).encrypt(text, iv: iv).base64;
  }

  static String decrypt(String text){
    return Encrypter(AES(key, mode: AESMode.cbc)).decrypt64(text, iv: iv);
  }

  //Save Locally~
  Future<void> saveNoteLocal(String noteId, String note) async{
    final encryptedNote = encrypt(note);
    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString(noteId, encryptedNote);
  }

  Future<String?> fetchNoteLocal(String noteId) async{
    final sharedPref = await SharedPreferences.getInstance();
    final encryptedNote = sharedPref.getString(noteId);
    if(encryptedNote != null) {
      return decrypt(encryptedNote);
    }
    return null;
  }

  //Save on the DB~
  Future<void> saveNoteFB(String userId, String noteId, String note) async {
    final encryptedNote = encrypt(note);
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('notes')
      .doc(noteId)
      .set({'content': encryptedNote});
  }

  Future<String?> fetchNoteFB(String userId, String noteId) async {
    final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('notes')
    .doc(noteId)
    .get();

    if(doc.exists) {
      final encryptedNote = doc.get('content');
      return decrypt(encryptedNote);
    }
    return null;
  }
}
