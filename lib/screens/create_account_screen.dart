import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';


class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

bool isLoading=false;
class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');



  showAlertDialog(BuildContext context,text) {

    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        _emailController.clear();
        _passwordController.clear();
        Navigator.pop(context);

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Error",style: TextStyle(color: Colors.red),),
      content: Text(text.toString()),
      actions: [
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
  void _RegisterUser() async{
    String email = _emailController.value.text;
    String password = _passwordController.value.text;

    setState(() {
      isLoading=true;
    });
    // Here, you can add the logic to authenticate the user with your backend.
    // You can use APIs or any other authentication method.

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      addUser(id:userCredential.user!.uid ,name: _nameController.value.text,email:userCredential.user!.email  ,status:'User' );
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      reLogin();
      // Prompt the user to enter their email and password

// Create a credential

// Reauthenticate

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          isLoading=false;
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          isLoading=false;
        });
      }
    } catch (e) {
    }
  }
  Future<void> addUser({id,name,email,status}) {
    return users.doc(id)
        .set({
      'id': id,
      'email': email,
      'name': name,
      'status': status ,
      "isActive":true,
    },SetOptions(merge: true))
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
  void reLogin()async{
    var box = Hive.box('Auth');



    String emailh =  box.get('email');
    String passwordh = box.get('pass');
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailh,
          password: passwordh
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
      } else if (e.code == 'wrong-password') {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: 400,
              child: const Text("Alert System",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 20,

            ),
            Container(
              alignment: Alignment.center,
              width: 400,
              child: const Text("Login",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            (isLoading)?const Center(child: CircularProgressIndicator(),):TextButton(
              onPressed:    _RegisterUser,
              child: const Text('Create'),
            ),

          ],
        ),
      ),
    );
  }
}