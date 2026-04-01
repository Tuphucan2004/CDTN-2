import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List stories = const [
    "https://randomuser.me/api/portraits/men/1.jpg",
    "https://randomuser.me/api/portraits/women/2.jpg",
    "https://randomuser.me/api/portraits/men/3.jpg",
  ];

  final List posts = const [
    {
      "name": "anh_tu",
      "avatar": "https://randomuser.me/api/portraits/men/5.jpg",
      "image": "https://picsum.photos/500/400?1",
    },
    {
      "name": "giang",
      "avatar": "https://randomuser.me/api/portraits/women/6.jpg",
      "image": "https://picsum.photos/500/400?2",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    /// 📱 MOBILE
    if (width < 800) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("TrustMe"),
          actions: const [
            Icon(Icons.favorite_border),
            SizedBox(width: 10),
            Icon(Icons.send),
          ],
        ),
        body: buildFeed(),
        bottomNavigationBar: const BottomNav(),
      );
    }

    ///  PC
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(child: Center(child: SizedBox(width: 500, child: buildFeed()))),
          const SuggestPanel(),
        ],
      ),
    );
  }

  /// ================= FEED =================
  Widget buildFeed() {
    return ListView(
      children: [
        /// STORY
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(stories[index]),
                    ),
                    const SizedBox(height: 5),
                    const Text("user", style: TextStyle(fontSize: 12))
                  ],
                ),
              );
            },
          ),
        ),

        const Divider(),

        /// POSTS
        ...posts.map((post) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(post["avatar"]!),
              ),
              title: Text(post["name"]!),
            ),
            Image.network(post["image"]!),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.favorite_border),
                  SizedBox(width: 10),
                  Icon(Icons.comment),
                  SizedBox(width: 10),
                  Icon(Icons.send),
                ],
              ),
            ),
          ],
        ))
      ],
    );
  }
}
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("TrustMe", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 30),
          Row(children: [Icon(Icons.home), SizedBox(width: 10), Text("Trang chủ")]),
          SizedBox(height: 20),
          Row(children: [Icon(Icons.search), SizedBox(width: 10), Text("Tìm kiếm")]),
          SizedBox(height: 20),
          Row(children: [Icon(Icons.explore), SizedBox(width: 10), Text("Khám phá")]),
          SizedBox(height: 20),
          Row(children: [Icon(Icons.message), SizedBox(width: 10), Text("Tin nhắn")]),
        ],
      ),
    );
  }
}
class SuggestPanel extends StatelessWidget {
  const SuggestPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Gợi ý cho bạn",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ListTile(
            leading: CircleAvatar(),
            title: Text("Phuong"),
            trailing: Text("Theo dõi", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,

      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,

      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,

      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },

      items: [
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 0 ? Icons.home : Icons.home_outlined,
          ),
          label: "",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_box),
          label: "",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.video_library),
          label: "",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "",
        ),
      ],
    );
  }
}