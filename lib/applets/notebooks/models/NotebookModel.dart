
import 'dart:convert';

NotebookModel notebookModelFromJson(String str) => NotebookModel.fromJson(json.decode(str));

String notebookModelToJson(NotebookModel data) => json.encode(data.toJson());

class NotebookModel {
    String? id;
    String? title;
    String? content;
    String? userId;
    DateTime? createdAt;
    DateTime? updatedAt;

    NotebookModel({
        this.id,
        this.title,
        this.content,
        this.userId,
        this.createdAt,
        this.updatedAt,
    });

    factory NotebookModel.fromJson(Map<String, dynamic> json) => NotebookModel(
        id: json["id"]?.toString(),
        title: json["title"] ?? json["name"],
        content: json["content"],
        userId: json["userId"]?.toString() ?? json["user_id"]?.toString(),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "userId": userId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
    };
}
