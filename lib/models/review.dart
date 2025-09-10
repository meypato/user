class Review {
  final String id;
  final String buildingId;
  final String reviewerId;
  final String? subscriptionId;
  final int rating;
  final String? reviewText;
  final List<String> photosUrl;
  final bool isVerified;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.buildingId,
    required this.reviewerId,
    this.subscriptionId,
    required this.rating,
    this.reviewText,
    this.photosUrl = const [],
    this.isVerified = false,
    this.helpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    List<String> photosList = [];
    if (json['photos_url'] != null) {
      if (json['photos_url'] is List) {
        photosList = (json['photos_url'] as List).map((e) => e.toString()).toList();
      }
    }

    return Review(
      id: json['id'] as String,
      buildingId: json['building_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      subscriptionId: json['subscription_id'] as String?,
      rating: json['rating'] as int,
      reviewText: json['review_text'] as String?,
      photosUrl: photosList,
      isVerified: json['is_verified'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_id': buildingId,
      'reviewer_id': reviewerId,
      'subscription_id': subscriptionId,
      'rating': rating,
      'review_text': reviewText,
      'photos_url': photosUrl,
      'is_verified': isVerified,
      'helpful_count': helpfulCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Review copyWith({
    int? rating,
    String? reviewText,
    List<String>? photosUrl,
    bool? isVerified,
    int? helpfulCount,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id,
      buildingId: buildingId,
      reviewerId: reviewerId,
      subscriptionId: subscriptionId,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      photosUrl: photosUrl ?? this.photosUrl,
      isVerified: isVerified ?? this.isVerified,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get hasReviewText => reviewText != null && reviewText!.trim().isNotEmpty;

  bool get hasPhotos => photosUrl.isNotEmpty;

  bool get isFromTenant => subscriptionId != null;

  bool get isHighRating => rating >= 4;

  bool get isLowRating => rating <= 2;

  bool get isMediumRating => rating == 3;

  String get ratingText {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Unrated';
    }
  }

  String get starsDisplay => '★' * rating + '☆' * (5 - rating);

  String get formattedCreatedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = difference.inDays ~/ 365;
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = difference.inDays ~/ 30;
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String get helpfulText {
    if (helpfulCount == 0) return 'No helpful votes';
    if (helpfulCount == 1) return '1 person found this helpful';
    return '$helpfulCount people found this helpful';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Review{id: $id, buildingId: $buildingId, rating: $rating, isVerified: $isVerified}';
  }
}