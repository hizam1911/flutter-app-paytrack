import 'package:flutter/material.dart';
import 'package:paytrack/pages/dashboard.dart';
import 'package:paytrack/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_password_field/fancy_password_field.dart';

String username = "";
String email = "";
String phonenum = "";
String age = "";
String gender = "";
String uid = "";
String currentPassword = "";
String newPassword = "";
bool isChangePassword = false;
bool loadingBool = true;

List lGender = ["Male", "Female"];

//textfile controller
TextEditingController usernameController = TextEditingController();
TextEditingController phonenumController = TextEditingController();
TextEditingController ageController = TextEditingController();
TextEditingController genderController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController confirmPasswordController = TextEditingController();
FancyPasswordController fancyPasswordController = FancyPasswordController();
FancyPasswordController fancyConfirmPasswordController = FancyPasswordController();

bool vUsernameField = false;
bool vAgeField = false;
bool vPhoneNumField = false;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String dropdownGenderValue = lGender.first;

  @override
  void initState() {
    super.initState();
    passwordController.text = "";
    confirmPasswordController.text = "";
    vUsernameField = false;
    vAgeField = false;
    vPhoneNumField = false;
    loadingBool = true;
  }

  void getUserInfo() {
    uid = DatabaseService().getUID();
    final userRef = FirebaseFirestore.instance.collection("users").doc(uid.toString());

    userRef.get().then(
          (DocumentSnapshot doc) {
        // final data = doc.data() as Map<String, dynamic>;
        username = doc.get("username");
        email = doc.get("email");
        age = doc.get("age");
        gender = doc.get("gender");
        phonenum = doc.get("phonenum");
        currentPassword = doc.get("password");

        usernameController.text = username;
        phonenumController.text = phonenum;
        ageController.text = age;
        genderController.text = gender;
        setState((){ loadingBool = false; });
      },
      onError: (e) => print("Error getting document: $e"),
    );
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

    // getUserInfo();
    if (loadingBool) {
      getUserInfo();

      return SizedBox(
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.white,),
          child: Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
              )
          ),
        ),
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width / 2,
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          title: Text('My Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          centerTitle: true,
          //elevation: 0,
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 150.0,
              width: 150.0,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Center(
                child: CircleAvatar(
                  radius: 48, // Image radius
                  backgroundImage: AssetImage('images/user.png'),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Text(email.toString(), style: TextStyle(fontSize: 18)),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
              child: InputDecorator(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  labelText: 'Personal Information',
                  labelStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                        child: const Text(
                          'Username:',
                          style: TextStyle(fontSize: 18),
                        )
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      height: 100,
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
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: const Text(
                          'Phone No.:',
                          style: TextStyle(fontSize: 18),
                        )
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      height: 100,
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
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: const Text(
                          'Age:',
                          style: TextStyle(fontSize: 18),
                        )
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      height: 100,
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
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: const Text(
                          'Gender:',
                          style: TextStyle(fontSize: 18),
                        )
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                      child: DropdownMenu<String>(
                        width: MediaQuery.of(context).size.width * 0.45,
                        initialSelection: gender,
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
                  ],
                ),
              ),
            ),
            
            Container(
              padding: EdgeInsets.fromLTRB(10, 40, 10, 20),
              child: InputDecorator(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  labelText: 'Change Password',
                  labelStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                        child: const Text(
                          'Password:',
                          style: TextStyle(fontSize: 18),
                        )
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      child: FancyPasswordField(
                        passwordController: fancyPasswordController,
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: const Text(
                          'Confirm Password:',
                          style: TextStyle(fontSize: 18),
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(125, 10, 125, 0),
                child: ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () {
                    setState(() {
                      usernameController.text.isEmpty ? vUsernameField = true : vUsernameField = false;
                      phonenumController.text.isEmpty ? vPhoneNumField = true : vPhoneNumField = false;
                      ageController.text.isEmpty ? vAgeField = true : vAgeField = false;
                    });

                    if (vUsernameField == false && vPhoneNumField == false && vAgeField == false) {
                      bool isOkay = true;
                      //check whether the textfield empty or not (set true if one of them is not null)
                      if (passwordController.text != "" || confirmPasswordController.text != "") {
                        if (passwordController.text == confirmPasswordController.text && fancyPasswordController.areAllRulesValidated == true) {
                          isChangePassword = true;
                          newPassword = passwordController.text;
                        } else if (passwordController.text != confirmPasswordController.text) {
                          isChangePassword = false;
                          isOkay = false;
                          showPasswordMismatchPopup();
                          print("Password didn't match!");
                        } else if (fancyPasswordController.areAllRulesValidated == false) {
                          isChangePassword = false;
                          isOkay = false;
                          showPasswordNotSecurePopup();
                          print("Password not secure!");
                        }
                      } else {
                        isChangePassword = false;
                        newPassword = currentPassword;
                      }

                      if (usernameController.text == "") {
                        isOkay = false;
                        print("Please enter username!");
                      } else if (phonenumController.text == "") {
                        isOkay = false;
                        print("Please enter phone number!");
                      } else if (ageController.text == "") {
                        isOkay = false;
                        print("Please enter age!");
                      }

                      if (isOkay == true) {
                        username = usernameController.text;
                        phonenum = phonenumController.text;
                        age = ageController.text;
                        gender = genderController.text;
                        DatabaseService().updatePersonalInfo(uid, username, isChangePassword, email, phonenum, age, gender, currentPassword, newPassword);
                        Navigator.pop(context, "update");
                      }
                    }

                    // Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                    //print(nameController.text);
                    //print(passwordController.text);
                  },
                )
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      );
    }
  }
}