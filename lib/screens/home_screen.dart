import 'package:alarmplayer/alarmplayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sademiot/model/data_info_model.dart';
import 'package:sademiot/screens/Login_screen.dart';
import 'package:sademiot/screens/dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chart_data_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

late DataInfo dataInfo;
Alarmplayer alarmplayer = Alarmplayer();
DatabaseReference starCountRef = FirebaseDatabase.instance.ref('rInfo');
var box;
class _HomeScreenState extends State<HomeScreen> {
  var lastData;
  List myOrderData = [];
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    // TODO: implement initState
    alarmplayer.StopAlarm();

    getData();
    userInfo();
    super.initState();
  }
bool isLoading=true;
  userInfo()async{
      box =  await Hive.openBox('Auth');
   var info= users.doc(FirebaseAuth.instance.currentUser!.uid).get();
    info.then(( DocumentSnapshot value){
    Map? data= value.data() as Map;

      box.put('status',data["status"]);

    setState(() {
      isLoading=false;
    });
    });


  }

  getData() {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('info');
    starCountRef.onValue.listen((DatabaseEvent event) {
      Map data = event.snapshot.value as Map;

      myOrderData = data.entries.toList();
      myOrderData.sort((a, b) {
        return a.key.compareTo(b.key);
      }); // inplace sort
      setState(() {
        lastData = myOrderData.last;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:( isLoading)?const Center(child: CircularProgressIndicator(),):SingleChildScrollView(
        physics:const BouncingScrollPhysics(),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBar(),
            Container(
              margin: const EdgeInsets.only(  left: 20),
              width: 200,
              child: const Text("Running Status",
                  style: TextStyle(
                      color: Color(0xFF414141),
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  ItemContainer(title: 'Main Circuit', appBarColor: Colors.black),
                  SizedBox(
                    width: 10,
                  ),
                  ItemContainer2(title: 'Data Center Building', appBarColor: Colors.black),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  ItemContainer2(title: 'Administration Building', appBarColor: Colors.black),
                  SizedBox(
                    width: 10,
                  ),
                  ItemContainer2(title: 'Laboratory Building', appBarColor: Colors.black),
                ],
              ),
            ),
            const ChartData(

            ),
            const SizedBox(height: 100,),
          ],
        ),
      ),
    );
  }
}

class AppBar extends StatelessWidget {
  const AppBar({Key? key}) : super(key: key);
  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = TextButton(
      child: const Text("logout",style: TextStyle(color: Colors.red),),
      onPressed: () {
        FirebaseAuth.instance.signOut();
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen(),), (route) => false);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Logout"),
      content: const Text("Are you sure you want to leave?"),
      actions: [
        cancelButton,
        okButton,

      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50, left: 20),
      child: Column(
        children: [
       Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center
        ,children: [
         Container(
           alignment: Alignment.center,

           child: const Text("Alert System",
               style: TextStyle(
                   color: Colors.black,
                   fontSize: 20,
                   fontWeight: FontWeight.bold)),
         ),
         Row(
           children: [
             ( box.get('status').toString()=="User")?const SizedBox():  GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DashBoardScreen(),));

              },
              child:  const CircleAvatar(
                child: Icon(Icons.dashboard),
              ),
            ),
             const SizedBox(width: 15,),
             GestureDetector(
               onTap: (){
                 showAlertDialog(context);
               },
               child:  const CircleAvatar(
                 backgroundColor: Colors.red,
                 child: Icon(Icons.logout,color: Colors.white,),
               ),
             ),
             const SizedBox(width: 15,),
           ],
         )
       ],),
          const SizedBox(
            height: 20,

          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                child: Text(
                  "Dashboard",
                  style: TextStyle(
                      color: Color(0xFF3894FF),
                      fontSize: 24,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        sosCall();
                      },
                      icon: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 45,
                        child: Icon(
                          Icons.sos,
                          color: Colors.white,
                        ),
                      )),
                  IconButton(
                      onPressed: () {
                       bossCall();
                      },
                      icon: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 45,
                        child: Icon(
                          Icons.work,
                          color: Colors.white,
                        ),
                      )),
                  IconButton(
                      onPressed: () {
                        fireDepartmentCall();

                      },
                      icon: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 45,
                        child: Icon(
                          Icons.fire_truck,
                          color: Colors.white,
                        ),
                      )),
                  const SizedBox(width: 20,),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> sosCall() async {
    await launchUrl( Uri.parse("tel:911"));
  }

  Future<void> fireDepartmentCall() async {
    await launchUrl( Uri.parse("tel:115"));
  }
  Future<void> bossCall() async {
    await launchUrl( Uri.parse("tel:07703964209"));
  }
}

