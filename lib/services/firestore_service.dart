import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // ================= USER =================

  Future<void> createUserProfile(
      String name, String uid, String email) async {
    try {
      await db.collection("users").doc(uid).set({
        "uid": uid,
        "name": name,
        "email": email,
        "avatar": "",
        "bio": "New user",
        "followers": 0,
        "following": 0,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(" CREATE USER ERROR: $e");
    }
  }

  Future<DocumentSnapshot> getProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    return await db.collection("users").doc(user.uid).get();
  }

  Future<void> updateAvatar(String avatarUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) throw Exception("Not logged in");

      await db.collection("users").doc(user.uid).update({
        "avatar": avatarUrl,
      });
    } catch (e) {
      print(" UPDATE AVATAR ERROR: $e");
    }
  }

  // ================= POSTS =================

  Future<void> createPost(String image, String caption) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print(" USER NULL → chưa login");
        return;
      }

      // lấy profile
      final userDoc =
      await db.collection("users").doc(user.uid).get();

      final userData = userDoc.data();

      print(" POST USER UID: ${user.uid}");

      await db.collection("posts").add({
        "userId": user.uid,
        "username": userData?["name"] ?? "User",
        "avatar": userData?["avatar"] ?? "",
        "image": image,
        "caption": caption,
        "likes": 0,
        "createdAt": FieldValue.serverTimestamp(),
      });

      print(" POST SUCCESS");
    } catch (e) {
      print(" CREATE POST ERROR: $e");
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await db.collection("posts").doc(postId).delete();
    } catch (e) {
      print(" DELETE POST ERROR: $e");
    }
  }

  Stream<QuerySnapshot> getPosts() {
    return db
        .collection("posts")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getUsers() {
    return db.collection("users").snapshots();
  }
}