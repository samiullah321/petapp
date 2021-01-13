

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import "package:flutter/material.dart";
import 'package:e_shop/Config/config.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
Stream<QuerySnapshot>  chatMessagesStream;
String poster="Loading...";
String purl;
final _controller = ScrollController();
Future addConversationMessages(String chatroomid, messageMap) async{
  await Firestore.instance
      .collection("chatroom")
      .document(chatroomid)
      .collection("chats").document(DateTime.now().millisecondsSinceEpoch.toString())
      .setData(messageMap).catchError((e){
    print(e.toString());
  });


}
getConversationMessages(String chatroomid) async{


  return Firestore.instance
      .collection("chatroom")
      .document(chatroomid)
      .collection("chats")
      .orderBy('time')
      .snapshots();


}
String nextuserid ;
class ConversationScreen extends StatefulWidget {

  final String chatroomid;
  final String userid;
  final String poster;
  final String phone;
  final String posteremail;
  final String posterurl;
  ConversationScreen({this.chatroomid,this.userid,this.poster,this.phone,this.posteremail,this.posterurl});
  _ConversationScreenState createState() => _ConversationScreenState();

}

class _ConversationScreenState extends State<ConversationScreen> {





  @override
  void initState() {
    purl=widget.posterurl;
    setState(() {

      initalrun();
    });



    super.initState();
  }

  Future initalrun()

  async {


    DocumentSnapshot variable = await petadoptapp.firestore.collection("users").document(widget.poster).get();


    setState(() {
      poster=variable.data['name'];
    });
  }
  void call(String number,String email,String text)
  { if(text=="Phone")
  { launch("tel:$number");}
  if(text=="Message")
  { launch("sms:$number");}
  if(text=="Email")
  {launch("mailto:$email");}






  }



