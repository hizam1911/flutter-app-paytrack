import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:paytrack/services/database_service.dart';
import 'package:paytrack/pages/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderDuration { Forever, Until }
ReminderDuration? _duration = ReminderDuration.Forever;
//1 = Add Reminder
//2 = Update Status
//3 = Update Reminder

//variables
bool loadingBool = true;
bool getRT = true;
bool getRF = true;
bool getRS = true;
bool vDuration = false;
int type = 0;
String? rid = "";
String rTitle = "";
String rAmount = "";
String rStartDate = "";
// String rEndDate = "";
String rStartTime = "";
// String rEndTime = "";
String rPaidDate = "";
String rNotes = "";
String rType = "";
String rStatus = "";
String rFrequency = "";

//list and map
int totalTQ = 0;
int totalFQ = 0;
int totalSQ = 0;
List rTID = [];
List rFID = [];
List rSID = [];
List rTName = [];
List rFName = [];
List rSName = [];
Map rTMap = {};
Map rFMap = {};
Map rSMap = {};

//text field controller
TextEditingController rTitleController = TextEditingController();
TextEditingController rAmountController = TextEditingController();
TextEditingController ddmType = TextEditingController();
TextEditingController ddmStatus = TextEditingController();
TextEditingController ddmFrequency = TextEditingController();
TextEditingController rNotesController = TextEditingController();

//text field validator
bool vTitleField = false;
bool vAmountField = false;

String setDateStart(String d) {
  rStartDate = d;
  // print(rStartDate);
  return rStartDate;
}
String setTimeStart(String t) {
  rStartTime = t;
  // rEndTime = t;
  // print(rStartTime);
  return rStartTime;
}
// String setDateEnd(String d) {
//   rEndDate = d;
//   // print(rEndDate);
//   return rEndDate;
// }
String setPaymentDate(String d) {
  rPaidDate = d;
  return rPaidDate;
}
bool isDurationVisible(bool v) {
  vDuration = v;
  print (v);
  return v;
}

void manageReminder(int t, [String? r]) {
  type = t;
  rid = r;
  loadingBool = true;
  getRT = true;
  getRF = true;
  getRS = true;
}

class ManageReminder extends StatefulWidget {
  const ManageReminder({super.key});

  @override
  State<ManageReminder> createState() => _ManageReminderState();
}

class _ManageReminderState extends State<ManageReminder> {
  void getRTFS() {

    final reminderTRef = FirebaseFirestore.instance.collection("reminderType");
    final reminderFRef = FirebaseFirestore.instance.collection("reminderFrequency");
    final reminderSRef = FirebaseFirestore.instance.collection("reminderStatus");

    //Reminder Type
    reminderTRef.get().then(
          (querySnapshot) {
        print("Successfully completed");
        int counter = 0;
        rTID = [];
        rTName = [];

        for (var docSnapshot in querySnapshot.docs) {

          print('${docSnapshot.id} => ${docSnapshot.data()}');
          var rT = docSnapshot.data();
          rTMap = rT;

          rTID.insert(counter, docSnapshot.id);
          rTName.insert(counter, rTMap['typeName']);

          counter++;
          print(counter);
          print("TypeName: " + rTMap['typeName']);
        }
        print("Total Queries: " + querySnapshot.size.toString());
        totalTQ = querySnapshot.size;
        // setState((){ loadingBool = false; });
        setState((){ getRT = false; });
      },
      onError: (e) => print("Error completing: $e"),
    );

    //Reminder Frequency
    reminderFRef.get().then(
          (querySnapshot) {
        print("Successfully completed");
        int counter = 0;
        rFID = [];
        rFName = [];

        for (var docSnapshot in querySnapshot.docs) {

          print('${docSnapshot.id} => ${docSnapshot.data()}');
          var rF = docSnapshot.data();
          rFMap = rF;

          rFID.insert(counter, docSnapshot.id);
          rFName.insert(counter, rFMap['frequencyName']);

          counter++;
          print(counter);
          print("FrequencyName: " + rFMap['frequencyName']);
        }
        print("Total Queries: " + querySnapshot.size.toString());
        totalFQ = querySnapshot.size;
        // setState((){ loadingBool = false; });
        setState((){ getRF = false; });
      },
      onError: (e) => print("Error completing: $e"),
    );

    //Reminder Status
    reminderSRef.get().then(
          (querySnapshot) {
        print("Successfully completed");
        int counter = 0;
        rSID = [];
        rSName = [];

        for (var docSnapshot in querySnapshot.docs) {

          print('${docSnapshot.id} => ${docSnapshot.data()}');
          var rS = docSnapshot.data();
          rSMap = rS;

          rSID.insert(counter, docSnapshot.id);
          rSName.insert(counter, rSMap['statusName']);

          counter++;
          print(counter);
          print("StatusName: " + rSMap['statusName']);
        }
        print("Total Queries: " + querySnapshot.size.toString());
        totalSQ = querySnapshot.size;
        // setState((){ loadingBool = false; });
        setState((){ getRS = false; });
      },
      onError: (e) => print("Error completing: $e"),
    );

    // print(rTID + rTName);
    // print(rSID + rSName);
    // print (rFID + rFName);
  }

