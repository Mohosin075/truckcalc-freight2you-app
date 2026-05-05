class AllReviewModelByEventId {
  final String id;
  final String eventId;
  final String reviewerName;
  final String reviewerId;
  final String reviewerImage;
  final double rating;
  final String review;
  final DateTime createdAt;

  AllReviewModelByEventId({
    required this.id,
    required this.eventId,
    required this.reviewerName,
    required this.reviewerId,
    required this.reviewerImage,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  factory AllReviewModelByEventId.fromJson(Map<String, dynamic> json) {
    return AllReviewModelByEventId(
      id: json['_id'] ?? '',
      eventId: json['eventId'] ?? '',
      reviewerName: json['reviewer'] != null
          ? json['reviewer']['name'] ?? 'Anonymous'
          : 'Anonymous',
      reviewerId: json['reviewer'] != null
          ? (json['reviewer']['id'] ?? json['reviewer']['_id'] ?? '')
          : '',
      reviewerImage: json['reviewer'] != null
          ? (json['reviewer']['profile'] ?? json['reviewer']['image'] ?? json['reviewer']['profileImage'] ?? '')
          : '',
      rating: (json['rating'] as num).toDouble(),
      review: json['review'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
