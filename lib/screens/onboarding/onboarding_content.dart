import 'package:flutter/material.dart';

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
  });
}

class OnboardingData {
  static const List<OnboardingContent> pages = [
    // Page 1: Welcome & Discovery
    OnboardingContent(
      title: 'Find Your Home',
      description: 'Discover rental properties in Arunachal Pradesh with APST compatibility and cultural filtering.',
      icon: Icons.home_outlined,
      backgroundColor: Color(0xFFFFF4E6),
    ),

    // Page 2: Smart Search
    OnboardingContent(
      title: 'Smart Search',
      description: 'Filter properties by tribe, profession, and location preferences for perfect compatibility.',
      icon: Icons.search_outlined,
      backgroundColor: Color(0xFFFFE6F2),
    ),

    // Page 3: Easy Management
    OnboardingContent(
      title: 'Easy Management',
      description: 'Track payments, manage subscriptions, and handle rental agreements digitally.',
      icon: Icons.credit_card_outlined,
      backgroundColor: Color(0xFFE6F7FF),
    ),
  ];

  static int get pageCount => pages.length;

  static OnboardingContent getPage(int index) {
    if (index < 0 || index >= pages.length) {
      throw ArgumentError('Invalid page index: $index');
    }
    return pages[index];
  }
}