import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class CounselorRegisterScreen extends StatefulWidget {
  const CounselorRegisterScreen({super.key});

  @override
  State<CounselorRegisterScreen> createState() => _CounselorRegisterScreenState();
}

class _CounselorRegisterScreenState extends State<CounselorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _rateController = TextEditingController();
  
  final List<String> _selectedSpecializations = [];
  final List<String> _availableSpecializations = [
    'Marriage & Family',
    'Depression & Anxiety',
    'Grief & Loss',
    'Addiction',
    'Trauma',
    'Youth Counseling',
    'Career Guidance',
    'Spiritual Growth',
  ];
  
  String _sessionType = 'both';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedSpecializations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one specialization')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final counselor = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'userType': 'counselor',
      'bio': _bioController.text.trim(),
      'experience': _experienceController.text.trim(),
      'rate': double.parse(_rateController.text),
      'specializations': _selectedSpecializations,
      'sessionType': _sessionType,
      'status': 'approved', // Auto-approve for demo
      'rating': 4.5,
      'reviewCount': 0,
      'followers': 0,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final success = await StorageService.registerUser(counselor);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email already exists')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Counselor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Counselor Application',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (!value!.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (value!.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Professional Bio',
                    prefixIcon: Icon(Icons.description),
                    hintText: 'Tell clients about yourself...',
                  ),
                  maxLines: 4,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(
                    labelText: 'Years of Experience',
                    prefixIcon: Icon(Icons.work),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(
                    labelText: 'Hourly Rate (USD)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(value!) == null) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Specializations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _availableSpecializations.map((spec) {
                    final isSelected = _selectedSpecializations.contains(spec);
                    return FilterChip(
                      label: Text(spec),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSpecializations.add(spec);
                          } else {
                            _selectedSpecializations.remove(spec);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Session Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                RadioListTile(
                  title: const Text('Online Only'),
                  value: 'online',
                  groupValue: _sessionType,
                  onChanged: (value) => setState(() => _sessionType = value!),
                ),
                RadioListTile(
                  title: const Text('Onsite Only'),
                  value: 'onsite',
                  groupValue: _sessionType,
                  onChanged: (value) => setState(() => _sessionType = value!),
                ),
                RadioListTile(
                  title: const Text('Both Online & Onsite'),
                  value: 'both',
                  groupValue: _sessionType,
                  onChanged: (value) => setState(() => _sessionType = value!),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit Application'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _rateController.dispose();
    super.dispose();
  }
}