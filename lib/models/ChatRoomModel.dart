class ChatRoomModel{
  String? chatroomid;
  Map<String, dynamic>? praticipants;
  String? lastMessage;
  List<dynamic>? users;
  DateTime? creatdon;

  ChatRoomModel({this.chatroomid, this.praticipants, this.lastMessage, this.users, this.creatdon});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid= map["chatroomid"];
    praticipants= map["participants"];
    lastMessage= map["lastMessage"];
    users= map["users"];
    creatdon= map["createdon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return{
      "chatroomid": chatroomid,
      "participants": praticipants,
      "lastMessage": lastMessage,
      "users": users,
      "createdon": creatdon,
};
}
}