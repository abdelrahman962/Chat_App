import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image }

class Message {
  String? senderID;
  String? content;
  MessageType? messageType;
  Timestamp? sentAt;
  bool? isRead;
  Timestamp? readAt;

  Message({
    required this.senderID,
    required this.content,
    required this.messageType,
    required this.sentAt,
    this.isRead = false,
    this.readAt,
  });

  Message.fromJson(Map<String, dynamic> json) {
    senderID = json['senderID'];
    content = json['content'];
    sentAt = json['sentAt'];
    messageType = MessageType.values.byName(json['messageType']);
    isRead = json['isRead'] ?? false;
    readAt = json['readAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderID'] = senderID;
    data['content'] = content;
    data['sentAt'] = sentAt;
    data['messageType'] = messageType!.name;
    data['isRead'] = isRead;
    data['readAt'] = readAt;
    return data;
  }
}
