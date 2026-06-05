import 'package:flutter/material.dart';

/// Helper function to resolve profile image URLs
/// Handles both local assets (starting with 'assets/') and network URLs.
ImageProvider? getProfileImageProvider(String? photoUrl) {
  if (photoUrl == null || photoUrl.isEmpty) return null;
  if (photoUrl.startsWith('assets/')) {
    return AssetImage(photoUrl);
  }
  return NetworkImage(photoUrl);
}
