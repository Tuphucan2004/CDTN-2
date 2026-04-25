import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // ================= USER =================
  Future<void> createUserProfile(String name, String uid, String email) async {
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
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");
    return await db.collection("users").doc(user.uid).get();
  }

  Future<void> updateAvatar(String avatarUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await db.collection("users").doc(user.uid).update({
      "avatar": avatarUrl
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return db.collection("users").snapshots();
  }

  // ================= POSTS =================
  Future<void> createPost(String image, String caption) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await db.collection("users").doc(user.uid).get();
    final userData = userDoc.data();

    await db.collection("posts").add({
      "userId": user.uid,
      "username": userData?["name"] ?? "User",
      "avatar": userData?["avatar"] ?? "",
      "image": image,
      "caption": caption,
      "likes": [],
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePost(String postId) async {
    await db.collection("posts").doc(postId).delete();
  }

  Future<void> updatePost(String postId, String caption) async {
    await db.collection("posts").doc(postId).update({
      "caption": caption,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPosts() {
    return db
        .collection("posts")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // ================= LIKE (ĐÃ FIX) =================
  Future<void> toggleLike(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = db.collection("posts").doc(postId);
    
    // Sử dụng Transaction hoặc FieldValue để tránh xung đột rules và data
    final doc = await ref.get();
    if (!doc.exists) return;

    List likes = List.from(doc.data()?["likes"] ?? []);

    if (likes.contains(user.uid)) {
      await ref.update({
        "likes": FieldValue.arrayRemove([user.uid])
      });
    } else {
      await ref.update({
        "likes": FieldValue.arrayUnion([user.uid])
      });
      // Chỉ tạo thông báo khi like mới
      await createNotification(postId, "like");
    }
  }

  // ================= COMMENT =================
  Future<void> addComment(String postId, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (text.trim().isEmpty) return;

    final userDoc = await db.collection("users").doc(user.uid).get();
    final userData = userDoc.data();

    await db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .add({
      "uid": user.uid,
      "name": userData?["name"] ?? "User",
      "avatar": userData?["avatar"] ?? "",
      "text": text,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await createNotification(postId, "comment");
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .orderBy("createdAt")
        .snapshots();
  }

  // ================= NOTIFICATION (ĐÃ FIX) =================
  Future<void> createNotification(String postId, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await db.collection("users").doc(user.uid).get();
    final userData = userDoc.data();

    final postDoc = await db.collection("posts").doc(postId).get();
    if (!postDoc.exists) return;
    
    final postOwner = postDoc["userId"];

    if (postOwner == user.uid) return;

    await db.collection("notifications").add({
      "to": postOwner,
      "from": user.uid,
      "name": userData?["name"] ?? "User",
      "avatar": userData?["avatar"] ?? "",
      "type": type,
      "postId": postId,
      "createdAt": FieldValue.serverTimestamp(),
      "read": false,
    });
  }

  Stream<QuerySnapshot> getNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return db
        .collection("notifications")
        .where("to", isEqualTo: user.uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // ================= FRIEND =================
  Future<void> sendFriendRequest(String toUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final exist = await db
        .collection("friends")
        .where("members", arrayContains: user.uid)
        .get();

    for (var doc in exist.docs) {
      final d = doc.data();
      if (List<String>.from(d["members"]).contains(toUid)) return;
    }

    await db.collection("friends").add({
      "from": user.uid,
      "to": toUid,
      "members": [user.uid, toUid],
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFriend(String otherUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final res = await db
        .collection("friends")
        .where("from", isEqualTo: otherUid)
        .where("to", isEqualTo: user.uid)
        .where("status", isEqualTo: "pending")
        .get();

    for (var doc in res.docs) {
      await db
          .collection("friends")
          .doc(doc.id)
          .update({"status": "accepted"});
    }
  }

  Future<Map<String, dynamic>> getFriendStatusWithDoc(String otherUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {"status": "none", "docId": null};

    final res = await db
        .collection("friends")
        .where("members", arrayContains: user.uid)
        .get();

    for (var doc in res.docs) {
      final d = doc.data();
      final members = List<String>.from(d["members"]);
      if (!members.contains(otherUid)) continue;

      if (d["status"] == "accepted") {
        return {"status": "accepted", "docId": doc.id};
      }

      if (d["from"] == user.uid) {
        return {"status": "pending", "docId": doc.id};
      } else {
        return {"status": "request", "docId": doc.id};
      }
    }

    return {"status": "none", "docId": null};
  }

  Stream<int> getFriendCount(String uid) {
    return db
        .collection("friends")
        .where("members", arrayContains: uid)
        .where("status", isEqualTo: "accepted")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ================= CHAT =================
  Future<String> createChat(String otherUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");

    final ids = [user.uid, otherUid]..sort();
    final chatId = ids.join("_");

    final ref = db.collection("chats").doc(chatId);

    try {
      final doc = await ref.get();
      if (!doc.exists) {
        await ref.set({
          "members": ids,
          "lastMessage": "",
          "updatedAt": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      await ref.set({
        "members": ids,
        "lastMessage": "",
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  Future<void> sendMessage(String chatId, String text, {String? imageUrl}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isImage = imageUrl != null && imageUrl.isNotEmpty;
    final lastMsg = isImage ? "[Hình ảnh]" : text;

    await db
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .add({
      "sender": user.uid,
      "text": text,
      "imageUrl": imageUrl ?? "",
      "type": isImage ? "image" : "text",
      "createdAt": FieldValue.serverTimestamp(),
    });

    await db.collection("chats").doc(chatId).update({
      "lastMessage": lastMsg,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatId) {
    return db
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("createdAt")
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChats() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return db
        .collection("chats")
        .where("members", arrayContains: user.uid)
        .orderBy("updatedAt", descending: true)
        .snapshots();
  }
}