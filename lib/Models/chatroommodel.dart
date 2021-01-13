

class ChatModel {
  String chatroomid;
  String users1;
  String users2;


  ChatModel(
      {this.chatroomid,
        this.users1,
        this.users2,

      });

  ChatModel.fromJson(Map<String, dynamic> json) {
    chatroomid = json['chatroomid'];
    users1 = json['users1'];
    users2 = json['users2'];



  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatroomid'] = this.chatroomid;
    data['users1'] = this.users1;
    data['users2'] = this.users2;

    return data;
  }
}

