### POST /api/register
{
"message": "Register success"
}

### POST /api/login
{
"message": "Login success",
"user": {
"id": 1,
"username": "anh_tu"
}
}

### POST /api/friends/add

### GET /api/friends
[
{
"user_id": 1,
"friend_id": 2,
"status": "accepted"
}
]

### POST /api/posts

### GET /api/posts
[
{
"id": 1,
"user_id": 1,
"content": "Hello",
"image": "url"
}
]

users
- id (int)
- username (string)
- password (string)

friends
- id
- user_id
- friend_id
- status (pending / accepted)

posts
- id
- user_id
- content
- image

User mở app
→ Login
→ Load posts (/api/posts)
→ Xem bạn bè (/api/friends)
→ Đăng bài (/api/posts)

## Future Features
- Like bài viết
- Comment
- Chat realtime
- Upload ảnh