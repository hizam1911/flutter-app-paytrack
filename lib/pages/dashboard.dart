import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:paytrack/pages/profile.dart';
import 'package:paytrack/pages/login.dart';
import 'package:paytrack/pages/managereminder.dart';
import 'package:paytrack/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paytrack/services/local_notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:pie_chart/pie_chart.dart';
import 'package:flip_card/flip_card.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:paytrack/services/chart_indicator.dart';
import 'dart:async';

// String webURL = "https://www.investopedia.com/articles/younginvestors/08/eight-tips.asp";
String webURL = "https://www.google.com/";
String username = "";
String email = "";
String age = "";
String gender = "";
String uid = "";
bool loadingBool = true;
bool needRefresh = false;
int totalQ = 0;
int currentPageIndex = 0;
List rID = [];
List rTitle = [];
List rAmount = [];
List rType = [];
List rStatus = [];
List rFrequency = [];
List rListFrequency = [];
// List tFM = ['Avoid debt', 'Plan for retirement', 'Borrow wisely', 'Insurance', 'Monitor spending'];
Map reminderMap = {};
double totalBillsPaid = 0;
double totalOutstandingBills = 0;
double totalDebtsPaid = 0;
double totalOutstandingDebts = 0;

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const MyDashboard(),
    );
  }
}

