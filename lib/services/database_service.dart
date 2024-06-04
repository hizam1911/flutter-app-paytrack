import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paytrack/services/local_notification_service.dart';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:paytrack/pages/dashboard.dart';
import 'dart:async';

const String USER_COLLECTION_REF = "users";

class DatabaseService {
  // final _firestore = FirebaseFirestore.instance;
  //
  // late final CollectionReference _usersRef;
  //
  // DatabaseService() {
  //   _usersRef = _firestore.collection(USER_COLLECTION_REF).withConverter<Users>(
  //       fromFirestore: (snapshot, _) => Users.fromJson(
  //         snapshot.data()!,
  //       ),
  //       toFirestore: (user, _) => user.toJson(),
  //   );
  // }
  //
  // Stream<QuerySnapshot> getUsers() {
  //   return _usersRef.snapshots();
  // }
  //
  // void addUser(User user) async {
  //   _usersRef.add(user);
  // }
  //ALL ABOVE ARE FROM TUTORIAL

  //fx to get currect userID
  String getUID() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    final uid = user.uid;
    print("UID = "+uid);
    return uid;
  }

  //test id token
  //User Logout
  Future<String> checkLoginState() async {
    String userState = 'NA';
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        userState = '0';
        print('User is currently signed out!');
      } else {
        userState = '1';
        print('User is signed in!');
      }
    });
    return userState;
  }

  //Add New User
  static Future<User?> signupUsingEmailPassword({required String email, required String username, required String age, required String gender, required String phonenum, required String password, required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(email: email, password: password);
      user = result.user;

      await FirebaseFirestore.instance.collection('users')
          .doc(user!.uid).set({ 'email': email,'username': username, 'age': age, 'gender': gender, 'phonenum': phonenum, 'password': password, 'isRefreshed': '0', });
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        print("Email exist.");
      }
    }

    return user;
  }

  //User Login
  static Future<User?> loginUsingEmailPassword({required String email, required String password, required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;

    } on FirebaseAuthException catch (e) {
      if (e.code == "user not found") {
        print("No user found for that email");
      }
    }

    return user;
  }

  //User Logout
  void signOut() async {
    await FirebaseAuth.instance.signOut();
    print("Successfully Logout");
  }

  void updatePersonalInfo (String uid, String username, bool isChangePassword, String email, String phonenum, String age, String gender, String currentPassword, String newPassword) async {
    final user = await FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: user!.email.toString(), password: currentPassword);

    // update email (cannot be used, probably cuz of the basic firebase plan or cuz it only works for signin with gmail method)
    // error: Email can't be changed[firebase_auth/operation-not-allowed] This operation is not allowed. This may be because the given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section. [ Please verify the new email before changing email. ]
    // if (newEmail != currentEmail) {
    //   user.reauthenticateWithCredential(cred).then((value) {
    //     user.updateEmail(newEmail).then((_) {
    //       //Success, do something
    //       print("Successfully changed email");
    //     }).catchError((error) {
    //       //Error, show something
    //       print("Email can't be changed" + error.toString());
    //     });
    //   }).catchError((err) {
    //
    //   });
    // }

    //update password
    if (isChangePassword == true) {
      user.reauthenticateWithCredential(cred).then((value) {
        user.updatePassword(newPassword).then((_) {
          //Success, do something
          print("Successfully changed password");
        }).catchError((error) {
          //Error, show something
          print("Password can't be changed" + error.toString());
        });
      }).catchError((err) {

      });
    }

    //update the user collection
    // await FirebaseFirestore.instance.collection('users')
    //     .doc(uid).set({ 'email': email, 'username': username, 'phonenum': phonenum, 'password': newPassword, });
    await FirebaseFirestore.instance.collection('users')
        .doc(uid).update({ 'email': email, 'username': username, 'phonenum': phonenum, 'age': age, 'gender': gender, 'password': newPassword, });

    print("Updated Personal Information Successfully");


    //
    // await FirebaseAuth.instance
    //     .sendPasswordResetEmail(email: "user@example.com");
  }

  //updatePass doc everytime user login
  void updatePassUponLogin(String tEmail, String tPass) async {
    String tempEmail = tEmail;
    String tempUsername = "";
    String tempPhonenum = "";
    String tempPass = tPass;
    String tempUID = getUID();

    //assign username and phonenum
    final userRef = await FirebaseFirestore.instance.collection("users").doc(tempUID);

    userRef.get().then(
          (DocumentSnapshot doc) {
        // final data = doc.data() as Map<String, dynamic>;
        tempUsername = doc.get("username");
        tempPhonenum = doc.get("phonenum");

        // userRef.set({ 'email': tempEmail, 'username': tempUsername, 'phonenum': tempPhonenum, 'password': tempPass, });
        userRef.update({ 'email': tempEmail, 'username': tempUsername, 'phonenum': tempPhonenum, 'password': tempPass, });

        print("Updated Personal Information Successfully");
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  //bool to check if user is verified
  bool checkEmailVerified() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    return user.emailVerified;
  }

  //add new reminder
  // void addNewReminder(String userID, String frequencyID, String statusID, String typeID,
  //     String reminderTitle, String reminderAmount, String reminderStartDate, String reminderEndDate,
  //     String reminderStartTime, String reminderEndTime, String reminderPaidDate, String reminderNotes) async {
  //
  //   try {
  //     final reminderRef = await FirebaseFirestore.instance.collection("reminders");
  //
  //     reminderRef.add({ 'userID': userID, 'frequencyID': frequencyID, 'statusID': statusID, 'typeID': typeID,
  //       'reminderTitle': reminderTitle, 'reminderAmount': reminderAmount, 'reminderStartDate': reminderStartDate, 'reminderEndDate': reminderEndDate,
  //       'reminderStartTime': reminderStartTime, 'reminderEndTime': reminderEndTime, 'reminderPaidDate': reminderPaidDate, 'reminderNotes': reminderNotes, });
  //
  //     print("New Reminder Added");
  //   } on FirebaseAuthException catch (e) {
  //     print("Error updating document: $e");
  //   }
  // }

  //determine Type, Status, Frequency
  String detType(String tid) {
    String temp = "";
    if(tid == "1") {
      temp = "Bills";
    } else if (tid == "2") {
      temp = "Debts";
    } else if (tid == "Bills") {
      temp = "1";
    } else if (tid == "Debts") {
      temp = "2";
    }
    return temp;
  }
  String detStatus(String sid) {
    String temp = "";
    if(sid == "1") {
      temp = "Paid";
    } else if (sid == "2") {
      temp = "Not Yet Paid";
    } else if(sid == "Paid") {
      temp = "1";
    } else if (sid == "Not Yet Paid") {
      temp = "2";
    }
    return temp;
  }
  String detFreq(String fid) {
    String temp = "";
    if(fid == "1") {
      temp = "Once";
    } else if (fid == "2") {
      temp = "Weekly";
    } else if (fid == "3") {
      temp = "Monthly";
    } else if(fid == "Once") {
      temp = "1";
    } else if (fid == "Weekly") {
      temp = "2";
    } else if (fid == "Monthly") {
      temp = "3";
    }
    return temp;
  }

  void addReminder(String typeID, String frequencyID, String reminderTitle,
      String reminderAmount, String reminderStartDate, String reminderStartTime, String reminderNotes, DateTime dtNotification) async {

    try {

      String statusID = "2"; //Not Yet Paid
      String paymentDate = "NA";
      String userID = getUID();
      print('before rng');
      //rng notification ID
      var rng = Random();
      int notificationID = rng.nextInt(1000000000) + 1;
      //--------------------
      //get notificationID
      final notificationRef = await FirebaseFirestore.instance.collection("reminders");

      notificationRef.where("notificationID", isEqualTo: notificationID).get().then(
            (querySnapshot) {
          print("Successfully completed");

          for (var docSnapshot in querySnapshot.docs) {

            print('${docSnapshot.id} => ${docSnapshot.data()}');
            var reminders = docSnapshot.data();
            reminderMap = reminders;
            // --------------------
            int tempNotificationID = int.parse(reminderMap['notificationID'].toString());

            while (tempNotificationID == notificationID) {
              notificationID = rng.nextInt(1000000000) + 1;
            }

            print(reminderMap['notificationID']);
          }
        },
        onError: (e) => print("Error completing: $e"),
      );
      //--------------------

      typeID = detType(typeID);
      frequencyID = detFreq(frequencyID);

      final reminderRef = await FirebaseFirestore.instance.collection("reminders");

      print(notificationID);
      print(userID);
      print(typeID);
      print(frequencyID);
      print(statusID);
      print(paymentDate);
      print(reminderTitle);
      print(reminderAmount);
      print(reminderStartDate);
      print(reminderStartTime);
      // print(reminderEndDate);
      // print(reminderEndTime);
      print(reminderNotes);


      reminderRef.add({ 'notificationID': notificationID,'userID': userID, 'typeID': typeID, 'frequencyID': frequencyID, 'statusID': statusID,
        'reminderTitle': reminderTitle, 'reminderAmount': reminderAmount, 'reminderNotes': reminderNotes, 'reminderPaidDate': paymentDate,
        'reminderStartTime': reminderStartTime, 'reminderStartDate': reminderStartDate, });

      String notificationTitle = 'Payment Reminder';
      String notificationType = detType(typeID);
      String notificationFrequency = detFreq(frequencyID);
      String notificationBody = 'Your $reminderTitle ($notificationType) is due today with a total amount of RM$reminderAmount!';
      if (notificationFrequency == 'Once') {
        LocalNotificationService().scheduleOneTimeNotification(notificationID, notificationTitle, notificationBody, dtNotification);
        print('Reminder Once Created');
      } else if (notificationFrequency == 'Weekly') {
        TimeOfDay timeDayNotification = TimeOfDay(hour: dtNotification.hour, minute: dtNotification.minute);
        String day = DateFormat('EEEE').format(dtNotification).toLowerCase();
        Day dayNotification = Day.values.firstWhere((e) => e.toString() == 'Day.' + day);
        LocalNotificationService().scheduleWeeklyNotification(notificationID, notificationTitle, notificationBody, timeDayNotification, dayNotification);
        print('Reminder Weekly Created');
      } else if (notificationFrequency == 'Monthly') {
        TimeOfDay timeDayNotification = TimeOfDay(hour: dtNotification.hour, minute: dtNotification.minute);
        int dayOfMonth = dtNotification.day;
        LocalNotificationService().scheduleMonthlyNotification(notificationID, notificationTitle, notificationBody, timeDayNotification, dayOfMonth);
        print('Reminder Monthly Created');
      }

      print('Notification Title: $notificationTitle');
      print('Notification Body: $notificationBody');
      print("Reminder Added");
    } on FirebaseAuthException catch (e) {
      print("Error updating document: $e");
    }

  }

  void updateReminder(String? rID, String typeID, String frequencyID, String reminderTitle,
      String reminderAmount, String reminderStartDate, String reminderStartTime, String reminderNotes, DateTime dtNotification) async {

    try {

      typeID = detType(typeID);
      frequencyID = detFreq(frequencyID);

      //--------------------
      //get notificationID
      int notificationID = 0;
      final notificationRef = await FirebaseFirestore.instance.collection("reminders").doc(rID);

      notificationRef.get().then(
            (DocumentSnapshot doc) {
          //
          String tempNotificationID = doc.get("notificationID").toString();
          notificationID = int.parse(tempNotificationID);

          //--------------------
          String notificationTitle = 'Payment Reminder';
          String notificationType = detType(typeID);
          String notificationFrequency = detFreq(frequencyID);
          String notificationBody = 'Your $reminderTitle ($notificationType) is due today with a total amount of RM$reminderAmount!';
          if (notificationFrequency == 'Once') {
            LocalNotificationService().scheduleOneTimeNotification(notificationID, notificationTitle, notificationBody, dtNotification);
            print('Reminder Once Created');
          } else if (notificationFrequency == 'Weekly') {
            TimeOfDay timeDayNotification = TimeOfDay(hour: dtNotification.hour, minute: dtNotification.minute);
            String day = DateFormat('EEEE').format(dtNotification).toLowerCase();
            Day dayNotification = Day.values.firstWhere((e) => e.toString() == 'Day.' + day);
            LocalNotificationService().scheduleWeeklyNotification(notificationID, notificationTitle, notificationBody, timeDayNotification, dayNotification);
            print('Reminder Weekly Created');
          } else if (notificationFrequency == 'Monthly') {
            TimeOfDay timeDayNotification = TimeOfDay(hour: dtNotification.hour, minute: dtNotification.minute);
            int dayOfMonth = dtNotification.day;
            LocalNotificationService().scheduleMonthlyNotification(notificationID, notificationTitle, notificationBody, timeDayNotification, dayOfMonth);
            print('Reminder Monthly Created');
          }
          //------------------------------------
          print("Updated NotificationID: $notificationID");

        },
        onError: (e) => print("Error getting document: $e"),
      );

      final reminderRef = await FirebaseFirestore.instance.collection("reminders").doc(rID);

      reminderRef.update({ 'typeID': typeID, 'frequencyID': frequencyID,
        'reminderTitle': reminderTitle, 'reminderAmount': reminderAmount, 'reminderNotes': reminderNotes,
        'reminderStartTime': reminderStartTime, 'reminderStartDate': reminderStartDate, });

      print("Reminder Updated");
    } on FirebaseAuthException catch (e) {
      print("Error updating document: $e");
    }

  }

  void updateReminderStatus(String? rID, String statusID, String reminderPaidDate) async {

    try {

      statusID = detStatus(statusID);

      final reminderRef = await FirebaseFirestore.instance.collection("reminders").doc(rID);

      reminderRef.update({ 'statusID': statusID, 'reminderPaidDate': reminderPaidDate, });

      print("Reminder Status Updated");

    } on FirebaseAuthException catch (e) {
      print("Error updating document: $e");
    }

  }

  void deleteReminder(String? rID) async {

    try {
      //--------------------
      //get notificationID
      int notificationID = 0;
      final notificationRef = await FirebaseFirestore.instance.collection("reminders").doc(rID.toString());
      final reminderRef = FirebaseFirestore.instance.collection("reminders").doc(rID);

      notificationRef.get().then(
            (DocumentSnapshot doc) {
          //
          String tempNotificationID = doc.get("notificationID").toString();
          notificationID = int.parse(tempNotificationID);
          LocalNotificationService().deleteNotification(notificationID);

          //--------------------
          reminderRef.delete();
          print("Reminder Deleted");
        },
        onError: (e) => print("Error getting document: $e"),
      );


    } on FirebaseAuthException catch (e) {
      print("Error deleting document: $e");
    }

  }

  void initSetPushNotification() async {
    String tempUID = getUID();
    int notificationID = 0;
    final reminderRef = await FirebaseFirestore.instance.collection("reminders");

    reminderRef.where("userID", isEqualTo: tempUID).get().then(
          (querySnapshot) async {
        print("Successfully completed");

        for (var docSnapshot in querySnapshot.docs) {

          print('${docSnapshot.id} => ${docSnapshot.data()}');
          var reminders = docSnapshot.data();
          reminderMap = reminders;
          // ----------------------------------------
          //--------------------
          notificationID = int.parse(reminderMap['notificationID'].toString());
          String notificationTitle = 'Payment Reminder';
          String reminderTitle = reminderMap['reminderTitle'];
          String notificationType = detType(reminderMap['typeID']);
          String notificationFrequency = detFreq(reminderMap['frequencyID']);
          String notificationAmount = reminderMap['reminderAmount'];
          DateTime dtNotification = DateTime.parse(reminderMap['reminderStartDate'].toString() + ' ' + reminderMap['reminderStartTime']);
          String notificationBody = 'Your $reminderTitle ($notificationType) is due today with a total amount of RM$notificationAmount!';

          if (notificationFrequency == 'Once') {
            LocalNotificationService().scheduleOneTimeNotification(notificationID, notificationTitle, notificationBody, dtNotification);
            print('Reminder Once Created');
          } else if (notificationFrequency == 'Weekly') {
            TimeOfDay timeDayNotification = TimeOfDay(hour: dtNotification.hour, minute: dtNotification.minute);
            String day = DateFormat('EEEE').format(dtNotification).toLowerCase();
            Day dayNotification = Day.values.firstWhere((e) => e.toString() == 'Day.' + day);
            LocalNotificationService().scheduleWeeklyNotification(notificationID, notificationTitle, notificationBody, timeDayNotification, dayNotification);
            print('Reminder Weekly Created');
          } else if (notificationFrequency == 'Monthly') {
            TimeOfDay timeDayNotification = TimeOfDay(hour: dtNotification.hour, minute: dtNotification.minute);
            int dayOfMonth = dtNotification.day;
            LocalNotificationService().scheduleMonthlyNotification(notificationID, notificationTitle, notificationBody, timeDayNotification, dayOfMonth);
            print('Reminder Monthly Created');
          }
          //------------------------------------
          print('Reminder Title: $reminderTitle');
          print('NotificationID: $notificationID');
        }
        print('Reminder Init Done');
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  void resetPaymentStatus() async {
    //---------------------------------------------
    String tempUID = getUID();
    String isRefreshed = '';
    final reminderRef = await FirebaseFirestore.instance.collection("reminders");
    final userRef = await FirebaseFirestore.instance.collection("users").doc(tempUID.toString());
    //---------------------------------------------
    // Create a timer that triggers every hour to check if it's the first day of the month
    Timer.periodic(Duration(seconds: 3), (timer) {
      DateTime now = DateTime.now();
      DateTime maxDays = LocalNotificationService().determineMaxDay(now);

      //get refresh info to see if the user data already been updated before
      userRef.get().then(
            (DocumentSnapshot doc) {
          // final data = doc.data() as Map<String, dynamic>;
          isRefreshed = doc.get("isRefreshed");
          //start here
          // if (isRefreshed == '0') {
          //   // Check if it's the first day of the month
          //   if (now.day == 1) {
          //     print("It is a new month so need to reset payment status!");
          //     reminderRef.where("userID", isEqualTo: tempUID).get().then(
          //           (querySnapshot) {
          //         print("Successfully completed");
          //
          //         for (var docSnapshot in querySnapshot.docs) {
          //
          //           print('${docSnapshot.id} => ${docSnapshot.data()}');
          //           var reminders = docSnapshot.data();
          //           reminderMap = reminders;
          //           // ----------------------------------------
          //           String reminderID = docSnapshot.id.toString();
          //           String statusID = reminderMap['statusID'];
          //           String reminderPaidDate = reminderMap['reminderPaidDate'];
          //           //----------------------------------------
          //           // Update the variable value
          //           statusID = 'Not Yet Paid'; //ID: 2
          //           reminderPaidDate = 'NA';
          //           updateReminderStatus(reminderID, statusID, reminderPaidDate);
          //         }
          //         isRefreshed = '1';
          //         userRef.update({ 'isRefreshed': isRefreshed, });
          //         print('Payment Status Reset Done');
          //       },
          //       onError: (e) => print("Error completing: $e"),
          //     );
          //   }
          // } else if (isRefreshed == '1') {
          //   if (now.day == maxDays.day) {
          //     isRefreshed = '0';
          //     userRef.update({ 'isRefreshed': isRefreshed, });
          //     print("Refreshed Info Update to $isRefreshed!");
          //   }
          // }
          //ends here

          if (now.day == 1 && isRefreshed == '0') {
            print("It is a new month so need to reset payment status!");
            reminderRef.where("userID", isEqualTo: tempUID).get().then(
                  (querySnapshot) {
                print("Successfully completed");

                for (var docSnapshot in querySnapshot.docs) {

                  print('${docSnapshot.id} => ${docSnapshot.data()}');
                  var reminders = docSnapshot.data();
                  reminderMap = reminders;
                  // ----------------------------------------
                  String reminderID = docSnapshot.id.toString();
                  String statusID = reminderMap['statusID'];
                  String reminderPaidDate = reminderMap['reminderPaidDate'];
                  //----------------------------------------
                  // Update the variable value
                  statusID = 'Not Yet Paid'; //ID: 2
                  reminderPaidDate = 'NA';
                  updateReminderStatus(reminderID, statusID, reminderPaidDate);
                }
                isRefreshed = '1';
                userRef.update({ 'isRefreshed': isRefreshed, });
                print('Payment Status Reset Done');
              },
              onError: (e) => print("Error completing: $e"),
            );
          } else {
            isRefreshed = '0';
            userRef.update({ 'isRefreshed': isRefreshed, });
            print("Refreshed Info Update to $isRefreshed!");
          }
        },
        onError: (e) => print("Error getting document: $e"),
      );
      //-----------------------------------------------

      // Stop the timer until the next month
      timer.cancel();
      print('isRefreshed: $isRefreshed');
      print('DateTime Now: ${DateTime.now().toString()}');
      print('Timer Stopped');
    });
  }




}
