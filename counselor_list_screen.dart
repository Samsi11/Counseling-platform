import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class CounselorListScreen extends StatefulWidget {
  const CounselorListScreen({super.key});

  @override
  State<CounselorListScreen> createState() => _CounselorListScreenState();
}

class _CounselorListScreenState extends State<CounselorListScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _counselors = [];
  List<Map<String, dynamic>> _filteredCounselors = [];

  @override
  void initState() {
    super.initState();
    _loadCounselors();
  }

  void _loadCounselors() {
    _counselors = StorageService.getAllCounselors();
    _filteredCounselors = _counselors;
    setState(() {});
  }

  void _filterCounselors(String query) {
    if (query.isEmpty) {
      _filteredCounselors = _counselors;
    } else {
      _filteredCounselors = _counselors.where((c) {
        final name = (c['name'] ?? '').toLowerCase();
        final bio = (c['bio'] ?? '').toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || bio.contains(searchLower);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Counselors'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search counselors...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterCounselors,
            ),
          ),
        ),
      ),
      body: _filteredCounselors.isEmpty
          ? const Center(child: Text('No counselors found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredCounselors.length,
              itemBuilder: (context, index) {
                final counselor = _filteredCounselors[index];
                final rating = StorageService.getCounselorRating(counselor['id'] ?? '');
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/counselor-profile',
                        arguments: counselor,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                child: Text(
                                  counselor['name']?[0] ?? 'C',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      counselor['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 16, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text('${rating.toStringAsFixed(1)} (${counselor['reviewCount'] ?? 0} reviews)'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${counselor['rate']}/hr',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${counselor['experience']} yrs exp',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            counselor['bio'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (counselor['specializations'] as List? ?? [])
                                .map((spec) => Chip(
                                      label: Text(spec, style: const TextStyle(fontSize: 12)),
                                      backgroundColor: Colors.blue[50],
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}