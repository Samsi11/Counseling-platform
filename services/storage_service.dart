import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Authentication
  static Future<bool> saveUser(Map<String, dynamic> user) async {
    try {
      await _prefs?.setString('current_user', jsonEncode(user));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic>? getCurrentUser() {
    final userStr = _prefs?.getString('current_user');
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  static Future<bool> logout() async {
    await _prefs?.remove('current_user');
    return true;
  }

  // Users Database (Mock)
  static Future<bool> registerUser(Map<String, dynamic> user) async {
    final users = getAllUsers();
    
    // Check if email exists
    if (users.any((u) => u['email'] == user['email'])) {
      return false;
    }
    
    user['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    users.add(user);
    await _prefs?.setString('users', jsonEncode(users));
    return true;
  }

  static List<Map<String, dynamic>> getAllUsers() {
    final usersStr = _prefs?.getString('users');
    if (usersStr != null) {
      final List<dynamic> decoded = jsonDecode(usersStr);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  static Map<String, dynamic>? login(String email, String password) {
    final users = getAllUsers();
    try {
      return users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Counselors
  static List<Map<String, dynamic>> getAllCounselors() {
    final users = getAllUsers();
    return users.where((u) => u['userType'] == 'counselor' && u['status'] == 'approved').toList();
  }

  static Map<String, dynamic>? getCounselorById(String id) {
    final counselors = getAllCounselors();
    try {
      return counselors.firstWhere((c) => c['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Bookings
  static Future<bool> createBooking(Map<String, dynamic> booking) async {
    final bookings = getBookings();
    booking['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    booking['status'] = 'pending';
    booking['createdAt'] = DateTime.now().toIso8601String();
    bookings.add(booking);
    await _prefs?.setString('bookings', jsonEncode(bookings));
    return true;
  }

  static List<Map<String, dynamic>> getBookings() {
    final bookingsStr = _prefs?.getString('bookings');
    if (bookingsStr != null) {
      final List<dynamic> decoded = jsonDecode(bookingsStr);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  static List<Map<String, dynamic>> getUserBookings(String userId) {
    final bookings = getBookings();
    return bookings.where((b) => b['clientId'] == userId || b['counselorId'] == userId).toList();
  }

  // Messages
  static Future<bool> sendMessage(Map<String, dynamic> message) async {
    final messages = getMessages();
    message['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    message['timestamp'] = DateTime.now().toIso8601String();
    messages.add(message);
    await _prefs?.setString('messages', jsonEncode(messages));
    return true;
  }

  static List<Map<String, dynamic>> getMessages() {
    final messagesStr = _prefs?.getString('messages');
    if (messagesStr != null) {
      final List<dynamic> decoded = jsonDecode(messagesStr);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  static List<Map<String, dynamic>> getConversation(String user1Id, String user2Id) {
    final messages = getMessages();
    return messages.where((m) =>
      (m['senderId'] == user1Id && m['receiverId'] == user2Id) ||
      (m['senderId'] == user2Id && m['receiverId'] == user1Id)
    ).toList()..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
  }

  // Posts
  static Future<bool> createPost(Map<String, dynamic> post) async {
    final posts = getPosts();
    post['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    post['timestamp'] = DateTime.now().toIso8601String();
    post['likes'] = 0;
    post['comments'] = [];
    posts.insert(0, post);
    await _prefs?.setString('posts', jsonEncode(posts));
    return true;
  }

  static List<Map<String, dynamic>> getPosts() {
    final postsStr = _prefs?.getString('posts');
    if (postsStr != null) {
      final List<dynamic> decoded = jsonDecode(postsStr);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  static Future<bool> likePost(String postId, String userId) async {
    final posts = getPosts();
    final postIndex = posts.indexWhere((p) => p['id'] == postId);
    if (postIndex != -1) {
      posts[postIndex]['likes'] = (posts[postIndex]['likes'] ?? 0) + 1;
      await _prefs?.setString('posts', jsonEncode(posts));
      return true;
    }
    return false;
  }

  // Reviews
  static Future<bool> addReview(String counselorId, Map<String, dynamic> review) async {
    final reviews = getReviews();
    review['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    review['counselorId'] = counselorId;
    review['timestamp'] = DateTime.now().toIso8601String();
    reviews.add(review);
    await _prefs?.setString('reviews', jsonEncode(reviews));
    return true;
  }

  static List<Map<String, dynamic>> getReviews() {
    final reviewsStr = _prefs?.getString('reviews');
    if (reviewsStr != null) {
      final List<dynamic> decoded = jsonDecode(reviewsStr);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  static List<Map<String, dynamic>> getCounselorReviews(String counselorId) {
    final reviews = getReviews();
    return reviews.where((r) => r['counselorId'] == counselorId).toList();
  }

  static double getCounselorRating(String counselorId) {
    final reviews = getCounselorReviews(counselorId);
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0, (sum, r) => sum + (r['rating'] ?? 0));
    return total / reviews.length;
  }
}