import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'counseling_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("PRAGMA foreign_keys = ON;");

        // USERS
        await db.execute('''
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  dob TEXT,
  gender TEXT,
  location TEXT,
  password_hash TEXT NOT NULL,
  role TEXT,
  email_verified INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
''');

        await db.execute('''
CREATE TABLE clients (
  user_id INTEGER PRIMARY KEY,
  preferred_contact TEXT,
  bio TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE counselors (
  user_id INTEGER PRIMARY KEY,
  bio TEXT,
  years_experience INTEGER,
  session_rate REAL,
  max_session_duration INTEGER,
  session_type TEXT,
  availability_status INTEGER DEFAULT 1,
  rating_average REAL DEFAULT 0,
  followers_count INTEGER DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE admins (
  user_id INTEGER PRIMARY KEY,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
''');

        // APPLICATION
        await db.execute('''
CREATE TABLE counselor_applications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  status TEXT,
  faith_background TEXT,
  professional_experience TEXT,
  background_check INTEGER,
  submitted_at TEXT DEFAULT CURRENT_TIMESTAMP,
  reviewed_at TEXT,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE counselor_certifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  counselor_id INTEGER,
  document_url TEXT,
  title TEXT,
  FOREIGN KEY(counselor_id) REFERENCES counselors(user_id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE counselor_references (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  counselor_id INTEGER,
  name TEXT,
  relationship TEXT,
  contact TEXT,
  FOREIGN KEY(counselor_id) REFERENCES counselors(user_id) ON DELETE CASCADE
);
''');

        // AVAILABILITY + SESSIONS
        await db.execute('''
CREATE TABLE availability_slots (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  counselor_id INTEGER,
  date TEXT,
  start_time TEXT,
  end_time TEXT,
  session_type TEXT,
  status TEXT DEFAULT 'available',
  FOREIGN KEY(counselor_id) REFERENCES counselors(user_id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  counselor_id INTEGER,
  client_id INTEGER,
  slot_id INTEGER,
  status TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(counselor_id) REFERENCES counselors(user_id),
  FOREIGN KEY(client_id) REFERENCES clients(user_id),
  FOREIGN KEY(slot_id) REFERENCES availability_slots(id)
);
''');

        // MESSAGING
        await db.execute('''
CREATE TABLE conversations (
  id INTEGER PRIMARY KEY AUTOINCREMENT
);
''');

        await db.execute('''
CREATE TABLE messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  conversation_id INTEGER,
  sender_id INTEGER,
  receiver_id INTEGER,
  message TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(conversation_id) REFERENCES conversations(id),
  FOREIGN KEY(sender_id) REFERENCES users(id),
  FOREIGN KEY(receiver_id) REFERENCES users(id)
);
''');

        // POSTS & SOCIAL
        await db.execute('''
CREATE TABLE posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  counselor_id INTEGER,
  content TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(counselor_id) REFERENCES counselors(user_id)
);
''');

        await db.execute('''
CREATE TABLE post_images (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_id INTEGER,
  image_url TEXT,
  FOREIGN KEY(post_id) REFERENCES posts(id)
);
''');

        await db.execute('''
CREATE TABLE comments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_id INTEGER,
  user_id INTEGER,
  content TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(post_id) REFERENCES posts(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);
''');

        await db.execute('''
CREATE TABLE likes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_id INTEGER,
  user_id INTEGER,
  FOREIGN KEY(post_id) REFERENCES posts(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);
''');

        await db.execute('''
CREATE TABLE followers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  counselor_id INTEGER,
  user_id INTEGER,
  FOREIGN KEY(counselor_id) REFERENCES counselors(user_id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);
''');

        // REVIEWS
        await db.execute('''
CREATE TABLE reviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER,
  client_id INTEGER,
  counselor_id INTEGER,
  rating INTEGER,
  review_text TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(session_id) REFERENCES sessions(id),
  FOREIGN KEY(client_id) REFERENCES clients(user_id),
  FOREIGN KEY(counselor_id) REFERENCES counselors(user_id)
);
''');

        // SECURITY
        await db.execute('''
CREATE TABLE authentication_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  event TEXT,
  timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(user_id) REFERENCES users(id)
);
''');

        await db.execute('''
CREATE TABLE reported_content (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  content_type TEXT,
  content_id INTEGER,
  reason TEXT,
  reviewed INTEGER DEFAULT 0,
  FOREIGN KEY(user_id) REFERENCES users(id)
);
''');
      },
    );
  }
}
