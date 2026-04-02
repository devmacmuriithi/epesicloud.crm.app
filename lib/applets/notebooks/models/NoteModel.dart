import 'dart:convert';

NoteModel noteModelFromJson(String str) => NoteModel.fromJson(json.decode(str));

String noteModelToJson(NoteModel data) => json.encode(data.toJson());

class NoteModel {
    String? id;
    String? name;
    String? content;
    String? userId;
    String? collectionId;
    DateTime? createdAt;
    DateTime? updatedAt;

    NoteModel({
        this.id,
        this.name,
        this.content,
        this.userId,
        this.collectionId,
        this.createdAt,
        this.updatedAt,
    });

    factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json["id"]?.toString(),
        name: json["name"],
        content: json["content"],
        userId: json["userId"]?.toString() ?? json["user_id"]?.toString(),
        collectionId: json["collectionId"]?.toString() ?? json["collection_id"]?.toString(),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "content": content,
        "userId": userId,
        "collectionId": collectionId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
    };
}