  TextEditingController messageController = new TextEditingController();
  Widget build(BuildContext context) {
    Timer(
      Duration(seconds: 1),
          () => _controller.animateTo(
            _controller.position.maxScrollExtent+80,
            duration: Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
          ),
    );
    return Scaffold(
        appBar: AppBar(

          brightness: Brightness.dark,
          //centerTitle: true,
          backgroundColor: Colors.orangeAccent,
          title:  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              // CircleAvatar(
              //
              //   backgroundImage: NetworkImage(
              //     widget.posterurl,
              //   ),
              // ),
              Container(
                  padding: const EdgeInsets.all(5), child: Text(poster,style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ) ,))
            ],

          ),
          actions:
          <Widget>[GestureDetector(
            onTap: (){
              showModal();
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(Icons.call,color: Colors.white,),
            ),
          ),],
          // <Widget>[IconButton(icon: Icon(Icons.phone),color: Colors.white, onPressed: ()=>{call(widget.phone)},),
          //   IconButton(icon: Icon(Icons.message_rounded),color: Colors.white, onPressed: ()=>{sendSms(widget.phone)},),
          //   IconButton(icon: Icon(Icons.email_rounded), color: Colors.white,onPressed: ()=>{sendEmail(widget.posteremail)},),],
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              }),

        ),
        body: Container(
          //color: Color.fromRGBO(29, 28, 29, 0.9),
          color:  Color(0xFFF6F6F6),
          child:Stack(
            children: [
              ChatMessageList(),

              Container(
                alignment:Alignment.bottomCenter,width: MediaQuery
                  .of(context)
                  .size
                  .width,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 70,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 20,),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Send a message..',

                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        iconSize: 25,
                        color: Colors.grey,
                        onPressed: () {sendmessage();},
                      ),
                    ],
                  ),
                ),

              ),
            ],
          ),)
    );
  }


  Widget ChatMessageList(){


    return StreamBuilder<QuerySnapshot>(

      stream: Firestore.instance
          .collection("chatroom").document(widget.chatroomid).collection("chats").orderBy("time", descending: false)
          .snapshots(),

      builder: (context,  snapshot){
        return
          snapshot.hasData ?

          ListView.builder(
              itemCount: snapshot.data.documents.length,
              controller: _controller,
              padding: EdgeInsets.all(20),
              itemBuilder: (context, index){
                bool isSameUser=false;

                print(index);
                if(index<snapshot.data.documents.length-1)
                { isSameUser = snapshot.data.documents[index].data["sendBy"]==snapshot.data.documents[index+1].data["sendBy"];}
                else{
                  isSameUser = true;
                }
                bool islast=false;
                if(index==snapshot.data.documents.length-1)
                {
                  islast=true;
                }


                //print(snapshot.data.documents[index].data["message"]);
                //String send=snapshot.data.documents[index].data["sendBy"];
                //print("previd: $prevuserid current id: $send");
                return MessageTile(
                  message: snapshot.data.documents[index].data["message"],
                  sendByMe: widget.userid == snapshot.data.documents[index].data["sendBy"],
                  isSameUser :  isSameUser,
                  time : snapshot.data.documents[index].data["time"],
                  islast : islast,

                );
              })
              :  Center(
            child: circularProgress(),
          );
      },
    );



  }
  Future sendmessage() async{




    if(messageController.text.isNotEmpty)
    {
      Map<String, dynamic> chatmessageMap={
        "message" : messageController.text,
        "sendBy" : widget.userid,
        'time': DateTime.now(),
      };
      print(chatmessageMap);
      await addConversationMessages(widget.chatroomid, chatmessageMap);
    }

    setState(() {
      messageController.text="";
    });

  }

  void showModal(){
    showModalBottomSheet(
        context: context,
        builder: (context){


          List<SendMenuItems> menuItems = [
            SendMenuItems(text: "Phone", icons: Icons.phone, color: Colors.amber, ),
            SendMenuItems(text: "Message", icons: Icons.message_rounded, color: Colors.blue),
            SendMenuItems(text: "Email", icons: Icons.email_rounded, color: Colors.orange),
          ];
          return Container(
            height: MediaQuery.of(context).size.height/2.8,
            color: Color(0xff737373),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 16,),
                  Center(
                    child: Container(
                      height: 4,
                      width: 50,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(height: 10,),
                  ListView.builder(
                    itemCount: menuItems.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index){
                      return GestureDetector(
                        onTap: (){
                          call(widget.phone,widget.posteremail,menuItems[index].text);
                        },
                        child:Container(
                          padding: EdgeInsets.only(top: 10,bottom: 10),
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: menuItems[index].color.shade50,
                              ),
                              height: 50,
                              width: 50,
                              child: IconButton(icon: Icon(menuItems[index].icons) ,color: menuItems[index].color.shade400,iconSize: 20, onPressed: ()=>{call(widget.phone,widget.posteremail,menuItems[index].text),},),
                            ),
                            title: Text(menuItems[index].text),
                          ),
                        ),);
                    },
                  )
                ],
              ),
            ),
          );
        }
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final bool isSameUser;
  final Timestamp time;
  final bool islast;


  MessageTile({@required this.message, @required this.sendByMe, @required this.isSameUser, @required this.time, @required this.islast});


  @override
  Widget build(BuildContext context) {
    if (sendByMe) {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF01afbd),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          !isSameUser
              ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                DateFormat.yMEd().add_jms().format(time.toDate()),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(
                    petadoptapp.sharedPreferences.getString(petadoptapp.userAvatarUrl),

                  ),
                ),
              ),
            ],
          )
              : islast ?Container(
            child: SizedBox(height: 70,),
          ) :Container(
            child: null,
          ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xffFFA62B) ,
                //color: Color.fromRGBO(0, 189,107, 0.7 ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          !isSameUser
              ? Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(
                    purl,

                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                DateFormat.yMEd().add_jms().format(time.toDate()),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ],
          )
              : islast ?Container(
            child: SizedBox(height: 70,),
          ) : Container(
            child: null,
          ),
        ],
      );
    }
  }
}



class SendMenuItems{
  String text;
  IconData icons;
  MaterialColor color;
  SendMenuItems({@required this.text,@required this.icons,@required this.color ,});
}
