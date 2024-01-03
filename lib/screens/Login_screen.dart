import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sademiot/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

bool isLoading=false;
class _LoginScreenState extends State<LoginScreen> {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    @override
  void initState() {
    // TODO: implement initState
    super.initState();

      isLoading=false;

  }
  void _login() async{

    var box = await Hive.openBox('Auth');

    await box.put('email', _emailController.value.text.toString());
    await box.put('pass', _passwordController.value.text.toString());




    setState(() {
      isLoading=true;
    });
    String email = _emailController.value.text;
    String password = _passwordController.value.text;

    // Here, you can add the logic to authenticate the user with your backend.
    // You can use APIs or any other authentication method.

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );

     
       Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const HomeScreen()), (route) => false);
       // reLogin();
      // Prompt the user to enter their email and password

// Create a credential

// Reauthenticate

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showAlertDialog(context,"user not found");
        setState(() {
          isLoading=false;
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          isLoading=false;
          showAlertDialog(context,"re-check Email or password");
        });
      }else{
        setState(() {
          isLoading=false;
          showAlertDialog(context,"re-check Email or password");
        });
      }
    } catch (e) {
    }

  }
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

      // Here, you can add the logic to authenticate the user with your backend.
      // You can use APIs or any other authentication method.

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password
        );
        addUser(id:userCredential.user!.uid ,email:userCredential.user!.email  ,status:'Admin' );
        // reLogin();
        // Prompt the user to enter their email and password

// Create a credential

// Reauthenticate

      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
        } else if (e.code == 'email-already-in-use') {
        }
      } catch (e) {
      }
    }
    Future<void> addUser({id,email,status}) {
       return users.doc(id)
          .set({
        'id': id,
        'email': email,
        'status': status ,
        "isActive":true,
      },SetOptions(merge: true))
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }
  void reLogin()async{
    String emailh = 'ali@admin.com';
    String passwordh = '12341234';
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailh,
          password: passwordh
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
      } else if (e.code == 'wrong-password') {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
              onPressed:    _login,
              child: const Text('Login'),
            ),

          ],
        ),
      ),
    );
  }
}