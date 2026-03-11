
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile.dart';

// Stream of the current authenticated user
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider to manage UserProfile state
class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null);

  Future<void> loadProfile(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        state = UserProfile.fromDocument(doc);
      }
    } catch (e) {
      // Handle error
      print("Error loading profile: $e");
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(profile.uid).set(profile.toMap());
      state = profile;
    } catch (e) {
      // Handle error
       print("Error updating profile: $e");
       rethrow;
    }
  }
  
  void clearProfile() {
    state = null;
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});

// Watch current user profile based on auth state
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  if (authState == null) return null;
  
  final notifier = ref.read(userProfileProvider.notifier);
  await notifier.loadProfile(authState.uid);
  return ref.watch(userProfileProvider);
});
