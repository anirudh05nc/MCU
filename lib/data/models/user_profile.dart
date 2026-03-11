
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String address;
  final String profileImageUrl;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.address,
    required this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
  }
}
