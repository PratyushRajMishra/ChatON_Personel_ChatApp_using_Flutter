class UserModel {
  String? uid;
  String? fullname;
  String? about;
  String? mobile;
  String? email;
  String? profilepic;


  UserModel({
    this.uid,
    this.fullname,
    this.email,
    this.profilepic,
    this.mobile,
    this.about,});


  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
    about = map["about"];
    mobile = map["mobile"];

  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "about": about,
      "mobile": mobile,
      "email": email,
      "profilepic": profilepic,
    };
  }
}
