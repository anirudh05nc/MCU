
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_styles/app_colors.dart';
import '../providers/user_provider.dart';
import '../data/models/user_profile.dart';
import '../widgets/app_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Effect to populate fields when data is available
  void _populateFields(UserProfile? profile) {
    if (profile != null) {
      if (_nameController.text.isEmpty) _nameController.text = profile.name;
      if (_phoneController.text.isEmpty) _phoneController.text = profile.phone;
      if (_addressController.text.isEmpty) _addressController.text = profile.address;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final profile = UserProfile(
          uid: user.uid,
          email: user.email ?? '',
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          profileImageUrl: '', // Handle image upload later if needed
        );

        await ref.read(userProfileProvider.notifier).updateProfile(profile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Updated Successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigation handled by main.dart auth state listener
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: appColors.background,
      body: userProfileAsync.when(
        data: (profile) {
          // Pre-fill only if not already editing (simplified approach)
          // Better approach is to use initial values or controller management
          // But relying on initState/controllers for simplicity here with a manual trigger if needed
          // Or identifying if it's first load. For now, let's just use the controllers 
          // and if they are empty, fill them from profile.
          _populateFields(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: appColors.background2,
                          child: Icon(Icons.person, size: 50, color: appColors.gold),
                        ),
                        // Edit icon could go here
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildTextField(appColors, "Full Name", _nameController, Icons.person_outline),
                  const SizedBox(height: 16),
                  
                  _buildTextField(appColors, "Phone Number", _phoneController, Icons.phone_outlined, 
                    keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  
                  _buildTextField(appColors, "Address", _addressController, Icons.location_on_outlined, 
                    maxLines: 3),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE PROFILE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTextField(
    dynamic appColors, 
    String label, 
    TextEditingController controller, 
    IconData icon, 
    {TextInputType? keyboardType, int maxLines = 1}
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: appColors.gold),
        filled: true,
        fillColor: appColors.background2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: appColors.textSecondary),
      ),
      style: TextStyle(color: appColors.textPrimary),
      validator: (value) => value != null && value.isNotEmpty ? null : '$label is required',
    );
  }
}
