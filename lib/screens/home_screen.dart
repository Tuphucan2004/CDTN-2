import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'friends_screen.dart';
import 'package:flutter/foundation.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  List posts = [];
  bool isLoading = true;
  String error = "";

  final List stories = const [
    "https://randomuser.me/api/portraits/men/1.jpg",
    "https://randomuser.me/api/portraits/women/2.jpg",
    "https://randomuser.me/api/portraits/men/3.jpg",
  ];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future fetchPosts() async {
    try {
      final url = kIsWeb
          ? "http://localhost:3000/api/posts"
          : "http://10.0.2.2:3000/api/posts";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          posts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Server lỗi: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Không kết nối được backend";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;
    final textColor = isMobile ? Colors.white : Colors.black;

    /// 📱 MOBILE
    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text("TrustMe"),
        ),
        body: getScreen(textColor),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Post"),
            BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Reels"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      );
    }

    /// 💻 PC
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 500,
                child: getScreen(textColor),
              ),
            ),
          ),
          const SuggestPanel(),
        ],
      ),
    );
  }

  /// 🔥 CHUYỂN MÀN
  Widget getScreen(Color textColor) {
    switch (currentIndex) {
      case 0:
        return buildFeed(textColor);
      case 1:
        return const FriendsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return buildFeed(textColor);
    }
  }

  /// ================= FEED =================
  Widget buildFeed(Color textColor) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(
        child: Text(error, style: const TextStyle(color: Colors.red)),
      );
    }

    return ListView.builder(
      itemCount: posts.length + 1,
      itemBuilder: (context, index) {
        /// STORY
        if (index == 0) {
          return Column(
            children: [
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                            child: ClipOval(
                              child: Image.network(
                                stories[i],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "user",
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: Colors.grey),
            ],
          );
        }

        /// POSTS
        final post = posts[index - 1];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: textColor),
              ),
              title: Text(
                post["name"] ?? "",
                style: TextStyle(color: textColor),
              ),
            ),
            Image.network(
              post["image"] ?? "",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.favorite_border, color: textColor),
                  const SizedBox(width: 10),
                  Icon(Icons.comment, color: textColor),
                  const SizedBox(width: 10),
                  Icon(Icons.send, color: textColor),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ===== SIDEBAR =====
class Sidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Sidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget buildItem(IconData icon, String title, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TrustMe",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          buildItem(Icons.home, "Trang chủ", 0),
          buildItem(Icons.people, "Bạn bè", 1),
          buildItem(Icons.add_box, "Đăng bài", 2),
          buildItem(Icons.video_library, "Reels", 3),
          buildItem(Icons.person, "Cá nhân", 4),
        ],
      ),
    );
  }
}

/// ===== RIGHT PANEL =====
class SuggestPanel extends StatelessWidget {
  const SuggestPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          Text("Gợi ý cho bạn",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ListTile(
            leading: CircleAvatar(),
            title: Text("Phuong"),
            trailing:
            Text("Theo dõi", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}