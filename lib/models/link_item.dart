class LinkItem {
  final String fileName;
  final String url;
  final DateTime createdAt;

  LinkItem({
    required this.fileName,
    required this.url,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'url': url,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LinkItem.fromJson(Map<String, dynamic> json) => LinkItem(
        fileName: json['fileName'],
        url: json['url'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
