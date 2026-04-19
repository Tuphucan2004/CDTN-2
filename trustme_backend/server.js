const express = require("express");
const cors = require("cors");

const app = express();

// ===== Middleware =====
app.use(cors());
app.use(express.json());

// ===== Fake Database =====
let users = [
  {
    id: 1,
    email: "test@gmail.com",
    password: "123456",
    name: "Anh Tú",
  },
];

let posts = [
  {
    id: 1,
    name: "anh_tu",
    image: "https://picsum.photos/500/400?1",
  },
  {
    id: 2,
    name: "giang",
    image: "https://picsum.photos/500/400?2",
  },
];

let friends = [
  { id: 1, name: "Giang" },
  { id: 2, name: "Nam" },
];

// ===== ROUTES =====

// test server
app.get("/", (req, res) => {
  res.send(" TrustMe Backend is running...");
});

// ===== AUTH =====

// REGISTER
app.post("/api/register", (req, res) => {
  const { email, password, name } = req.body;

  if (!email || !password || !name) {
    return res.status(400).json({ message: "Thiếu dữ liệu" });
  }

  const userExists = users.find((u) => u.email === email);

  if (userExists) {
    return res.status(400).json({ message: "Email đã tồn tại" });
  }

  const newUser = {
    id: users.length + 1,
    email,
    password,
    name,
  };

  users.push(newUser);

  res.json({
    message: "Đăng ký thành công",
    user: newUser,
  });
});

// LOGIN
app.post("/api/login", (req, res) => {
  const { email, password } = req.body;

  const user = users.find(
    (u) => u.email === email && u.password === password
  );

  if (!user) {
    return res.status(401).json({ message: "Sai email hoặc mật khẩu" });
  }

  res.json({
    message: "Đăng nhập thành công",
    user,
  });
});

// ===== POSTS =====

// GET POSTS
app.get("/api/posts", (req, res) => {
  res.json(posts);
});

// CREATE POST
app.post("/api/posts", (req, res) => {
  const { name, image } = req.body;

  if (!name || !image) {
    return res.status(400).json({ message: "Thiếu dữ liệu" });
  }

  const newPost = {
    id: posts.length + 1,
    name,
    image,
  };

  posts.push(newPost);

  res.json({
    message: "Đăng bài thành công",
    post: newPost,
  });
});

// ===== FRIENDS =====
app.get("/api/friends", (req, res) => {
  res.json(friends);
});

// ===== PROFILE =====
app.get("/api/profile", (req, res) => {
  res.json({
    name: "Anh Tú",
    avatar: "https://randomuser.me/api/portraits/men/5.jpg",
    bio: "Flutter Developer 🚀",
    posts: posts.length,
    followers: 120,
    following: friends.length,
  });
});

// ===== 404 HANDLER =====
app.use((req, res) => {
  res.status(404).json({
    message: "API không tồn tại ",
  });
});

// ===== START SERVER =====
app.listen(3000, "0.0.0.0", () => {
  console.log(" Server running at:");
  console.log(" http://localhost:3000");
});