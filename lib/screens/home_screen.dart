import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;

import '../services/firestore_service.dart';
import '../services/auth_service.dart';

import 'post_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'friends_screen.dart';
import 'chat_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = FirestoreService();
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isMobile = MediaQuery.of(context).size.width < 800;

    // ================= MOBILE =================
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("TrustMe"),
          centerTitle: true,
          actions: [

            //  SEARCH
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),

            //  NOTIFICATION BADGE
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("notifications")
                  .where("to", isEqualTo: currentUser?.uid)
                  .where("read", isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                int count =
                snapshot.hasData ? snapshot.data!.docs.length : 0;

                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationScreen()),
                    );
                  },
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications),

                      if (count > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            // MENU
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == "logout") {
                  await auth.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: "logout",
                  child: Text("Đăng xuất"),
                ),
              ],
            ),
          ],
        ),

        body: buildFeed(currentUser),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.chat),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ChatScreen()),
            );
          },
        ),

        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const FriendScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PostScreen()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProfileScreen()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: "Friends"),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Post"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      );
    }

    // ================= WEB =================
    return Scaffold(
      body: Row(
        children: [
          // LEFT MENU
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Text("TM",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),

                const SizedBox(height: 40),

                // ==== MENU ICONS (ĐỀU NHAU) ====
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.home),
                        onPressed: () => setState(() {}),
                      ),

                      IconButton(
                        icon: const Icon(Icons.group),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FriendScreen()),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.add_box),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PostScreen()),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SearchScreen()),
                          );
                        },
                      ),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("notifications")
                            .where("to", isEqualTo: currentUser?.uid)
                            .where("read", isEqualTo: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

                          return IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NotificationScreen()),
                              );
                            },
                            icon: badges.Badge(
                              showBadge: count > 0,
                              badgeContent: Text(
                                count.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                              position: badges.BadgePosition.topEnd(top: -5, end: -5),
                              child: const Icon(Icons.notifications),
                            ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ==== LOGOUT ====
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == "logout") {
                      await auth.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: "logout", child: Text("Đăng xuất")),
                  ],
                ),
              ],
            ),
          ),

          Expanded(flex: 2, child: buildFeed(currentUser)),
          Expanded(flex: 1, child: buildRightSidebar(currentUser)),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ChatScreen()),
          );
        },
      ),
    );
  }

  // ================= FEED =================
  Widget buildFeed(User? currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: db.getPosts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final postDoc = posts[index];
            final post =
                postDoc.data() as Map<String, dynamic>? ?? {};

            final likes = post["likes"] is List
                ? List<String>.from(post["likes"])
                : [];

            final isOwner =
                currentUser != null &&
                    currentUser.uid == post["userId"];

            return Center(
              child: Container(
                width: 300,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Card(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      //  HEADER + MENU
                      ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileScreen(uid: post["userId"]),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage:
                            (post["avatar"] != null &&
                                post["avatar"] != "")
                                ? NetworkImage(post["avatar"])
                                : null,
                            child: (post["avatar"] == null ||
                                post["avatar"] == "")
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        ),
                        title: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileScreen(uid: post["userId"]),
                              ),
                            );
                          },
                          child: Text(post["username"] ?? "User"),
                        ),

                        trailing: isOwner
                            ? PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == "delete") {
                              await db.deletePost(postDoc.id);
                            }
                            if (value == "edit") {
                              showEditDialog(
                                  postDoc.id,
                                  post["caption"] ?? "");
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: "edit",
                                child: Text("Sửa")),
                            PopupMenuItem(
                                value: "delete",
                                child: Text("Xóa")),
                          ],
                        )
                            : null,
                      ),

                      //  CAPTION
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(post["caption"] ?? ""),
                      ),

                      const SizedBox(height: 8),

                      //  IMAGE
                      if (post["image"] != null && post["image"] != "")
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: Image.network(
                            post["image"],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                          ),
                        ),

                      //  ACTION
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: currentUser != null &&
                                  likes.contains(currentUser.uid)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              db.toggleLike(postDoc.id);
                            },
                          ),
                          Text("${likes.length}"),

                          IconButton(
                            icon: const Icon(Icons.comment),
                            onPressed: () =>
                                showPostDialog(postDoc.id, post),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= EDIT =================
  void showEditDialog(String postId, String oldCaption) {
    final controller = TextEditingController(text: oldCaption);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sửa bài"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              await db.updatePost(postId, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          )
        ],
      ),
    );
  }

  // ================= RIGHT SIDEBAR (FIX AVATAR + PROFILE) =================
  Widget buildRightSidebar(User? currentUser) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gợi ý kết bạn",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db.getUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allUsers = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data["uid"] != currentUser?.uid;
                }).toList();

                allUsers.shuffle();

                return FutureBuilder(
                  future: Future.wait(allUsers.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return db.getFriendStatusWithDoc(data["uid"]);
                  })),
                  builder: (context, snap) {
                    if (!snap.hasData) return Container();

                    final statuses = snap.data as List;
                    List filtered = [];

                    for (int i = 0; i < allUsers.length; i++) {
                      if (statuses[i]["status"] == "none") {
                        filtered.add(allUsers[i]);
                      }
                    }

                    final users = filtered.take(5).toList();

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userData = users[index].data() as Map<String, dynamic>;

                        return ListTile(
                          // THÊM AVATAR
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(uid: userData["uid"]),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: (userData["avatar"] != null && userData["avatar"] != "")
                                  ? NetworkImage(userData["avatar"])
                                  : null,
                              child: (userData["avatar"] == null || userData["avatar"] == "")
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                          ),
                          title: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(uid: userData["uid"]),
                                ),
                              );
                            },
                            child: Text(userData["name"] ?? "User", style: const TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add, color: Colors.blue),
                            onPressed: () async {
                              await db.sendFriendRequest(userData["uid"]);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMENT =================
  void showPostDialog(String postId, Map post) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: Container(
            width: 400,
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              children: [

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.network(
                          post["image"] ?? "",
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                        ),

                        const SizedBox(height: 10),

                        Text(post["caption"] ?? ""),

                        const Divider(),

                        // ================= COMMENTS =================
                        StreamBuilder<QuerySnapshot>(
                          stream: db.getComments(postId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container();

                            final comments = snapshot.data!.docs;

                            return Column(
                              children: comments.map<Widget>((c) {
                                final data =
                                    c.data() as Map<String, dynamic>? ?? {};

                                //  LẤY USER REALTIME
                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(data["uid"])
                                      .get(),
                                  builder: (context, userSnap) {
                                    if (!userSnap.hasData) {
                                      return const SizedBox();
                                    }

                                    final userData = userSnap.data!.data()
                                    as Map<String, dynamic>? ??
                                        {};

                                    return ListTile(
                                      leading: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ProfileScreen(uid: data["uid"]),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundImage:
                                          (userData["avatar"] != null &&
                                              userData["avatar"] != "")
                                              ? NetworkImage(
                                              userData["avatar"])
                                              : null,
                                          child: (userData["avatar"] == null ||
                                              userData["avatar"] == "")
                                              ? const Icon(Icons.person)
                                              : null,
                                        ),
                                      ),
                                      title: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ProfileScreen(uid: data["uid"]),
                                            ),
                                          );
                                        },
                                        child: Text(
                                            userData["name"] ?? "User"),
                                      ),
                                      subtitle:
                                      Text(data["text"] ?? ""),
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(),

                // ================= INPUT =================
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: "Nhập comment...",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (controller.text.trim().isEmpty) return;

                        db.addComment(postId, controller.text.trim());
                        controller.clear();
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}