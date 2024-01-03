class UserModel {
  String? id;
  bool? isActive;
  String? email;
  String? status;
  String? name;

  UserModel({this.id, this.isActive, this.email, this.status});

  UserModel.fromJson(json) {
    id = json['id'];
    isActive = json['isActive'];
    email = json['email'];
    status = json['status'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['isActive'] = this.isActive;
    data['email'] = this.email;
    data['status'] = this.status;
    data['name'] = this.name;
    return data;
  }
}