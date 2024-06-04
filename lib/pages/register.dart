import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paytrack/services/database_service.dart';
import 'package:fancy_password_field/fancy_password_field.dart';
import 'package:paytrack/pages/login.dart';

List lGender = ["Male", "Female"];

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //textfiled controller
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phonenumController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  FancyPasswordController fancyPasswordController = FancyPasswordController();
  FancyPasswordController fancyConfirmPasswordController = FancyPasswordController();

  bool vEmailField = false;
  bool vUsernameField = false;
  bool vAgeField = false;
  bool vPhoneNumField = false;
  bool vPasswordField = false;
  bool vConfirmPasswordField = false;
  String dropdownGenderValue = lGender.first;

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    phonenumController.dispose();
    genderController.dispose();
    passwordController.dispose();
    fancyPasswordController.dispose();
    confirmPasswordController.dispose();
    fancyConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Future<bool> showPasswordMismatchPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Alert!'),
          content: Text('The password is mismatch!'),
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

    Future<bool> showPasswordMatchEmailPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Alert!'),
          content: Text('The password cannot be the same as your email address!'),
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

    Future<bool> showPasswordNotSecurePopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Alert!'),
          content: Text('The password is not secure enough!'),
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

    Future<bool> showUserExistPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Alert!'),
          content: Text('The email already exist!'),
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

    Future<bool> showVerifyEmailAlertPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success!'),
          content: Text('A verification link has been sent to your email. You need to verify your email before you are allowed to use the system.'),
          actions:[
            ElevatedButton(
              onPressed: () {
                DatabaseService().signOut();
                Navigator.of(context, rootNavigator: true)
                    .pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const Login();
                    },
                  ),
                      (_) => false,
                );
              },
              child:Text('OK'),
            ),
          ],
        ),
      )??false; //if showDialogue had returned null, then return false
    }

    return PopScope(
        canPop: true, //call function on back button press
        child:Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: Colors.white,
              title: Text('Register', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              centerTitle: true,
              //elevation: 0,
            ),
            body: ListView(
              shrinkWrap: true,
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                      errorText: vEmailField ? 'Field Cannot Be Empty' : null,
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: const Text(
                      'Username:',
                      style: TextStyle(fontSize: 20),
                    )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      errorText: vUsernameField ? 'Field Cannot Be Empty' : null,
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: const Text(
                      'Phone No.:',
                      style: TextStyle(fontSize: 20),
                    )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: phonenumController,
                    decoration: InputDecoration(
                      labelText: 'Phone No.',
                      errorText: vPhoneNumField ? 'Field Cannot Be Empty' : null,
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: const Text(
                      'Age:',
                      style: TextStyle(fontSize: 20),
                    )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      errorText: vAgeField ? 'Field Cannot Be Empty' : null,
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: const Text(
                      'Gender:',
                      style: TextStyle(fontSize: 20),
                    )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: DropdownMenu<String>(
                    width: MediaQuery.of(context).size.width * 0.45,
                    initialSelection: lGender.first,
                    controller: genderController,
                    onSelected: (String? value) {
                      // This is called when the user selects an item.
                      // print(genderController.text);
                      setState(() {
                        dropdownGenderValue = value!;
                      });
                    },
                    dropdownMenuEntries: lGender.map<DropdownMenuEntry<String>>((var value) {
                      return DropdownMenuEntry<String>(value: value, label: value);
                    }).toList(),
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
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: vPasswordField ? 'Field Cannot Be Empty' : null,
                    ),
                    validationRules: {
                      DigitValidationRule(),
                      UppercaseValidationRule(),
                      LowercaseValidationRule(),
                      SpecialCharacterValidationRule(),
                      MinCharactersValidationRule(6),
                      MaxCharactersValidationRule(12),
                    },
                    validator: (value) {
                      return fancyPasswordController.areAllRulesValidated
                          ? null
                          : 'Not Validated';
                    },
                  ),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: const Text(
                      'Confirm Password:',
                      style: TextStyle(fontSize: 20),
                    )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                  child: FancyPasswordField(
                    passwordController: fancyConfirmPasswordController,
                    controller: confirmPasswordController,
                    hasStrengthIndicator: false,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      errorText: vConfirmPasswordField ? 'Field Cannot Be Empty' : null,
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
                      child: const Text('Register', style: TextStyle(color: Colors.indigo),),
                      onPressed: () async {
                        print("password rules value: " + fancyPasswordController.areAllRulesValidated.toString());
                        setState(() {
                          emailController.text.isEmpty ? vEmailField = true : vEmailField = false;
                          usernameController.text.isEmpty ? vUsernameField = true : vUsernameField = false;
                          ageController.text.isEmpty ? vAgeField = true : vAgeField = false;
                          phonenumController.text.isEmpty ? vPhoneNumField = true : vPhoneNumField = false;
                          passwordController.text.isEmpty ? vPasswordField = true : vPasswordField = false;
                          confirmPasswordController.text.isEmpty ? vConfirmPasswordField = true : vConfirmPasswordField = false;
                        });
                        //test
                        // print(emailController.text);
                        // print(usernameController.text);
                        // print(phonenumController.text);
                        // print(passwordController.text);

                        if (vEmailField == false && vUsernameField == false && vAgeField == false && vPhoneNumField == false && vPasswordField == false && vConfirmPasswordField == false) {
                          //password matched validation
                          if (passwordController.text == confirmPasswordController.text && passwordController.text != "" && confirmPasswordController.text != "" && fancyPasswordController.areAllRulesValidated == true && passwordController.text != emailController.text) {
                            User? user = await DatabaseService.signupUsingEmailPassword(
                                email: emailController.text,
                                username: usernameController.text,
                                age: ageController.text,
                                gender: genderController.text,
                                phonenum: phonenumController.text,
                                password: passwordController.text,
                                context: context
                            );
                            print(user);

                            if (user != null) {
                              FirebaseAuth.instance.currentUser!.reload();
                              bool isEmailVerified = DatabaseService().checkEmailVerified();

                              if(isEmailVerified == true) {
                                print("Email Verified");
                              } else {
                                print("Email Not Verified");
                                user.sendEmailVerification();
                                showVerifyEmailAlertPopup();
                              }
                            } else {
                              showUserExistPopup();
                            }
                          } else if (passwordController.text == emailController.text) {
                            showPasswordMatchEmailPopup();
                            print('Password cannot be the same as email address!');
                          } else if (passwordController.text != confirmPasswordController.text) {
                            showPasswordMismatchPopup();
                            print('Password mismatch!');
                          } else if (fancyPasswordController.areAllRulesValidated == false) {
                            showPasswordNotSecurePopup();
                            print('Password not secure!');
                          };
                        }

                        // else if (emailController.text == "") {
                        //   print("Please enter email");
                        // } else if (usernameController.text == "") {
                        //   print("Please enter username");
                        // } else if (phonenumController.text == "") {
                        //   print("Please enter phone number");
                        // } else if (passwordController.text == "") {
                        //   print("Please enter password");
                        // } else if (passwordController.text != confirmpasswordController.text){
                        //   print("Password didn't match!");
                        // };
                      },
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

