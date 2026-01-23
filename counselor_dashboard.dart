import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../common/social_feed_screen.dart';
import '../common/profile_screen.dart';
import '../common/messaging_screen.dart';

class CounselorDashboard extends StatefulWidget {
  const CounselorDashboard({super.key});

  @override
  State<CounselorDashboard> createState() => _CounselorDashboardState();
}

class _CounselorDashboardState extends State<CounselorDashboard> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const CounselorHomeScreen(),
      const MessagingScreen(),
      const SocialFeedScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class CounselorHomeScreen extends StatefulWidget {
  const CounselorHomeScreen({super.key});

  @override
  State<CounselorHomeScreen> createState() => _CounselorHomeScreenState();
}

class _CounselorHomeScreenState extends State<CounselorHomeScreen> {
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _pendingBookings = [];
  double _rating = 0.0;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = StorageService.getCurrentUser();
    _bookings = StorageService.getUserBookings(user?['id'] ?? '');
    _pendingBookings = _bookings.where((b) => b['status'] == 'pending').toList();
    _rating = StorageService.getCounselorRating(user?['id'] ?? '');
    _reviews = StorageService.getCounselorReviews(user?['id'] ?? '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counselor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user?['name'] ?? 'Counselor'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatColumn(
                          label: 'Rating',
                          value: _rating.toStringAsFixed(1),
                          icon: Icons.star,
                        ),
                        _StatColumn(
                          label: 'Reviews',
                          value: _reviews.length.toString(),
                          icon: Icons.comment,
                        ),
                        _StatColumn(
                          label: 'Bookings',
                          value: _bookings.length.toString(),
                          icon: Icons.calendar_today,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pending Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_pendingBookings.isNotEmpty)
                  Chip(
                    label: Text('${_pendingBookings.length}'),
                    backgroundColor: Colors.orange[100],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_pendingBookings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No pending requests'),
                  ),
                ),
              )
            else
              ..._pendingBookings.map((booking) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(booking['clientName']?[0] ?? 'C'),
                    ),
                    title: Text(booking['clientName'] ?? 'Client'),
                    subtitle: Text('${booking['date']} at ${booking['time']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveBooking(context, booking),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _denyBooking(context, booking),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            const SizedBox(height: 24),
            const Text(
              'Upcoming Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._bookings
                .where((b) => b['status'] == 'approved')
                .take(3)
                .map((booking) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(booking['clientName']?[0] ?? 'C'),
                  ),
                  title: Text(booking['clientName'] ?? 'Client'),
                  subtitle: Text('${booking['date']} at ${booking['time']}'),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Start'),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreatePostDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Post'),
      ),
    );
  }

  void _approveBooking(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Booking'),
        content: Text('Approve booking for ${booking['clientName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              booking['status'] = 'approved';
              await StorageService.updateBooking(booking);
              
              Navigator.pop(context);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking approved!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the screen properly
                _loadData();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _denyBooking(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deny Booking'),
        content: Text('Deny booking for ${booking['clientName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              booking['status'] = 'rejected';
              await StorageService.updateBooking(booking);
              
              Navigator.pop(context);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking denied'),
                    backgroundColor: Colors.red,
                  ),
                );
                // Refresh the screen properly
                _loadData();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deny'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 100,
          decoration: const InputDecoration(
            hintText: 'Share inspiration...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final user = StorageService.getCurrentUser();
              await StorageService.createPost({
                'authorId': user?['id'],
                'authorName': user?['name'],
                'content': controller.text.trim(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post created!')),
              );
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}