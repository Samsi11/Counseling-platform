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
                                onPressed: () {
                                  _showComments(context, post);
                                },
                                icon: const Icon(Icons.comment),
                                label: Text('${(post['comments'] as List?)?.length ?? 0}'),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _sharePost(context, post);
                                },
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

  void _showComments(BuildContext context, Map<String, dynamic> post) {
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Comments'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: (post['comments'] as List?)?.isEmpty ?? true
                      ? const Center(child: Text('No comments yet'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: (post['comments'] as List?)?.length ?? 0,
                          itemBuilder: (context, index) {
                            final comment = (post['comments'] as List)[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.black,
                                child: Text(
                                  comment['authorName']?[0] ?? 'U',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(comment['authorName'] ?? 'User'),
                              subtitle: Text(comment['text'] ?? ''),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (commentController.text.trim().isEmpty) return;
                        final user = StorageService.getCurrentUser();
                        
                        if (post['comments'] == null) {
                          post['comments'] = [];
                        }
                        (post['comments'] as List).add({
                          'authorName': user?['name'],
                          'text': commentController.text.trim(),
                        });
                        
                        StorageService.updatePost(post);
                        commentController.clear();
                        setDialogState(() {});
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(BuildContext context, Map<String, dynamic> post) {
    final user = StorageService.getCurrentUser();
    final isCounselor = user?['userType'] == 'counselor';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            if (!isCounselor)
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Share via Message'),
                onTap: () {
                  Navigator.pop(context);
                  _showShareWithDialog(context, post);
                },
              ),
            if (isCounselor)
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share on My Feed'),
                onTap: () async {
                  Navigator.pop(context);
                  
                  // Repost on counselor's feed
                  await StorageService.createPost({
                    'authorId': user?['id'],
                    'authorName': user?['name'],
                    'content': '${post['content']}\n\n[Shared from ${post['authorName']}]',
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post shared on your feed!')),
                    );
                    setState(() {});
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showShareWithDialog(BuildContext context, Map<String, dynamic> post) {
    final counselors = StorageService.getAllCounselors();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share With'),
        content: SizedBox(
          width: double.maxFinite,
          child: counselors.isEmpty
              ? const Text('No counselors available')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: counselors.length,
                  itemBuilder: (context, index) {
                    final counselor = counselors[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Text(
                          counselor['name']?[0] ?? 'C',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(counselor['name'] ?? ''),
                      onTap: () async {
                        Navigator.pop(context);
                        
                        // Send message with post content
                        final user = StorageService.getCurrentUser();
                        await StorageService.sendMessage({
                          'senderId': user?['id'],
                          'senderName': user?['name'],
                          'receiverId': counselor['id'],
                          'receiverName': counselor['name'],
                          'content': 'Check out this post: "${post['content']}"',
                        });
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Post shared with ${counselor['name']}'),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}