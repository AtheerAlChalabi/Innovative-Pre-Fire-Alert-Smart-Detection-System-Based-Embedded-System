import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sademiot/screens/create_account_screen.dart';

import '../model/user_model.dart';


class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  List<DataRow> listOfUsers=[];
  bool isLoading=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData()  {
    var getAllUsers = users.get();
   getAllUsers.asStream().listen((element) {
      for (DocumentSnapshot element in element.docs) {

      UserModel data=UserModel.fromJson(element.data()as Map);



        listOfUsers.add( DataRow(
          cells: <DataCell>[
            DataCell(Text(data.name.toString())),
            DataCell(Text(data.email.toString())),
            DataCell(GestureDetector(
                onTap: () {
                  selectedData = _scrollController.initialItem;

                  changeStatus(   element.id);
                },
                child:(FirebaseAuth.instance.currentUser?.uid==element.id)?const SizedBox(): Row(
                  children: [
                    Text(
                      data.status.toString(),
                      style: const TextStyle(color: Colors.blue),
                    ),
                    const SizedBox(
                      width: 20,
                    ),

                    IconButton(
                        onPressed: () {
                          listOfUsers.clear();
                          deleteUser(element.id);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        )),
                  ],
                ))),
          ],
        ));
      }
    }).onDone(() {

     setState(() {
       isLoading=false;
     });
   });

  }

  void deleteUser(String uid) async {
    // Initialize Firebase Admin SDK


    try {

      users.doc(uid).delete();
      getData();
      setState(() {

      });
      print('User with UID $uid deleted successfully.');
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("data ${users}");
    print(FirebaseAuth.instance.currentUser?.uid);
    print(FirebaseAuth.instance.currentUser?.uid.toString()==users.id.toString());
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            "DashBoard",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateAccountScreen())).then((value) =>
                  {
                    listOfUsers.clear(),
                    getData()});
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: const [
                      Text("add User"),
                      Icon(CupertinoIcons.add_circled_solid)
                    ],
                  ),
                ))
          ],
        ),
        body: (isLoading)?const Center(child: CircularProgressIndicator(),):SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 400,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dividerThickness: 1,
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Name',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Email',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                        ),
                      ),
                    ],
                    rows:  listOfUsers
                  ),
                ),
              )
            ],
          ),
        ));
  }

  int selectedData = 0;
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController();

  changeStatus(index) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                color: Color(0xffffffff),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xff999999),
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      print(index);

                      if(selectedData==0){
                        users.doc(index).set({"status":"Admin"},SetOptions(merge: true));
                      }else{
                        users.doc(index).set({"status":"User"},SetOptions(merge: true));
                      }
                      listOfUsers.clear();
                      getData();


                      Navigator.pop(context);
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                    child: const Text('Confirm'),
                  )
                ],
              ),
            ),
            Container(
              height: 320.0,
              color: const Color(0xfff7f7f7),
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (int value) {
                  selectedData = value;
                },
                scrollController: _scrollController,
                children: const [
                  Text(
                    "Admin",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Text(
                    "User",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],

                /* the rest of the picker */
              ),
            )
          ],
        );
      },
    );
  }
}
