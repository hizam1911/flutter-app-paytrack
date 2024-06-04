import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytrack/pages/dashboard.dart';
import 'package:paytrack/pages/profile.dart';
import 'package:paytrack/pages/register.dart';
import 'package:paytrack/pages/recoverpassword.dart';
import 'package:paytrack/services/database_service.dart';
import 'package:fancy_password_field/fancy_password_field.dart';
import 'package:paytrack/services/local_notification_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  //textfiled controller
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FancyPasswordController fancyPasswordController = FancyPasswordController();
  bool vEmailField = false;
  bool vPasswordField = false;

  // @override
  // void dispose() {
  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    Future<bool> showExitPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exit App'),
          content: Text('Do you want to exit the app?'),
          actions:[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              //return false when click on "NO"
              child:Text('No'),
            ),

            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              //return true when click on "Yes"
              child:Text('Yes'),
            ),
          ],
        ),
      )??false; //if showDialogue had returned null, then return false
    }

    Future<bool> showLoginErrorPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Alert!'),
          content: Text('Please check your email and password again!'),
          actions:[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              //return false when click on "NO"
              child:Text('OK'),
            ),
          ],
        ),
      )??false; //if showDialogue had returned null, then return false
    }

    Future<bool> showEmailNotVerifiedPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Alert!'),
          content: Text('Your email is not verified yet! Please open your email and press the link given from Google.'),
          actions:[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              //return false when click on "NO"
              child:Text('OK'),
            ),
          ],
        ),
      )??false; //if showDialogue had returned null, then return false
    }

    Future<bool> showPermissionDeniedPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Alert!'),
          content: Text('You need to give permission for Alarm and Notification in order to continue using this application!'),
          actions:[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              //return false when click on "NO"
              child:Text('OK'),
            ),
          ],
        ),
      )??false; //if showDialogue had returned null, then return false
    }

    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) return;
          showExitPopup();
        }, //call function on back button press
        child:Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              title: Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              centerTitle: true,
              //elevation: 0,
            ),
            body: ListView(
              children: [
                Container(
                  height: 150.0,
                  width: 190.0,
                  padding: EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: Center(
                    child: Image.asset('images/PayTrack.png'),
                  ),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                    child: const Text(
                      'Email:',
                      style: TextStyle(fontSize: 20),
                    )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: vEmailField ? 'Value Cannot Be Empty' : null,
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: const Text(
                      'Password:',
                      style: TextStyle(fontSize: 20),
                    )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                  child: FancyPasswordField(
                    passwordController: fancyPasswordController,
                    controller: passwordController,
                    hasStrengthIndicator: false,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: vPasswordField ? 'Field Cannot Be Empty' : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                  child: Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          emailController.text = "";
                          passwordController.text = "";
                          setState(() {
                            vEmailField = false;
                            vPasswordField = false;
                          });

                          //register screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Register()),
                          );
                        },
                        child: const Text('Register', style: TextStyle(color: Colors.indigo),),
                      ),
                      const Text('|'),
                      TextButton(
                        onPressed: () {
                          emailController.text = "";
                          passwordController.text = "";
                          setState(() {
                            vEmailField = false;
                            vPasswordField = false;
                          });

                          //forgot password screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RecoverPassword()),
                          );
                        },
                        child: const Text('Forgot Password', style: TextStyle(color: Colors.indigo),),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                ),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(125, 0, 125, 0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[50],
                        ),
                        child: const Text('Sign In', style: TextStyle(color: Colors.indigo),),
                        onPressed: () async {
                          setState(() {
                            emailController.text.isEmpty ? vEmailField = true : vEmailField = false;
                            passwordController.text.isEmpty ? vPasswordField = true : vPasswordField = false;
                          });
                          //test
                          print(emailController.text);
                          print(passwordController.text);
                          if (vEmailField == false && vPasswordField == false) {
                            bool isAlarmNotificationPermissionGranted = await LocalNotificationService().allPermissionAllowed();

                            if (isAlarmNotificationPermissionGranted == true) {
                              User? user = await DatabaseService.loginUsingEmailPassword(email: emailController.text, password: passwordController.text, context: context);
                              print(user);

                              if (user != null) {
                                FirebaseAuth.instance.currentUser!.reload();
                                bool isEmailVerified = DatabaseService().checkEmailVerified();

                                if(isEmailVerified == true) {
                                  print("Email Verified");
                                  String tEmail = emailController.text;
                                  String tPass = passwordController.text;
                                  DatabaseService().updatePassUponLogin(tEmail, tPass);
                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                      builder: (context) => Dashboard()), (Route route) => false);
                                } else {
                                  print("Email Not Verified");
                                  user.sendEmailVerification();
                                  showEmailNotVerifiedPopup();
                                }
                              } else {
                                showLoginErrorPopup();
                              }
                            } else {
                              showPermissionDeniedPopup();
                            }
                          }
                        },
                      //old onPressed fx
                      // onPressed: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => Dashboard()),
                      //   );
                      //   // Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
                      //   //print(nameController.text);
                      //   //print(passwordController.text);
                      // },
                    )
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            )
        )
    );
  }
}