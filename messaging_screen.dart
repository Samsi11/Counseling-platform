import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

// Main messaging screen - shows list of conversations
class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    final user = StorageService.getCurrentUser();
    final allMessages = StorageService.getMessages();
    
    // Group messages by conversation partners
    final Map<String, Map<String, dynamic>> conversationsMap = {};
    
    for (var message in allMessages) {
      final senderId = message['senderId'];
      final receiverId = message['receiverId'];
      
      // Determine the other person in conversation
      String otherPersonId;
      String otherPersonName;
      
      if (senderId == user?['id']) {
        otherPersonId = receiverId;
        otherPersonName = message['receiverName'] ?? 'User';
      } else if (receiverId == user?['id']) {
        otherPersonId = senderId;
        otherPersonName = message['senderName'] ?? 'User';
      } else {
        continue; // Not relevant to current user
      }
      
      // Create or update conversation entry
      if (!conversationsMap.containsKey(otherPersonId)) {
        conversationsMap[otherPersonId] = {
          'userId': otherPersonId,
          'userName': otherPersonName,
          'lastMessage': message['content'],
          'timestamp': message['timestamp'],
        };
      } else {
        // Update with latest message
        if (message['timestamp'].compareTo(conversationsMap[otherPersonId]!['timestamp']) > 0) {
          conversationsMap[otherPersonId]!['lastMessage'] = message['content'];
          conversationsMap[otherPersonId]!['timestamp'] = message['timestamp'];
        }
      }
    }
    
    _conversations = conversationsMap.values.toList();
    _conversations.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getCurrentUser();
    final isCounselor = user?['userType'] == 'counselor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          if (!isCounselor)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showNewChatDialog(),
            ),
        ],
      ),
      body: _conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  if (!isCounselor) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showNewChatDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Start New Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _loadConversations();
              },
              child: ListView.builder(
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text(
                        conversation['userName']?[0] ?? 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      conversation['userName'] ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      conversation['lastMessage'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            otherUserId: conversation['userId'],
                            otherUserName: conversation['userName'],
                          ),
                        ),
                      );
                      _loadConversations(); // Refresh after returning
                    },
                  );
                },
              ),
            ),
    );
  }

  void _showNewChatDialog() {
    final counselors = StorageService.getAllCounselors();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
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
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              otherUserId: counselor['id'],
                              otherUserName: counselor['name'],
                            ),
                          ),
                        );
                        _loadConversations();
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

// Individual chat screen for specific conversation
class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    final user = StorageService.getCurrentUser();
    _messages = StorageService.getConversation(user?['id'] ?? '', widget.otherUserId);
    setState(() {});
    
    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = StorageService.getCurrentUser();
    await StorageService.sendMessage({
      'senderId': user?['id'],
      'senderName': user?['name'],
      'receiverId': widget.otherUserId,
      'receiverName': widget.otherUserName,
      'content': _messageController.text.trim(),
    });

    _messageController.clear();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.otherUserName[0],
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.otherUserName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(widget.otherUserName),
                  content: const Text('Chat information and settings will appear here.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet. Say hello! 👋',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message['senderId'] == user?['id'];

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.black : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['content'] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}