class ItemContainer extends StatelessWidget {
  final Color appBarColor;
  final String title;

  const ItemContainer(
      {Key? key, this.appBarColor = Colors.black, this.title = "title"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          height: 180,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4))
              ]),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                height: 40,
                decoration: BoxDecoration(
                    color: appBarColor,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10))),
                alignment: Alignment.centerLeft,
                width: double.infinity,
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              StreamBuilder(
                stream: starCountRef.onValue,
                builder: (context, snapshot) {

                  if (snapshot.hasData) {
                    Map data = snapshot.data?.snapshot.value as Map;
                    int temp = int.parse(data["Amp"].replaceAll(RegExp(r'[^0-9]'),''));


                    return Column(
                      children: [
                        TextValueData(
                          title: 'Gas sensor',
                          data: data["Gaz"].toString(),
                          color: (int.parse(data["Gaz"].toString()) >= 300)
                              ? Colors.red
                              : (int.parse(data["Gaz"].toString()) <= 299 &&
                                      int.parse(data["Gaz"].toString()) >= 270)
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        TextValueData(
                          title: 'Smoke sensor',
                          data: data["Smk"].toString(),
                          color: (int.parse(data["Smk"].toString()) >= 400)
                              ? Colors.red
                              : (int.parse(data["Smk"].toString()) <= 399 &&
                                      int.parse(data["Smk"].toString()) >= 359)
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        TextValueData(
                          title: 'iTemp sensor',
                          data: data["iTmp"].toString(),
                          color: (int.parse(data["iTmp"].toString()) >= 55)
                              ? Colors.red
                              : (int.parse(data["iTmp"].toString()) <= 54 &&
                                      int.parse(data["iTmp"].toString()) >= 50)
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        TextValueData(
                          title: 'oTemp sensor',
                          data: data["oTmp"].toString(),
                          color: (int.parse(data["oTmp"].toString()) >= 300)
                              ? Colors.red
                              : (int.parse(data["oTmp"].toString()) <= 299 &&
                                      int.parse(data["oTmp"].toString()) >= 270)
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        TextValueData(
                          title: 'Amp sensor',
                          data: (temp-15<0)?0.toString():(temp-15).toString(),
                          color: (int.parse((temp-15).toString()) >= 90)
                              ? Colors.red
                              : (int.parse((temp-15).toString()) <= 89 &&
                                      int.parse((temp-15).toString()) >= 81)
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              )
            ],
          )),
    );
  }
}
class ItemContainer2 extends StatelessWidget {
  final Color appBarColor;
  final String title;

  const ItemContainer2(
      {Key? key, this.appBarColor = Colors.black, this.title = "title"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          height: 180,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [

                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4))
              ]),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                height: 40,
                decoration: BoxDecoration(
                    color: appBarColor,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10))),
                alignment: Alignment.centerLeft,
                width: double.infinity,
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              StreamBuilder(
                stream: starCountRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map data = snapshot.data?.snapshot.value as Map;
                    return Column(
                      children: const [
                        TextValueData(
                          title: 'Gas sensor',
                          color:Colors.black, data: '0',
                        ),
                        TextValueData(
                          title: 'Smoke sensor',
                           color:Colors.black, data: '0',

                        ),
                        TextValueData(
                          title: 'iTemp sensor',
                          color:Colors.black, data: '0',
                        ),
                        TextValueData(
                          title: 'oTemp sensor',
                          color:Colors.black, data: '0',
                        ),
                        TextValueData(
                          title: 'Amp sensor',
                          color:Colors.black, data: '0',
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              )
            ],
          )),
    );
  }
}
class TextValueData extends StatelessWidget {
  final String title;
  final String data;
  final Color color;

  const TextValueData(
      {Key? key, this.title = "", required this.data, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          Text(data,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


}