  void getReminderInfo() {
    print(rid);
    final userRef = FirebaseFirestore.instance.collection("reminders").doc(rid.toString());

    userRef.get().then(
          (DocumentSnapshot doc) {
        // final data = doc.data() as Map<String, dynamic>;
        rTitle = doc.get("reminderTitle");
        rAmount = doc.get("reminderAmount");
        rType = doc.get("typeID");
        rStatus = doc.get("statusID");
        rFrequency = doc.get("frequencyID");
        // rEndDate = doc.get("reminderEndDate");
        // rEndTime = doc.get("reminderEndTime");
        rStartDate = doc.get("reminderStartDate");
        rStartTime = doc.get("reminderStartTime");
        rPaidDate = doc.get("reminderPaidDate");
        rNotes = doc.get("reminderNotes");

        // if (rEndDate != "NA") {
        //   vDuration = true;
        //   _duration = ReminderDuration.Until;
        // } else if (rEndDate == "NA") {
        //   vDuration = false;
        //   _duration = ReminderDuration.Forever;
        // }

        if(rStatus == "1") {
          rPaidDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(rPaidDate.toString()));
        } else if (rStatus == "2") {
          rPaidDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        } else {
          print("No Status Found");
        }

        rTitleController.text = rTitle;
        rAmountController.text = rAmount;
        rNotesController.text = rNotes;

        setState((){ loadingBool = false; });
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }


  @override
  Widget build(BuildContext context) {
    if(getRT && getRF && getRS) {
      getRTFS();
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
      if (type == 1) {
          return AddReminder();
      } else if (type == 2) {
        if(loadingBool) {

          getReminderInfo();
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
          // print(rTID + rTName);
          // print(rSID + rSName);
          // print (rFID + rFName);
          return UpdateStatus();
        }
      } else if (type == 3) {
        if(loadingBool) {

          getReminderInfo();
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
          return UpdateReminder();
        }
      };
    }

    return Inform();
  }
}

class Inform extends StatelessWidget {
  const Inform({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Error 404: Page Not Found :v');
  }
}

// ADD REMINDER PAGE START HERE
class AddReminder extends StatefulWidget {
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  ReminderDuration? _duration = ReminderDuration.Forever;

  String dropdownTypeValue = rTName.first;
  String dropdownStatusValue = rSName.first;
  String dropdownRepeatValue = rFName.first;
  String _formatDate = 'yyyy-MM-dd';
  String _formatTime = 'HH:mm';
  late DateTime _dateTime, _dateDuration;

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.parse(DateTime.now().toString());
    _dateDuration = DateTime.parse(DateTime.now().toString());
    isDurationVisible(false);

    rTitleController.text = "";
    rAmountController.text = "";
    rNotesController.text = "";
    vTitleField = false;
    vAmountField = false;
    // ddmType
    // ddmStatus
    // ddmFrequency
  }

