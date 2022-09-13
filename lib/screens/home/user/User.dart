class User {
  String id;
  String authUserId;
  String name;
  String email;
  String? mobileNumber;
  String? avatar;
  double? rating;
  String comment;
  bool isRated;
  bool isFollowed;

  User(this.id, this.authUserId,this.name, this.email, this.mobileNumber, this.avatar, this.rating,this.comment,this.isRated, this.isFollowed);

}