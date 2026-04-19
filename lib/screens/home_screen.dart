import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'post_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'friends_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();
    final auth = AuthService();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Row(
        children: [
          // LEFT MENU
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Text("TM",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),

                const SizedBox(height: 40),

                const Icon(Icons.home),
                const SizedBox(height: 30),

                const Icon(Icons.search),
                const SizedBox(height: 30),

                IconButton(
                  icon: const Icon(Icons.group),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FriendScreen()),
                    );
                  },
                ),

                const SizedBox(height: 30),

                IconButton(
                  icon: const Icon(Icons.add_box),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PostScreen()),
                    );
                  },
                ),

                const SizedBox(height: 30),

                const Icon(Icons.favorite_border),
                const SizedBox(height: 30),

                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const ProfileScreen()),
                    );
                  },
                ),

                const Spacer(),

                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  onSelected: (value) async {
                    if (value == "logout") {
                      await auth.logout();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const LoginScreen()),
                            (route) => false,
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                        value: "logout",
                        child: Text("Đăng xuất")),
                  ],
                ),
              ],
            ),
          ),

          // FEED
          Expanded(
            flex: 2,
            child: Center(
              child: SizedBox(
                width: 500,
                child: StreamBuilder<QuerySnapshot>(
                  stream: db.getPosts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final posts = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final doc = posts[index];
                        final post =
                        doc.data() as Map<String, dynamic>;

                        final isOwner =
                            post["userId"] ==
                                currentUser?.uid;

                        return Card(
                          margin:
                          const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                  (post["avatar"] != null &&
                                      post["avatar"]
                                          .toString()
                                          .isNotEmpty)
                                      ? NetworkImage(
                                      post["avatar"])
                                      : null,
                                  child: (post["avatar"] ==
                                      null ||
                                      post["avatar"] == "")
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(
                                  post["username"] ?? "User",
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                trailing: isOwner
                                    ? PopupMenuButton<String>(
                                  onSelected:
                                      (value) async {
                                    if (value ==
                                        "delete") {
                                      await db
                                          .deletePost(
                                          doc.id);
                                    }
                                  },
                                  itemBuilder:
                                      (context) =>
                                  const [
                                    PopupMenuItem(
                                      value: "delete",
                                      child:
                                      Text("Xóa"),
                                    ),
                                  ],
                                )
                                    : null,
                              ),

                              Image.network(
                                post["image"],
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (c, e, s) =>
                                const Icon(
                                    Icons.broken_image,
                                    size: 100),
                              ),

                              Padding(
                                padding:
                                const EdgeInsets.all(8),
                                child: Text(
                                  "${post["username"]}: ${post["caption"]}",
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // RIGHT
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder<QuerySnapshot>(
                stream: db.getUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();

                  final users = snapshot.data!.docs
                      .where((doc) =>
                  doc["uid"] != currentUser?.uid)
                      .toList();

                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text("Gợi ý",
                          style: TextStyle(
                              fontWeight:
                              FontWeight.bold)),
                      const SizedBox(height: 10),

                      ...users.take(5).map((doc) {
                        final user =
                        doc.data() as Map<String, dynamic>;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: (user["avatar"] !=
                                null &&
                                user["avatar"]
                                    .toString()
                                    .isNotEmpty)
                                ? NetworkImage(
                                user["avatar"])
                                : null,
                            child: (user["avatar"] == null ||
                                user["avatar"] == "")
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(user["name"] ?? ""),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}