class MyDashboard extends StatefulWidget {
  const MyDashboard({super.key});

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard>
    with TickerProviderStateMixin {

  String refreshPage = "";
  int touchedIndex = -1;
  Timer? _timer;
  late TabController _tabController;
  late final WebViewController webcontroller;

  void getUsernameEmail() {
    uid = DatabaseService().getUID();
    final userRef = FirebaseFirestore.instance.collection("users").doc(uid.toString());

    userRef.get().then(
          (DocumentSnapshot doc) {
        // final data = doc.data() as Map<String, dynamic>;
        username = doc.get("username");
        email = doc.get("email");
        age = doc.get("age");
        gender = doc.get("gender");

        setWebURL();
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  void getRQueryTotalLocal() async {
    String tempUID = DatabaseService().getUID();
    final reminderRef = await FirebaseFirestore.instance.collection("reminders");

    reminderRef.where("userID", isEqualTo: tempUID).get().then(
          (querySnapshot) {
        print("Successfully completed");
        int counter = 0;
        double tempTotalBillsDebts = 0;
        totalBillsPaid = 0;
        totalOutstandingBills = 0;
        totalDebtsPaid = 0;
        totalOutstandingDebts = 0;

        for (var docSnapshot in querySnapshot.docs) {

          print('${docSnapshot.id} => ${docSnapshot.data()}');
          var reminders = docSnapshot.data();
          reminderMap = reminders;
          // reminderList.insert(counter, reminderMap);
          //process ID
          String typeTemp = "";
          String statusTemp = "";
          String reminderFrequencyTemp = "";

          DateTime dtTemp = DateTime.parse(reminderMap['reminderStartDate']);
          String monthTemp = "${dtTemp.month.toString().padLeft(2,'0')}";
          String dateTemp = "";
          String dayDateTemp = "";
          String dayWeekly = "";

          if (monthTemp == "01") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Jan";
          } else if (monthTemp == "02") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Feb";
          } else if (monthTemp == "03") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Mar";
          } else if (monthTemp == "04") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Apr";
          } else if (monthTemp == "05") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " May";
          } else if (monthTemp == "06") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Jun";
          } else if (monthTemp == "07") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Jul";
          } else if (monthTemp == "08") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Aug";
          } else if (monthTemp == "09") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Sep";
          } else if (monthTemp == "10") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Oct";
          } else if (monthTemp == "11") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Nov";
          } else if (monthTemp == "12") {
            dateTemp = "${dtTemp.day.toString().padLeft(2,'0')}" + " Dec";
          }

          dayDateTemp = "${dtTemp.day.toString().padLeft(2,'0')}";

          if (int.parse(dayDateTemp) == 01 || int.parse(dayDateTemp) == 21 || int.parse(dayDateTemp) == 31) {
            dayDateTemp = dayDateTemp + "st Day";
          } else if (int.parse(dayDateTemp) == 02 || int.parse(dayDateTemp) == 22 ) {
            dayDateTemp = dayDateTemp + "nd Day";
          } else if (int.parse(dayDateTemp) == 03 || int.parse(dayDateTemp) == 23 ) {
            dayDateTemp = dayDateTemp + "rd Day";
          } else {
            dayDateTemp = dayDateTemp + "th Day";
          }

          dayWeekly = DateFormat('EEEE').format(dtTemp).toString();

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

          if (reminderMap['frequencyID'] == "1") {
            reminderFrequencyTemp = "Once on " + dateTemp;
          } else if (reminderMap['frequencyID'] == "2") {
            reminderFrequencyTemp = "Weekly on " + dayWeekly;
          } else if (reminderMap['frequencyID'] == "3") {
            reminderFrequencyTemp = "Monthly on " + dayDateTemp;
          }

          //----------------------------------------------------------
          tempTotalBillsDebts = double.parse(reminderMap['reminderAmount'].toString());
          if (reminderMap['typeID'] == "1") {
            if (reminderMap['statusID'] == "1") {
              totalBillsPaid = totalBillsPaid + tempTotalBillsDebts;
            } else if (reminderMap['statusID'] == "2") {
              totalOutstandingBills = totalOutstandingBills + tempTotalBillsDebts;
            }
          } else if (reminderMap['typeID'] == "2") {
            if (reminderMap['statusID'] == "1") {
              totalDebtsPaid = totalDebtsPaid + tempTotalBillsDebts;
            } else if (reminderMap['statusID'] == "2") {
              totalOutstandingDebts = totalOutstandingDebts + tempTotalBillsDebts;
            }
          }
          //----------------------------------------------------------

          rID.insert(counter, docSnapshot.id);
          rTitle.insert(counter, reminderMap['reminderTitle']);
          rAmount.insert(counter, reminderMap['reminderAmount']);
          rType.insert(counter, typeTemp);
          rStatus.insert(counter, statusTemp);
          rListFrequency.insert(counter, reminderFrequencyTemp);
          counter++;
          print(counter);
          print(reminderMap['reminderTitle']);
          print(reminderFrequencyTemp);
          print(dtTemp);
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

  String printTest1(int n) {
    String meow = 'meow';
    print('touchedIndex1 = ' + n.toString());
    return meow;
  }

  String printTest2(int n) {
    String meow = 'meow';
    print('touchedIndex2 = ' + n.toString());
    return meow;
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      double tp;
      double bP = double.parse(totalBillsPaid.toStringAsFixed(2));
      double bO = double.parse(totalOutstandingBills.toStringAsFixed(2));
      double dP = double.parse(totalDebtsPaid.toStringAsFixed(2));
      double dO = double.parse(totalOutstandingDebts.toStringAsFixed(2));



      print('bP: ' + bP.toString());
      print('bO: ' + bO.toString());
      print('dP: ' + dP.toString());
      print('dO: ' + dO.toString());

      double totalBD = bP + bO + dP + dO;
      if (totalBD == 0) {
        totalBD = 1;
      }
      tp = (bP/totalBD) * 100;
      int pBP = tp.toInt();
      tp = (bO/totalBD) * 100;
      int pBO = tp.toInt();
      tp = (dP/totalBD) * 100;
      int pDP = tp.toInt();
      tp = (dO/totalBD) * 100;
      int pDO = tp.toInt();

      String sBP = pBP.toString();
      String sBO = pBO.toString();
      String sDP = pDP.toString();
      String sDO = pDO.toString();

      if (pBP == 0) {
        pBP = 1;
        sBP = '0';
      }
      if (pBO == 0) {
        pBO = 1;
        sBO = '0';
      }
      if (pDP == 0) {
        pDP = 1;
        sDP = '0';
      }
      if (pDO == 0) {
        pDO = 1;
        sDO = '0';
      }

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blueAccent,
            value: pBP.toDouble(),
            title: '${sBP}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.yellowAccent,
            value: pBO.toDouble(),
            title: '${sBO}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.purpleAccent,
            value: pDP.toDouble(),
            title: '${sDP}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.greenAccent,
            value: pDO.toDouble(),
            title: '${sDO}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  void showSummary(BuildContext context, String s1, String s2) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150, // Adjust height as needed
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
                  child: Text(s1, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text(s2, style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  Map<String, double> initDashPie() {
    Map<String, double> dataMap = {
      "Bills Paid": 5,
      "Out. Bills": 3,
      "Debts Paid": 2,
      "Out. Debts": 2,
    };
    return dataMap;
  }

  Map<String, double> initTipsPie() {
    Map<String, double> dataMap = {
      "Needs": 5,
      "Wants": 3,
      "Savings": 2,
    };
    return dataMap;
  }

  void setWebURL(){
    String baseURL = "https://www.google.com/search?q=financial+tips";
    webURL = baseURL + "+" + gender.toString() + "+" + age.toString();
    webcontroller.loadRequest(Uri.parse(webURL));
    print("URL: " + webURL);
    print("gender: " + gender.toString());
    print("age: " + age.toString());
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    this.refreshPage = "init";
    webcontroller = WebViewController()
      // disabled javascript to block ads
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(webURL),
      );
  }

  // Future<bool> _exitApp(BuildContext context) async {
  //   if (await webcontroller.canGoBack()) {
  //     print("onwill goback");
  //     webcontroller.goBack();
  //     return Future.value(true);
  //   } else {
  //     print("No back history item");
  //     return Future.value(false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double navBarHeight = MediaQuery.of(context).size.height - (kBottomNavigationBarHeight * 4);
    getUsernameEmail();

    final ThemeData theme = Theme.of(context);
    final _tabBar = TabBar(
      indicatorColor: Colors.indigo,
      labelColor: Colors.indigo[800],
      controller: _tabController,
      tabs: [
        Tab(
          text: "Bills/Debts",
        ),
        Tab(
          text: "Reminder",
        ),
      ],
    );

    if(loadingBool) {
      getRQueryTotalLocal();

      // return CircularProgressIndicator();
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
      return PopScope(
          canPop: false,
          child: Scaffold(
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                  loadingBool = true;
                  // if (currentPageIndex == 0) {
                  //   loadingBool = true;
                  // }
                  // if (currentPageIndex == 1) {
                  //   loadingBool = true;
                  // }
                });
              },
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              indicatorColor: Colors.indigo[50],
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.checklist),
                  label: 'Bills',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tips_and_updates),
                  label: 'Tips',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
            body: <Widget>[
              /// Home page
              Container(
                child: Center(child: new Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.white,
                      title: Text('My Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
                                child: Text('MONTHLY SUMMARY', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
                                child: AspectRatio(
                                  aspectRatio: 2,
                                  child: PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                          _timer?.cancel();
                                          _timer = Timer(const Duration(milliseconds: 1), () {
                                            setState(() {
                                              if (!event.isInterestedForInteractions ||
                                                  pieTouchResponse == null ||
                                                  pieTouchResponse.touchedSection == null) {
                                                print('Index: ' + touchedIndex.toString());
                                                if(touchedIndex == 0) {
                                                  showSummary(context, 'Bills Paid', 'RM${totalBillsPaid.toStringAsFixed(2)}');
                                                } else if(touchedIndex == 1) {
                                                  showSummary(context, 'Outstanding Bills', 'RM${totalOutstandingBills.toStringAsFixed(2)}');
                                                } else if(touchedIndex == 2) {
                                                  showSummary(context, 'Debts Paid', 'RM${totalDebtsPaid.toStringAsFixed(2)}');
                                                } else if(touchedIndex == 3) {
                                                  showSummary(context, 'Outstanding Debts', 'RM${totalOutstandingDebts.toStringAsFixed(2)}');
                                                }
                                                touchedIndex = -1;
                                                return;
                                              }
                                              touchedIndex = pieTouchResponse
                                                  .touchedSection!.touchedSectionIndex;
                                            });
                                          });
                                        },
                                      ),
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      sectionsSpace: 0,
                                      centerSpaceRadius: 50,
                                      sections: showingSections(),
                                    ),
                                  ),
                                ),
                                // PieChart(
                                //     dataMap: initDashPie(),
                                //     chartRadius: MediaQuery.of(context).size.width / 1.5,
                                //     legendOptions: LegendOptions(
                                //       legendPosition: LegendPosition.bottom,
                                //       showLegendsInRow: true,
                                //     )
                                // ),
                              ),

                              IntrinsicHeight(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 60, 30, 20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Indicator(
                                          color: Colors.blueAccent,
                                          text: 'Bills Paid',
                                          isSquare: false,
                                        ),
                                      ),
                                      Expanded(
                                        child: Indicator(
                                          color: Colors.yellowAccent,
                                          text: 'Outstanding Bills',
                                          isSquare: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              IntrinsicHeight(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Indicator(
                                          color: Colors.purpleAccent,
                                          text: 'Debts Paid',
                                          isSquare: false,
                                        ),
                                      ),
                                      Expanded(
                                        child: Indicator(
                                          color: Colors.greenAccent,
                                          text: 'Outstanding Debts',
                                          isSquare: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    )
                )),
              ),

              /// Bills page
              Container(
                child: Center(child: new Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.white,
                      title: Text('My Bills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      centerTitle: true,
                      //elevation: 0,
                    ),
                    body: Stack(
                      children: [
                        ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.white,
                                    alignment: Alignment.topCenter,
                                    child: Column(
                                      children: <Widget>[
                                        _tabBar,
                                        Expanded( // needed for TabBar View to show correctly
                                          child: TabBarView(
                                            controller: _tabController,
                                            children: [
                                              //Listview Bills Debts
                                              ListView(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          height: navBarHeight,
                                                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                                          child: ListView.builder(
                                                              itemCount: totalQ,
                                                              itemBuilder: (BuildContext context, int index) {

                                                                return Card(
                                                                  color: Colors.white,
                                                                  surfaceTintColor: Colors.indigo[400],
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
                                                                    onTap: () async {
                                                                      print("Printing " + rID[index] + "...");
                                                                      manageReminder(2, rID[index]);

                                                                      String result = await Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(builder: (context) => ManageReminder()),
                                                                      );
                                                                      setState(() {
                                                                        this.refreshPage = result;
                                                                        loadingBool = true;
                                                                      });

                                                                    },
                                                                  ),
                                                                );

                                                              }),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              //ListView Reminders
                                              ListView(
                                                shrinkWrap: true,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          height: navBarHeight,
                                                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                                          child: ListView.builder(
                                                              itemCount: totalQ,
                                                              itemBuilder: (BuildContext context, int index) {

                                                                return Card(
                                                                  color: Colors.white,
                                                                  surfaceTintColor: Colors.indigo[400],
                                                                  child: ListTile(
                                                                    leading: rlType(rType[index]),
                                                                    title: Text(rTitle[index]),
                                                                    subtitle: Row(
                                                                      children: [
                                                                        Text(rType[index] + " | "),
                                                                        Text(rListFrequency[index], style: TextStyle(color: Colors.indigo[800])),
                                                                      ],
                                                                    ),//rlText(rType[index], rStatus[index]),
                                                                    trailing: Icon(Icons.keyboard_arrow_right_rounded),
                                                                    onTap: () async {
                                                                      print("Printing " + rID[index] + "...");
                                                                      manageReminder(3, rID[index]);

                                                                      String result = await Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(builder: (context) => ManageReminder()),
                                                                      );
                                                                      setState(() {
                                                                        this.refreshPage = result;
                                                                        loadingBool = true;
                                                                      });

                                                                    },
                                                                  ),
                                                                );

                                                              }),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 20.0, // Adjust for spacing as needed
                          right: 20.0,  // Adjust for spacing as needed
                          child: FloatingActionButton(
                            backgroundColor: Colors.indigo[100],
                            child: Icon(Icons.add),
                            onPressed: () async  {
                              manageReminder(1);
                              String result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ManageReminder()),
                              );
                              setState(() {
                                this.refreshPage = result;
                                loadingBool = true;
                              });
                              //print(nameController.text);
                              //print(passwordController.text);
                            },
                          ),
                        ),
                      ],
                    ),
                )),
              ),

              /// Tips page
              Container(
                child: Center(child: new Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.white,
                      title: Text('Tips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      centerTitle: true,
                      //elevation: 0,
                    ),
                    body: PopScope(
                      canPop: false,
                      onPopInvoked: (didPop) async {
                        if (await webcontroller.canGoBack()) {
                        print("on will goback");
                        webcontroller.goBack();
                        return Future.value(true);
                        } else {
                        print("No back history item");
                        return Future.value(false);
                        }
                      },
                      child: WebViewWidget(
                        controller: webcontroller,
                      ),
                    ),
                )),
              ),

              /// Profile page
              Container(
                child: Center(child: new Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.white,
                    title: Text('My Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    centerTitle: true,
                    //elevation: 0,
                  ),
                  body: ListView(
                    children: [
                      Container(
                        height: 150.0,
                        width: 150.0,
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: CircleAvatar(
                            radius: 48, // Image radius
                            backgroundImage: AssetImage('images/user.png'),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 10),
                        child: Text(username.toString()),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 10, bottom: 40),
                        child: Text(email.toString()),
                      ),
                      Container(
                          height: 50,
                          child: TextButton(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: const Text('Edit Profile',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.black26)
                                    )
                                )
                            ),
                            onPressed: () async {
                              String result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Profile()),
                              );
                              setState(() {
                                this.refreshPage = result;
                                loadingBool = true;
                              });
                            },
                          )
                      ),
                      Container(
                          height: 50,
                          child: TextButton(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: const Text('Sign Out',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.black26)
                                    )
                                )
                            ),
                            onPressed: () {

                              LocalNotificationService().deleteNotificationSignOut();
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
                              currentPageIndex = 0;
                              loadingBool = true;

                            },
                          )
                      ),

                      // Container(
                      //     height: 50,
                      //     child: TextButton(
                      //       child: Align(
                      //         alignment: Alignment.centerLeft,
                      //         child: const Text('Test Notification',
                      //           style: TextStyle(color: Colors.black87),
                      //         ),
                      //       ),
                      //       style: ButtonStyle(
                      //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      //               RoundedRectangleBorder(
                      //                   side: BorderSide(color: Colors.black26)
                      //               )
                      //           )
                      //       ),
                      //       onPressed: () {
                      //         // LocalNotificationService().initNotification();
                      //         LocalNotificationService().showNotification(title: 'This is the title!', body: 'This is the body!');
                      //         print('Added Notification');
                      //         print(DateTime.now());
                      //       },
                      //     )
                      // ),

                      // Container(
                      //     height: 50,
                      //     child: TextButton(
                      //       child: Align(
                      //         alignment: Alignment.centerLeft,
                      //         child: const Text('Test Once Schedule Notification',
                      //           style: TextStyle(color: Colors.black87),
                      //         ),
                      //       ),
                      //       style: ButtonStyle(
                      //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      //               RoundedRectangleBorder(
                      //                   side: BorderSide(color: Colors.black26)
                      //               )
                      //           )
                      //       ),
                      //       onPressed: () {
                      //         int notificationID = 0;
                      //         String title = 'Payment Reminder';
                      //         String body = 'Notification Body';
                      //         DateTime time = DateTime.now().add(Duration(seconds: 3));
                      //         LocalNotificationService().scheduleOneTimeNotification(notificationID, title, body, time);
                      //         print('debug successful');
                      //       },
                      //     )
                      // ),

                      // Container(
                      //     height: 50,
                      //     child: TextButton(
                      //       child: Align(
                      //         alignment: Alignment.centerLeft,
                      //         child: const Text('Test Weekly Schedule Notification',
                      //           style: TextStyle(color: Colors.black87),
                      //         ),
                      //       ),
                      //       style: ButtonStyle(
                      //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      //               RoundedRectangleBorder(
                      //                   side: BorderSide(color: Colors.black26)
                      //               )
                      //           )
                      //       ),
                      //       onPressed: () {
                      //         int notificationID = 0;
                      //         String title = 'Weekly Notification';
                      //         String body = 'Weekly body';
                      //         TimeOfDay time = TimeOfDay(hour: 10, minute: 0);
                      //         Day dayOfWeek = Day.wednesday;
                      //         LocalNotificationService().scheduleWeeklyNotification(notificationID, title, body, time, dayOfWeek);
                      //       },
                      //     )
                      // ),

                      // Container(
                      //     height: 50,
                      //     child: TextButton(
                      //       child: Align(
                      //         alignment: Alignment.centerLeft,
                      //         child: const Text('Test Monthly Schedule Notification 1',
                      //           style: TextStyle(color: Colors.black87),
                      //         ),
                      //       ),
                      //       style: ButtonStyle(
                      //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      //               RoundedRectangleBorder(
                      //                   side: BorderSide(color: Colors.black26)
                      //               )
                      //           )
                      //       ),
                      //       onPressed: () {
                      //         int notificationID = 0;
                      //         String title = 'Monthly Notification 1';
                      //         String body = '1st day at 8AM';
                      //         TimeOfDay time = TimeOfDay(hour: 8, minute: 0);
                      //         int dayOfMonth = 1;
                      //         LocalNotificationService().scheduleMonthlyNotification(notificationID, title, body, time, dayOfMonth);
                      //       },
                      //     )
                      // ),

                      // Container(
                      //     height: 50,
                      //     child: TextButton(
                      //       child: Align(
                      //         alignment: Alignment.centerLeft,
                      //         child: const Text('Test Monthly Schedule Notification 2',
                      //           style: TextStyle(color: Colors.black87),
                      //         ),
                      //       ),
                      //       style: ButtonStyle(
                      //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      //               RoundedRectangleBorder(
                      //                   side: BorderSide(color: Colors.black26)
                      //               )
                      //           )
                      //       ),
                      //       onPressed: () {
                      //         int notificationID = 1;
                      //         String title = 'Monthly Notification 2';
                      //         String body = '3rd day at 1PM';
                      //         TimeOfDay time = TimeOfDay(hour: 13, minute: 0);
                      //         int dayOfMonth = 3;
                      //         LocalNotificationService().scheduleMonthlyNotification(notificationID,title, body, time, dayOfMonth);
                      //       },
                      //     )
                      // ),

                      // Container(
                      //     height: 50,
                      //     child: TextButton(
                      //       child: Align(
                      //         alignment: Alignment.centerLeft,
                      //         child: const Text('Test Convert String to Day',
                      //           style: TextStyle(color: Colors.black87),
                      //         ),
                      //       ),
                      //       style: ButtonStyle(
                      //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      //               RoundedRectangleBorder(
                      //                   side: BorderSide(color: Colors.black26)
                      //               )
                      //           )
                      //       ),
                      //       onPressed: () {
                      //         // DatabaseService().testConvertStringtoDay();
                      //       },
                      //     )
                      // ),




                    ],
                  ),
                )),
              ),
            ][currentPageIndex],
          ));
    }


  }
}

