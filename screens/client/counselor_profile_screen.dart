import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class CounselorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> counselor;

  const CounselorProfileScreen({super.key, required this.counselor});

  @override
  State<CounselorProfileScreen> createState() => _CounselorProfileScreenState();
}

class _CounselorProfileScreenState extends State<CounselorProfileScreen> {
  List<Map<String, dynamic>> _reviews = [];
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    _reviews = StorageService.getCounselorReviews(widget.counselor['id'] ?? '');
    _rating = StorageService.getCounselorRating(widget.counselor['id'] ?? '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counselor Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Text(
                      widget.counselor['name']?[0] ?? 'C',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.counselor['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${_rating.toStringAsFixed(1)} (${_reviews.length} reviews)',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatCard(
                        icon: Icons.work,
                        label: 'Experience',
                        value: '${widget.counselor['experience']} years',
                      ),
                      _StatCard(
                        icon: Icons.attach_money,
                        label: 'Rate',
                        value: '\$${widget.counselor['rate']}/hr',
                      ),
                      _StatCard(
                        icon: Icons.people,
                        label: 'Followers',
                        value: '${widget.counselor['followers'] ?? 0}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/booking',
                              arguments: widget.counselor,
                            );
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Book Session'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/messaging');
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('Message'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // About Section
            _SectionCard(
              title: 'About',
              child: Text(
                widget.counselor['bio'] ?? 'No bio available',
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            // Specializations
            _SectionCard(
              title: 'Specializations',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (widget.counselor['specializations'] as List? ?? [])
                    .map((spec) => Chip(
                          label: Text(spec),
                          backgroundColor: Colors.blue[50],
                        ))
                    .toList(),
              ),
            ),
            // Session Type
            _SectionCard(
              title: 'Session Type',
              child: Row(
                children: [
                  Icon(
                    widget.counselor['sessionType'] == 'online'
                        ? Icons.videocam
                        : widget.counselor['sessionType'] == 'onsite'
                            ? Icons.location_on
                            : Icons.dashboard,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.counselor['sessionType'] == 'online'
                        ? 'Online Only'
                        : widget.counselor['sessionType'] == 'onsite'
                            ? 'Onsite Only'
                            : 'Both Online & Onsite',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Reviews
            _SectionCard(
              title: 'Reviews (${_reviews.length})',
              child: _reviews.isEmpty
                  ? const Text('No reviews yet')
                  : Column(
                      children: _reviews.take(5).map((review) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  child: Text(review['clientName']?[0] ?? 'U'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review['clientName'] ?? 'Anonymous',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (index) => Icon(
                                            index < (review['rating'] ?? 0)
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(review['comment'] ?? ''),
                            const Divider(height: 24),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

