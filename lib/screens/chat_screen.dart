import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart'; // Import file storage của bạn

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String? otherUserName;

  const ChatScreen({
    super.key,
    this.chatId,
    this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final db = FirestoreService();
  final storage = StorageService();
  final currentUser = FirebaseAuth.instance.currentUser;

  String? selectedChatId;
  String? selectedUserName;

  final textController = TextEditingController();
  final scrollController = ScrollController();
  final searchController = TextEditingController();
  final focusNode = FocusNode();

  String searchText = "";
  bool showEmoji = false;
  bool isUploading = false;

  bool get isMobile => MediaQuery.of(context).size.width < 800;

  @override
  void initState() {
    super.initState();
    if (widget.chatId != null) {
      selectedChatId = widget.chatId;
      selectedUserName = widget.otherUserName;
    }

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          showEmoji = false;
        });
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openChat(String chatId, String userName) {
    if (isMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: chatId,
            otherUserName: userName,
          ),
        ),
      );
    } else {
      setState(() {
        selectedChatId = chatId;
        selectedUserName = userName;
      });
    }
  }

  void sendText() async {
    if (selectedChatId == null) return;
    if (textController.text.trim().isEmpty) return;

    final text = textController.text.trim();
    textController.clear();

    await db.sendMessage(selectedChatId!, text);
    _scrollToBottom();
  }

  Future<void> sendImage() async {
    if (selectedChatId == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => isUploading = true);
      try {
        final Uint8List bytes = await pickedFile.readAsBytes();
        final imageUrl = await storage.uploadChatImageBytes(bytes, selectedChatId!);

        // Gửi tin nhắn chứa ảnh
        await db.sendMessage(selectedChatId!, "", imageUrl: imageUrl);
        _scrollToBottom();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi tải ảnh lên!")),
        );
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  // ================= THANH TÌM KIẾM =================
  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Tìm kiếm",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.all(0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchText = value.trim().toLowerCase();
          });
        },
      ),
    );
  }

  // ================= KẾT QUẢ TÌM KIẾM =================
  Widget buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final users = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data["name"] ?? "").toString().toLowerCase();
          return data["uid"] != currentUser?.uid && name.contains(searchText);
        }).toList();

        if (users.isEmpty) return const Center(child: Text("Không tìm thấy kết quả"));

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final data = users[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: (data["avatar"] != null && data["avatar"] != "")
                    ? NetworkImage(data["avatar"]) : null,
                child: (data["avatar"] == null || data["avatar"] == "")
                    ? const Icon(Icons.person) : null,
              ),
              title: Text(data["name"] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                final chatId = await db.createChat(data["uid"]);
                _openChat(chatId, data["name"] ?? "User");
                searchController.clear();
                setState(() => searchText = "");
              },
            );
          },
        );
      },
    );
  }

  // ================= DANH SÁCH CHAT GẦN ĐÂY =================
  Widget buildRecentChats() {
    return StreamBuilder<QuerySnapshot>(
      stream: db.getChats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final chats = snapshot.data!.docs;
        if (chats.isEmpty) return const Center(child: Text("Chưa có tin nhắn nào"));

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final doc = chats[index];
            final data = doc.data() as Map<String, dynamic>;
            final members = List<String>.from(data["members"] ?? []);
            final otherUid = members.firstWhere((id) => id != currentUser?.uid, orElse: () => "");

            if (otherUid.isEmpty) return const SizedBox();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("users").doc(otherUid).get(),
              builder: (context, snapUser) {
                if (!snapUser.hasData) return const SizedBox();

                final userData = snapUser.data!.data() as Map<String, dynamic>? ?? {};

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: (userData["avatar"] != null && userData["avatar"] != "")
                        ? NetworkImage(userData["avatar"]) : null,
                    child: (userData["avatar"] == null || userData["avatar"] == "")
                        ? const Icon(Icons.person) : null,
                  ),
                  title: Text(
                    userData["name"] ?? "Unknown",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    data["lastMessage"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () => _openChat(doc.id, userData["name"] ?? "Unknown"),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildChatSidebar() {
    if (isMobile && widget.chatId != null) return const SizedBox();
    return Column(
      children: [
        buildSearchBar(),
        Expanded(child: searchText.isNotEmpty ? buildSearchResults() : buildRecentChats()),
      ],
    );
  }

  // ================= KHUNG NHẮN TIN =================
  Widget buildMessagesArea() {
    if (selectedChatId == null) {
      return const Center(child: Text("Chọn một đoạn chat để bắt đầu nhắn tin", style: TextStyle(color: Colors.grey)));
    }

    return Column(
      children: [
        if (!isMobile)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            width: double.infinity,
            child: Text(
              selectedUserName ?? "Chat",
              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

        // DANH SÁCH TIN NHẮN
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: db.getMessages(selectedChatId!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final msgs = snapshot.data!.docs;

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final data = msgs[index].data() as Map<String, dynamic>;
                  final isMe = data["sender"] == currentUser?.uid;

                  // Kiểm tra xem tin nhắn có chứa ảnh không
                  final imageUrl = data["imageUrl"] as String?;
                  final isImage = imageUrl != null && imageUrl.isNotEmpty;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 2, bottom: 2,
                        left: isMe ? 60 : 0,
                        right: isMe ? 0 : 60,
                      ),
                      // Không cần padding/màu nền nếu là ảnh
                      padding: isImage ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isImage ? Colors.transparent : (isMe ? Colors.blueAccent : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                          bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(20),
                        ),
                      ),
                      child: isImage
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          width: 220,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Text(
                        data["text"] ?? "",
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Hiển thị Loading khi đang up ảnh
        if (isUploading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(),
          ),

        // THANH CÔNG CỤ NHẬP TIN NHẮN
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!))
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Nút chọn ảnh
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.blueAccent),
                  onPressed: sendImage,
                ),
                // Nút bật/tắt Emoji
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: Colors.blueAccent),
                  onPressed: () {
                    setState(() {
                      showEmoji = !showEmoji;
                      if (showEmoji) {
                        focusNode.unfocus(); // Ẩn bàn phím để hiện Emoji Picker
                      } else {
                        focusNode.requestFocus(); // Hiện lại bàn phím
                      }
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    focusNode: focusNode,
                    controller: textController,
                    onTap: () {
                      if (showEmoji) setState(() => showEmoji = false);
                    },
                    decoration: InputDecoration(
                      hintText: "Aa",
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: sendText,
                )
              ],
            ),
          ),
        ),

        // BẢNG EMOJI PICKER (Dành cho phiên bản 4.x.x)
        Offstage(
          offstage: !showEmoji,
          child: SizedBox(
            height: 250,
            child: EmojiPicker(
              textEditingController: textController,
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                viewOrderConfig: const ViewOrderConfig(),
                emojiViewConfig: EmojiViewConfig(
                  emojiSizeMax: 28 * (isMobile ? 1.0 : 1.2),
                ),
                skinToneConfig: const SkinToneConfig(),
                categoryViewConfig: const CategoryViewConfig(),
                bottomActionBarConfig: const BottomActionBarConfig(),
                searchViewConfig: const SearchViewConfig(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isMobile && widget.chatId != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.blueAccent),
          title: Text(
            selectedUserName ?? "Chat",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: buildMessagesArea(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isMobile ? AppBar(
        title: const Text("Chat", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
      ) : null,
      body: isMobile
          ? buildChatSidebar()
          : Row(
        children: [
          SizedBox(
              width: 350,
              child: Scaffold(
                appBar: AppBar(title: const Text("Chat")),
                body: buildChatSidebar(),
              )
          ),
          VerticalDivider(width: 1, color: Colors.grey[300]),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: buildMessagesArea(),
            ),
          ),
        ],
      ),
    );
  }
}
