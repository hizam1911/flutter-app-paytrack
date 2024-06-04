import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytrack/pages/register.dart';
import 'package:paytrack/pages/recoverpassword.dart';
import 'package:paytrack/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paytrack/pages/managereminder.dart';

bool loadingBool = true;
int totalQ = 0;
List rID = [];
List rTitle = [];
List rAmount = [];
List rType = [];
List rStatus = [];
Map reminderMap = {};



class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {

  void getRQueryTotalLocal() async {
    String tempUID = "meowmeow";
    final reminderRef = await FirebaseFirestore.instance.collection("reminders");

    reminderRef.where("userID", isEqualTo: tempUID).get().then(
          (querySnapshot) {
        print("Successfully completed");
        int counter = 0;

        for (var docSnapshot in querySnapshot.docs) {

          print('${docSnapshot.id} => ${docSnapshot.data()}');
          var reminders = docSnapshot.data();
          reminderMap = reminders;
          // reminderList.insert(counter, reminderMap);
          //process ID
          String typeTemp = "";
          String statusTemp = "";
          if (reminderMap['typeID'] == "1") {
            typeTemp = "Bills";
          } else if (reminderMap['typeID'] == "2") {
            typeTemp = "Debts";
          }

          if (reminderMap['statusID'] == "1") {
            statusTemp = "Paid on " + reminderMap['reminderPaidDate'];
          } else if (reminderMap['statusID'] == "2") {
            statusTemp = "Not Yet Paid";
          }

          rID.insert(counter, docSnapshot.id);
          rTitle.insert(counter, reminderMap['reminderTitle']);
          rAmount.insert(counter, reminderMap['reminderAmount']);
          rType.insert(counter, typeTemp);
          rStatus.insert(counter, statusTemp);
          counter++;
          print(counter);
          print(reminderMap['reminderTitle']);
        }
        print("Total Queries: " + querySnapshot.size.toString());
        totalQ = querySnapshot.size;
        setState((){ loadingBool = false; });
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  void printTestQ () {
    print("TotalQ = " + totalQ.toString());
  }

  void printList() {
    for (int i = 0; i < totalQ; i++) {
      print("-----------------------------------------");
      print("ID: " + rID[i]);
      print("Title: " + rTitle[i]);
      print("Amount: " + rAmount[i]);
      print("Type: " + rType[i]);
      print("Status: " + rStatus[i]);
    }
  }

  Icon rlType(String type) {
    Icon temp = Icon(Icons.check_circle);
    if (type == "Bills") {
      temp = Icon(Icons.house);
    } else if (type == "Debts") {
      temp = Icon(Icons.monetization_on_rounded);
    }
    return temp;
  }

  TextStyle rlText(String s) {
    TextStyle ts;
    if (s == "Not Yet Paid") {
      ts = TextStyle(color: Colors.redAccent);
    } else {
      ts = TextStyle(color: Colors.green);
    }

    return ts;
  }


  @override
  Widget build(BuildContext context) {
    if(loadingBool) {
      getRQueryTotalLocal();

      return SizedBox(
        child: Center(
            child: CircularProgressIndicator()
        ),
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width / 2,
      );
    } else {
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

      return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) return;
            showExitPopup();
          }, //call function on back button press
          child:Scaffold(
              appBar: AppBar(
                title: Text('CRUD TEST DB'),
              ),
              body: ListView(
                children: [
                  Container(
                      height: 50,
                      padding: const EdgeInsets.fromLTRB(125, 0, 125, 0),
                      child: ElevatedButton(
                        child: const Text('Print List'),
                        onPressed: () {
                          printList();


                          // Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
                          //print(nameController.text);
                          //print(passwordController.text);
                        },
                      )
                  ),
                  Container(
                      height: 50,
                      padding: const EdgeInsets.fromLTRB(125, 0, 125, 0),
                      child: ElevatedButton(
                        child: const Text('Convert'),
                        onPressed: () {
                          printTestQ();

                        },
                      )
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.78,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: ListView.builder(
                        itemCount: totalQ,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              leading: rlType(rType[index]),
                              title: Text(rTitle[index]),
                              subtitle: Row(
                                children: [
                                  Text(rType[index] + " | "),
                                  Text(rStatus[index], style: rlText(rStatus[index])),
                                ],
                              ),//rlText(rType[index], rStatus[index]),
                              trailing: Icon(Icons.keyboard_arrow_right_rounded),
                              onTap: () {
                                print("Printing " + rID[index] + "...");
                                manageReminder(2, rID[index]);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ManageReminder()),
                                );
                              },
                            ),
                          );
                        }),
                  ),
                ],
              )
          )
      );
    }

  }

}