  void _showDateDurationPicker() {
    DatePicker.showDatePicker(
      context,
      initialDateTime: _dateDuration,
      dateFormat: _formatDate,
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
      ),
      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateDuration = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateDuration = dateTime;
        });
      },
    );
  }

  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      initialDateTime: _dateTime,
      minDateTime: DateTime.now(),
      dateFormat: _formatDate,
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
      ),
      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }

  void _showTimePicker() {
    DatePicker.showDatePicker(
      context,
      initialDateTime: _dateTime,
      dateFormat: _formatTime,
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
      ),
      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          title: Text('Add Reminder', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          centerTitle: true,
          //elevation: 0,
        ),
        body: ListView(
          children: [
            Column(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                            child: Text('Title:', style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 100,
                            child: TextField(
                              controller: rTitleController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Title',
                                errorText: vTitleField ? 'Field Cannot Be Empty' : null,

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                            child: Text('Amount (RM):', style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: rAmountController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                errorText: vAmountField ? 'Field Cannot Be Empty' : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text('Date and Time:', style: TextStyle(fontSize: 18)),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 5.0, right:5.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[50],
                                  ),
                                  onPressed: _showDatePicker,
                                  child: Icon(Icons.calendar_month, color: Colors.indigo,),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text(
                                  setDateStart('${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}'),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text('', style: TextStyle(fontSize: 18)),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10.0, right:5.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[50],
                                  ),
                                  onPressed: _showTimePicker,
                                  child: Icon(Icons.access_time, color: Colors.indigo),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text(
                                  setTimeStart('${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}'),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                            child: Text('Type:', style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                            child: DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.45,
                              initialSelection: rTName.first,
                              controller: ddmType,
                              onSelected: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  dropdownTypeValue = value!;
                                });
                              },
                              dropdownMenuEntries: rTName.map<DropdownMenuEntry<String>>((var value) {
                                return DropdownMenuEntry<String>(value: value, label: value);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Visibility(
                        visible: false,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                              child: Text('Payment Status:', style: TextStyle(fontSize: 18)),
                            ),
                            Container(
                              child: DropdownMenu<String>(
                                width: MediaQuery.of(context).size.width * 0.45,
                                initialSelection: rSName.first,
                                controller: ddmStatus,
                                onSelected: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    dropdownStatusValue = value!;
                                  });
                                },
                                dropdownMenuEntries: rSName.map<DropdownMenuEntry<String>>((var value) {
                                  return DropdownMenuEntry<String>(value: value, label: value);
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                            child: Text('Repeat:', style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                            child: DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.45,
                              initialSelection: rFName.first,
                              controller: ddmFrequency,
                              onSelected: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  dropdownRepeatValue = value!;
                                });
                              },
                              dropdownMenuEntries: rFName.map<DropdownMenuEntry<String>>((var value) {
                                return DropdownMenuEntry<String>(value: value, label: value);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Visibility(
                        visible: false,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                              child: Text('Payment Date:', style: TextStyle(fontSize: 18)),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                /* Start Here
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                  child: Text('Duration:', style: TextStyle(fontSize: 18)),
                ),

                Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text('Forever'),
                      leading: Radio<ReminderDuration>(
                        value: ReminderDuration.Forever,
                        groupValue: _duration,
                        onChanged: (ReminderDuration? value) {
                          setState(() {
                            _duration = value;
                            isDurationVisible(false);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      // title: const Text('Until'),
                      title: Row(
                        children: [
                          Text('Until'),
                          Visibility(
                            visible: isDurationVisible(vDuration),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 20.0, right: 10.0),
                                  child: ElevatedButton(
                                    onPressed: _showDateDurationPicker,
                                    child: Icon(Icons.calendar_month),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    setDateEnd('${_dateDuration.year}-${_dateDuration.month.toString().padLeft(2, '0')}-${_dateDuration.day.toString().padLeft(2, '0')}'),
                                    style: Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      leading: Radio<ReminderDuration>(
                        value: ReminderDuration.Until,
                        groupValue: _duration,
                        onChanged: (ReminderDuration? value) {
                          setState(() {
                            _duration = value;
                            isDurationVisible(true);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Until Here */

                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                  child: Text('Notes:', style: TextStyle(fontSize: 18)),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextField(
                    controller: rNotesController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[50],
                              ),
                              child: const Text('Cancel', style: TextStyle(color: Colors.indigo),),
                              onPressed: () {
                                Navigator.pop(context);
                                //print(nameController.text);
                                //print(passwordController.text);
                              },
                            ),
                          )
                      ),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[50],
                              ),
                              child: const Text('Add', style: TextStyle(color: Colors.indigo),),
                              onPressed: () {
                                setState(() {
                                  rTitleController.text.isEmpty ? vTitleField = true : vTitleField = false;
                                  rAmountController.text.isEmpty ? vAmountField = true : vAmountField = false;
                                });

                                if (vTitleField == false && vAmountField == false) {
                                  String tempType = ddmType.text.toString();
                                  String tempFrequency = ddmFrequency.text.toString();
                                  String tempTitle = rTitleController.text.toString();
                                  String tempAmount = rAmountController.text.toString();
                                  String tempNotes = rNotesController.text.toString();

                                  DatabaseService().addReminder(tempType, tempFrequency, tempTitle, tempAmount,
                                      rStartDate, rStartTime, tempNotes, _dateTime);

                                  Navigator.pop(context, "update");
                                }
                              },
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )




      // ListView(
      //   shrinkWrap: true,
      //   children: [
      //     Container(
      //       height: 150.0,
      //       width: 150.0,
      //       padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      //       child: Center(
      //         child: CircleAvatar(
      //           radius: 48, // Image radius
      //           backgroundImage: AssetImage('images/logo.jpg'),
      //         ),
      //       ),
      //     ),
      //     Container(
      //       alignment: Alignment.center,
      //       padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      //       child: Text('hikitohackerz', style: TextStyle(fontSize: 18)),
      //     ),
      //     Container(
      //         height: 50,
      //         padding: const EdgeInsets.fromLTRB(125, 10, 125, 0),
      //         child: ElevatedButton(
      //           child: const Text('Update'),
      //           onPressed: () {
      //             Navigator.pop(context);
      //             // Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      //             //print(nameController.text);
      //             //print(passwordController.text);
      //           },
      //         )
      //     ),
      //   ],
      // ),
    );
  }
}

//UPDATE REMINDER PAGE START HERE
class UpdateReminder extends StatefulWidget {
  const UpdateReminder({super.key});

  @override
  State<UpdateReminder> createState() => _UpdateReminderState();
}

class _UpdateReminderState extends State<UpdateReminder> {

  String dropdownTypeValue = rTName.first;
  String dropdownStatusValue = rSName.first;
  String dropdownRepeatValue = rSName.first;
  String _formatDate = 'yyyy-MM-dd';
  String _formatTime = 'HH:mm';
  late DateTime _dateTime, _dateDuration;

  @override
  void initState() {
    super.initState();
    //for Add Reminder Only
    // _dateTime = DateTime.parse(DateTime.now().toString());
    // _dateDuration = DateTime.parse(DateTime.now().toString());

    _dateTime = DateTime.parse(rStartDate.toString() + " " + rStartTime.toString());
    _dateDuration = DateTime.parse(DateTime.now().toString());
    // if(rEndDate != "NA") {
    //   _dateDuration = DateTime.parse(rEndDate.toString());
    // } else {
    //   _dateDuration = DateTime.parse(DateTime.now().toString());
    // }

    vTitleField = false;
    vAmountField = false;

  }

  void _showDateDurationPicker() {
    DatePicker.showDatePicker(
      context,
      initialDateTime: _dateDuration,
      dateFormat: _formatDate,
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
      ),
      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateDuration = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateDuration = dateTime;
        });
      },
    );
  }

  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      initialDateTime: _dateTime,
      minDateTime: DateTime.now(),
      dateFormat: _formatDate,
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
      ),
      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }

  void _showTimePicker() {
    DatePicker.showDatePicker(
      context,
      initialDateTime: _dateTime,
      dateFormat: _formatTime,
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
      ),
      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    Future<bool> showDeletePopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Reminder'),
          content: Text('Do you want to delete this reminder?'),
          actions:[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              //return false when click on "NO"
              child:Text('No'),
            ),

            ElevatedButton(
              onPressed: () async {
                DatabaseService().deleteReminder(rid);

                Navigator.of(context).pop(true);
              },
              //return true when click on "Yes"
              child:Text('Yes'),
            ),
          ],
        ),
      )??false; //if showDialogue had returned null, then return false
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          title: Text('Manage Reminder', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          centerTitle: true,
          //elevation: 0,
        ),
        body: ListView(
          children: [
            Column(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                            child: Text('Title:', style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 100,
                            child: TextField(
                              controller: rTitleController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Title',
                                errorText: vTitleField ? 'Field Cannot Be Empty' : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                            child: Text('Amount (RM):', style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: rAmountController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                errorText: vAmountField ? 'Field Cannot Be Empty' : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text('Date and Time:', style: TextStyle(fontSize: 18)),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 5.0, right:5.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[50],
                                  ),
                                  onPressed: _showDatePicker,
                                  child: Icon(Icons.calendar_month, color: Colors.indigo,),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text(
                                  setDateStart('${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}'),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text('', style: TextStyle(fontSize: 18)),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10.0, right:5.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[50],
                                  ),
                                  onPressed: _showTimePicker,
                                  child: Icon(Icons.access_time, color: Colors.indigo),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text(
                                  setTimeStart('${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}'),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                            child: Text('Type:', style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                            child: DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.45,
                              initialSelection: DatabaseService().detType(rType),
                              controller: ddmType,
                              onSelected: (String? value) {
                                // This is called when the user selects an item.
                                print(value);
                                setState(() {
                                  dropdownTypeValue = value!;
                                });
                              },
                              dropdownMenuEntries: rTName.map<DropdownMenuEntry<String>>((var value) {
                                return DropdownMenuEntry<String>(value: value, label: value);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Visibility(
                        visible: false,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                              child: Text('Payment Status:', style: TextStyle(fontSize: 18)),
                            ),
                            Container(
                              child: DropdownMenu<String>(
                                width: MediaQuery.of(context).size.width * 0.45,
                                initialSelection: DatabaseService().detStatus(rStatus),
                                controller: ddmStatus,
                                onSelected: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    dropdownStatusValue = value!;
                                  });
                                },
                                dropdownMenuEntries: rSName.map<DropdownMenuEntry<String>>((var value) {
                                  return DropdownMenuEntry<String>(value: value, label: value);
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                            child: Text('Repeat:', style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                            child: DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.45,
                              initialSelection: DatabaseService().detFreq(rFrequency),
                              controller: ddmFrequency,
                              onSelected: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  dropdownRepeatValue = value!;
                                });
                              },
                              dropdownMenuEntries: rFName.map<DropdownMenuEntry<String>>((var value) {
                                return DropdownMenuEntry<String>(value: value, label: value);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Visibility(
                        visible: false,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                              child: Text('Payment Date:', style: TextStyle(fontSize: 18)),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                rPaidDate,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                /* Start Here
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                  child: Text('Duration:', style: TextStyle(fontSize: 18)),
                ),

                Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text('Forever'),
                      leading: Radio<ReminderDuration>(
                        value: ReminderDuration.Forever,
                        groupValue: _duration,
                        onChanged: (ReminderDuration? value) {
                          setState(() {
                            _duration = value;
                            isDurationVisible(false);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      // title: const Text('Until'),
                      // onTap: ,
                      title: Row(
                        children: [
                          Text('Until'),
                          Visibility(
                            visible: isDurationVisible(vDuration),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 20.0, right: 10.0),
                                  child: ElevatedButton(
                                    onPressed: _showDateDurationPicker,
                                    child: Icon(Icons.calendar_month),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    setDateEnd('${_dateDuration.year}-${_dateDuration.month.toString().padLeft(2, '0')}-${_dateDuration.day.toString().padLeft(2, '0')}'),
                                    style: Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      leading: Radio<ReminderDuration>(
                        value: ReminderDuration.Until,
                        groupValue: _duration,
                        onChanged: (ReminderDuration? value) {
                          setState(() {
                            _duration = value;
                            isDurationVisible(true);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Until Here */

                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                  child: Text('Notes:', style: TextStyle(fontSize: 18)),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextField(
                    controller: rNotesController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[50],
                              ),
                              child: const Text('Delete', style: TextStyle(color: Colors.indigo),),
                              onPressed: () async {
                                bool delReminder = await showDeletePopup();

                                if (delReminder) {
                                  await Future.delayed(const Duration(seconds: 1));
                                  Navigator.pop(context, "update");
                                }

                                // DatabaseService().deleteReminder(rid);
                                //
                                // Navigator.pop(context, "update");
                              },
                            ),
                          )
                      ),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[50],
                              ),
                              child: const Text('Update', style: TextStyle(color: Colors.indigo),),
                              onPressed: () {
                                setState(() {
                                  rTitleController.text.isEmpty ? vTitleField = true : vTitleField = false;
                                  rAmountController.text.isEmpty ? vAmountField = true : vAmountField = false;
                                });

                                if (vTitleField == false && vAmountField == false) {
                                  String tempType = ddmType.text.toString();
                                  String tempFrequency = ddmFrequency.text.toString();
                                  String tempTitle = rTitleController.text.toString();
                                  String tempAmount = rAmountController.text.toString();
                                  String tempNotes = rNotesController.text.toString();

                                  DatabaseService().updateReminder(rid, tempType, tempFrequency, tempTitle, tempAmount,
                                      rStartDate, rStartTime, tempNotes, _dateTime);

                                  Navigator.pop(context, "update");
                                }

                              },
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )
    );
  }
}

//UPDATE STATUS PAGE START HERE
class UpdateStatus extends StatefulWidget {
  const UpdateStatus({super.key});

  @override
  State<UpdateStatus> createState() => _UpdateStatusState();
}

class _UpdateStatusState extends State<UpdateStatus> {

  String dropdownTypeValue = rTName.first;
  String dropdownStatusValue = rSName.first;
  String dropdownRepeatValue = rSName.first;
  String _formatDate = 'yyyy-MM-dd';
  String _formatTime = 'HH:mm';
  late DateTime _dateTime, _dateDuration;

  @override
  void initState() {
    super.initState();
    //for Add Reminder Only
    // _dateTime = DateTime.parse(DateTime.now().toString());
    // _dateDuration = DateTime.parse(DateTime.now().toString());

    _dateTime = DateTime.parse(rStartDate.toString() + " " + rStartTime.toString());
    _dateDuration = DateTime.parse(DateTime.now().toString());
    // if(rEndDate != "NA") {
    //   _dateDuration = DateTime.parse(rEndDate.toString());
    // } else {
    //   _dateDuration = DateTime.parse(DateTime.now().toString());
    // }

    vTitleField = false;
    vAmountField = false;

  }

  void _showDateDurationPicker() {
    DatePicker.showDatePicker(
      context,
      initialDateTime: _dateDuration,
      dateFormat: _formatDate,
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
      ),
      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateDuration = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateDuration = dateTime;
        });
      },
    );
  }

  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      initialDateTime: _dateTime,
      minDateTime: DateTime.now(),
      dateFormat: _formatDate,
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
      ),
      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }

  void _showTimePicker() {
    DatePicker.showDatePicker(
      context,
      initialDateTime: _dateTime,
      dateFormat: _formatTime,
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
      ),
      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        title: Text('Update Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        centerTitle: true,
        //elevation: 0,
      ),
      body: ListView(
        children: [
          Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                          child: Text('Title:', style: TextStyle(fontSize: 18)),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          height: 100,
                          child: TextField(
                            readOnly: true,
                            controller: rTitleController,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Title',
                              errorText: vTitleField ? 'Field Cannot Be Empty' : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                          child: Text('Amount (RM):', style: TextStyle(fontSize: 18)),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          height: 100,
                          child: TextField(
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            controller: rAmountController,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              errorText: vAmountField ? 'Field Cannot Be Empty' : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Text('Date and Time:', style: TextStyle(fontSize: 18)),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo[50],
                                ),
                                onPressed: null,
                                child: Icon(Icons.calendar_month),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                setDateStart('${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}'),
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Text('', style: TextStyle(fontSize: 18)),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0, right: 5.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo[50],
                                ),
                                onPressed: null,
                                child: Icon(Icons.access_time),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                setTimeStart('${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}'),
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                          child: Text('Type:', style: TextStyle(fontSize: 18)),
                        ),
                        Container(
                          child: DropdownMenu<String>(
                            enabled: false,
                            width: MediaQuery.of(context).size.width * 0.45,
                            initialSelection: DatabaseService().detType(rType),
                            controller: ddmType,
                            onSelected: (String? value) {
                              // This is called when the user selects an item.
                              print(value);
                              setState(() {
                                dropdownTypeValue = value!;
                              });
                            },
                            dropdownMenuEntries: rTName.map<DropdownMenuEntry<String>>((var value) {
                              return DropdownMenuEntry<String>(value: value, label: value);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                          child: Text('Payment Status:', style: TextStyle(fontSize: 18)),
                        ),
                        Container(
                          child: DropdownMenu<String>(
                            width: MediaQuery.of(context).size.width * 0.45,
                            initialSelection: DatabaseService().detStatus(rStatus),
                            controller: ddmStatus,
                            onSelected: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                dropdownStatusValue = value!;
                              });
                            },
                            dropdownMenuEntries: rSName.map<DropdownMenuEntry<String>>((var value) {
                              return DropdownMenuEntry<String>(value: value, label: value);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                          child: Text('Repeat:', style: TextStyle(fontSize: 18)),
                        ),
                        Container(
                          child: DropdownMenu<String>(
                            enabled: false,
                            width: MediaQuery.of(context).size.width * 0.45,
                            initialSelection: DatabaseService().detFreq(rFrequency),
                            controller: ddmFrequency,
                            onSelected: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                dropdownRepeatValue = value!;
                              });
                            },
                            dropdownMenuEntries: rFName.map<DropdownMenuEntry<String>>((var value) {
                              return DropdownMenuEntry<String>(value: value, label: value);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                          child: Text('Payment Date:', style: TextStyle(fontSize: 18)),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            rPaidDate,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /* Start Here
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                child: Text('Duration:', style: TextStyle(fontSize: 18)),
              ),

              Column(
                children: <Widget>[
                  ListTile(
                    title: const Text('Forever'),
                    leading: Radio<ReminderDuration>(
                      value: ReminderDuration.Forever,
                      groupValue: _duration,
                      onChanged: null,
                    ),
                  ),
                  ListTile(
                    // title: const Text('Until'),
                    // onTap: ,
                    title: Row(
                      children: [
                        Text('Until'),
                        Visibility(
                          visible: isDurationVisible(vDuration),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20.0, right: 10.0),
                                child: ElevatedButton(
                                  onPressed: null,
                                  child: Icon(Icons.calendar_month),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text(
                                  setDateEnd('${_dateDuration.year}-${_dateDuration.month.toString().padLeft(2, '0')}-${_dateDuration.day.toString().padLeft(2, '0')}'),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    leading: Radio<ReminderDuration>(
                      value: ReminderDuration.Until,
                      groupValue: _duration,
                      onChanged: null,
                    ),
                  ),
                ],
              ),

              Until Here */

              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(10, 30, 0, 5),
                child: Text('Notes:', style: TextStyle(fontSize: 18)),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: TextField(
                  readOnly: true,
                  controller: rNotesController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[50],
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Colors.indigo),),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        )
                    ),
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[50],
                            ),
                            child: const Text('Update', style: TextStyle(color: Colors.indigo),),
                            onPressed: () {
                              setState(() {
                                rTitleController.text.isEmpty ? vTitleField = true : vTitleField = false;
                                rAmountController.text.isEmpty ? vAmountField = true : vAmountField = false;
                              });

                              if (vTitleField == false && vAmountField == false) {
                                String tempStatus = ddmStatus.text.toString();

                                DatabaseService().updateReminderStatus(rid, tempStatus, rPaidDate,);

                                Navigator.pop(context, "update");
                              }

                            },
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}
