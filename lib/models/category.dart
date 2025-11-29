class Category {
  final int id;
  final String name;
  final int fatherId;
  final int parentId;

  Category({
    required this.id,
    required this.name,
    required this.fatherId,
    required this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      fatherId: json['father_id'] as int,
      parentId: json['parent_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'father_id': fatherId,
      'parent_id': parentId,
    };
  }
}