import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytrack/services/firebase_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecoverPassword extends StatefulWidget {
  const RecoverPassword({super.key});

  @override
  State<RecoverPassword> createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
  final _key = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  static final auth = FirebaseAuth.instance;
  static late AuthStatus _status;
  bool vEmailField = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<AuthStatus> resetPassword({required String email}) async {
    await auth
        .sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful)
        .catchError(
            (e) => _status = AuthExceptionHandler.handleAuthException(e));

    return _status;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true, //call function on back button press
        child:Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: Colors.white,
              title: Text('Reset Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              centerTitle: true,
              //elevation: 0,
            ),
            body: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: const Text(
                            'Email:',
                            style: TextStyle(fontSize: 20),
                          )
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                              labelText: 'Email',
                              errorText: vEmailField ? 'Field Cannot Be Empty' : null,
                          ),
                        ),
                      ),
                      Container(
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(125, 10, 125, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[50],
                            ),
                            child: const Text('Send Link', style: TextStyle(color: Colors.indigo),),
                            onPressed: () async {
                              setState(() {
                                emailController.text.isEmpty ? vEmailField = true : vEmailField = false;
                              });

                              if (vEmailField == false) {
                                final _status = await resetPassword(email: emailController.text.trim());
                                if (_status == AuthStatus.successful) {
                                  //your logic
                                } else {
                                  //your logic or show snackBar with error message
                                }

                                // Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
                                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                                print('Codes Send');
                                //print(nameController.text);
                                //print(passwordController.text);
                              }
                            },
                          )
                      ),
                      SizedBox(
                        height: 20,
                      ),

                    ],
                  ),
                ),
              ],
            )
        )
    );
  }
}

