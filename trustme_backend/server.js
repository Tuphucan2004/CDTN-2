const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

const posts = [
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

const friends = [
  { id: 1, name: "Giang" },
  { id: 2, name: "Nam" },
];

app.get("/api/posts", (req, res) => {
  res.json(posts);
});

app.get("/api/friends", (req, res) => {
  res.json([
    { id: 1, name: "Giang" },
    { id: 2, name: "Nam" },
  ]);
});

app.get("/", (req, res) => {
  res.send("TrustMe Backend is running ");
});

app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
});

app.get("/api/profile", (req, res) => {
  res.json({
    name: "Anh Tú",
    avatar: "https://randomuser.me/api/portraits/men/5.jpg",
    bio: "Flutter Developer ",
    posts: 12,
    followers: 120,
    following: 80,
  });
});
