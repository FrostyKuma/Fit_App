import 'dart:typed_data';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:fit_app/models/user_model.dart';
import 'package:fit_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserProvider() {
    _loadUser();
  }

  Future<String> uploadImageToStorage(
      String ChildName, Uint8List file, String nameForTheUser) async {
    print('Username for file: $nameForTheUser');
    Reference ref =
        _storage.ref().child(ChildName).child('ImageOf$nameForTheUser');
    UploadTask uploadTask = ref.putData(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
    }, onError: (error) {
      print('Error during upload: $error');
    });

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    print('Download URL: $downloadUrl');
    return downloadUrl;
  }

  Future<String> saveData(Uint8List file, String NameOfTheUser) async {
    String resp = "Some error occurred";
    try {
      String imageUrl =
          await uploadImageToStorage('ProfileImage', file, NameOfTheUser);

      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'profileImageUrl': imageUrl,
        });
      }

      resp = 'success';
      return imageUrl;
    } catch (err) {
      resp = err.toString();
      print("Error uploading image: $err");
      return resp;
    }
  }

  Future<void> _loadUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      _user = UserModel.fromMap(
          doc.data() as Map<String, dynamic>, currentUser.uid);
      notifyListeners();

      // Set up a listener for the user's document
      _firestore
          .collection('users')
          .doc(currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          _user = UserModel.fromMap(
              snapshot.data() as Map<String, dynamic>, currentUser.uid);
          notifyListeners();
        }
      });
    }
  }

  Future<void> updateUser(UserModel user) async {
    _user = user;
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> refreshUser() async {
    await _loadUser();
  }

  Future<void> saveMessage(
      String message, String role, String recipientId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('messages')
          .add({
        'role': role,
        'content': message,
        'timestamp': FieldValue.serverTimestamp(),
        'recipientId': recipientId,
      });

      await _firestore
          .collection('users')
          .doc(recipientId)
          .collection('assistants')
          .doc(currentUser.uid)
          .collection('messages')
          .add({
        'role': role,
        'content': message,
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': currentUser.uid,
      });
    }
  }

  Stream<QuerySnapshot> getMessageStream(String recipientId) {
    User? currentUser = _auth.currentUser;
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<List<Map<String, String>>> loadMessages(String recipientId) async {
    List<Map<String, String>> messages = [];
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      QuerySnapshot senderSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('messages')
          .orderBy('timestamp')
          .get();
      for (var doc in senderSnapshot.docs) {
        messages.add({
          'role': doc['role'],
          'content': doc['content'],
        });
      }

      QuerySnapshot recipientSnapshot = await _firestore
          .collection('users')
          .doc(recipientId)
          .collection('assistants')
          .doc(currentUser.uid)
          .collection('messages')
          .orderBy('timestamp')
          .get();
      for (var doc in recipientSnapshot.docs) {
        messages.add({
          'role': doc['role'],
          'content': doc['content'],
        });
      }

      final seen = <String>{};
      messages = messages.where((msg) => seen.add(msg['content']!)).toList();
    }
    return messages;
  }
}

class UserModel {
  final String uid;
  final String username;
  final String? profileImageUrl;
  final String email;
  final String gender;
  final int age;
  final int height;
  final int weight;
  final int neck;
  final int waist;
  final int hips;
  final String goal;
  final String level;
  final String frequency;
  final String duration;
  //final String time;
  final List<String>? favorites; // New field
  final List<Timestamp>? completedDays;

  UserModel({
    required this.uid,
    required this.username,
    this.profileImageUrl,
    required this.email,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.neck,
    required this.waist,
    required this.hips,
    required this.goal,
    required this.level,
    required this.frequency,
    required this.duration,
    //required this.time,
    this.favorites, // Make favorites nullable here
    this.completedDays,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      username: map['username'],
      profileImageUrl: map['profileImageUrl'],
      email: map['email'],
      gender: map['gender'],
      age: map['age'],
      height: map['height'],
      weight: map['weight'],
      neck: map['neck'],
      waist: map['waist'],
      hips: map['hips'],
      goal: map['goal'],
      level: map['level'],
      frequency: map['frequency'],
      duration: map['duration'],
      //time: map['time'],
      favorites: List<String>.from(map['favorites'] ?? []), // Parse favorites
      completedDays: (map['completedDays'] as List<dynamic>?)
          ?.map((timestamp) => timestamp as Timestamp)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'email': email,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'neck': neck,
      'waist': waist,
      'hips': hips,
      'goal': goal,
      'level': level,
      'frequency': frequency,
      'duration': duration,
      //'time': time,
      'favorites': favorites, // Include favorites
      'completedDays': completedDays,
    };
  }
}
