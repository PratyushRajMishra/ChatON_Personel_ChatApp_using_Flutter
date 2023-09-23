import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel{
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  List<dynamic>? users;
  DateTime? createdon;
  DateTime? lastMsgtime;

  ChatRoomModel({this.chatroomid, this.participants, this.lastMessage, this.users, this.createdon, this.lastMsgtime});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid= map["chatroomid"];
    participants= map["participants"];
    lastMessage= map["lastMessage"];
    users= map["users"];
    final Timestamp? timestamp = map["createdon"];
    createdon = timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch) : null;
    lastMsgtime = map["lastMsgtime"]?.toDate();
  }

  Map<String, dynamic> toMap() {
    return{
      "chatroomid": chatroomid,
      "participants": participants,
      "lastMessage": lastMessage,
      "users": users,
      "createdon": createdon,
      "lastMsgtime": lastMsgtime,
    };
  }
}