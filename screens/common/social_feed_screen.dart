import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _posts = StorageService.getPosts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
      ),
      body: _posts.isEmpty
          ? const Center(
              child: Text('No posts yet'),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _loadPosts();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                child: Text(post['authorName']?[0] ?? 'U'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['authorName'] ?? 'User',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Posted recently',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            post['content'] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  final user = StorageService.getCurrentUser();
                                  await StorageService.likePost(
                                    post['id'],
                                    user?['id'] ?? '',
                                  );
                                  _loadPosts();
                                },
                                icon: const Icon(Icons.favorite_border),
                                label: Text('${post['likes'] ?? 0}'),
                              ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.comment),
                                label: const Text('Comment'),
                              ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.share),
                                label: const Text('Share'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}