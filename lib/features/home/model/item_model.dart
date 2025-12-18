class ItemModel {
  final String itemId;
  final String title;
  final String category;
  final String location;
  final DateTime foundDate;
  final String status; // 'FOUND' or 'LOST'
  final String? description;
  final List<String>? imageUrls;
  final String? reportedBy;
  final String? reportedByName;
  final String? reportedByPhone;
  final DateTime? createdAt;

  ItemModel({
    required this.itemId,
    required this.title,
    required this.category,
    required this.location,
    required this.foundDate,
    required this.status,
    this.description,
    this.imageUrls,
    this.reportedBy,
    this.reportedByName,
    this.reportedByPhone,
    this.createdAt,
  });

  // Convert ItemModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'title': title,
      'category': category,
      'location': location,
      'foundDate': foundDate.toIso8601String(),
      'status': status,
      'description': description ?? '',
      'imageUrls': imageUrls ?? [],
      'reportedBy': reportedBy ?? '',
      'reportedByName': reportedByName ?? '',
      'reportedByPhone': reportedByPhone ?? '',
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Create ItemModel from Firestore document
  factory ItemModel.fromFirestore(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return ItemModel(
      itemId: map['itemId'] ?? documentId,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      foundDate: map['foundDate'] != null
          ? DateTime.parse(map['foundDate'])
          : DateTime.now(),
      status: map['status'] ?? 'FOUND',
      description: map['description'],
      imageUrls: map['imageUrls'] != null
          ? List<String>.from(map['imageUrls'])
          : null,
      reportedBy: map['reportedBy'],
      reportedByName: map['reportedByName'],
      reportedByPhone: map['reportedByPhone'],
      createdAt: map['createdAt']?.toDate(),
    );
  }
}

