import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:calculatorapp/databaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SimpleCalculator(),
    );
  }
}

class SimpleCalculator extends StatefulWidget {
  const SimpleCalculator({Key? key}) : super(key: key);

  @override
  _SimpleCalculatorState createState() => _SimpleCalculatorState();
}

class _SimpleCalculatorState extends State<SimpleCalculator> {
  bool isKmToMil = false;
  bool isHistoryPressed = false;
  double convertionResult = 0.0;
  String equation = "0";
  String result = "0";
  String expression = "";
  double equationFontSize = 38.0;
  double resultFontSide = 48.0;
  TextEditingController textValue = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  final Stream<QuerySnapshot> firebaseHistory =
      FirebaseFirestore.instance.collection("history").snapshots();

  buttonPressed(String buttonText) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    setState(() {
      if (buttonText == "C") {
        equation = "0";
        result = "0";
        equationFontSize = 38.0;
        resultFontSide = 48.0;
      } else if (buttonText == "\u232b") {
        equation = equation.substring(0, equation.length - 1);
        equationFontSize = 48.0;
        resultFontSide = 38.0;
        if (equation == "") {
          equation = "0";
        }
      } else if (buttonText == "km to mil") {
        isKmToMil = true;
      } else if (buttonText == "=") {
        equationFontSize = 38.0;
        resultFontSide = 48.0;

        expression = equation;

        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);
          ContextModel cm = ContextModel();
          result = "${exp.evaluate(EvaluationType.REAL, cm)}";

          DatabaseService("${equation}= ${result} - ${formattedDate}")
              .addHistory();
        } catch (e) {
          result = "Error";
        }
      } else {
        equationFontSize = 48.0;
        resultFontSide = 38.0;
        if (equation == "0") {
          equation = buttonText;
        } else {
          equation = equation + buttonText;
          print(buttonText);
        }
      }
    });
  }

  Widget buildButton(String buttonText, double buttonHeight, Color buttonColor,
      double fontSize) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1 * buttonHeight,
      color: buttonColor,
      child: TextButton(
        style: TextButton.styleFrom(
            side: BorderSide(
                color: Colors.white, width: 1, style: BorderStyle.solid)),
        child: Text(
          buttonText,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
              color: Colors.black),
        ),
        onPressed: () => buttonPressed(buttonText),
      ),
    );
  }

  Widget simpleCalc() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Calculator"),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  isHistoryPressed = true;
                });
              },
              child: Text("History"))
        ],
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.fromLTRB(10, 20, 20, 0),
            child: Text(
              equation,
              style: TextStyle(fontSize: equationFontSize),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.fromLTRB(10, 30, 20, 0),
            child: Text(
              result,
              style: TextStyle(fontSize: resultFontSide),
            ),
          ),
          Expanded(child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .75,
                child: Table(
                  children: [
                    TableRow(children: [
                      buildButton("C", 1, Colors.grey, 30.0),
                      buildButton("\u232b", 1, Colors.grey, 30.0),
                      buildButton("^", 1, Colors.grey, 30.0),
                    ]),
                    TableRow(children: [
                      buildButton("7", 1, Colors.grey.shade300, 30.0),
                      buildButton("8", 1, Colors.grey.shade300, 30.0),
                      buildButton("9", 1, Colors.grey.shade300, 30.0),
                    ]),
                    TableRow(children: [
                      buildButton("4", 1, Colors.grey.shade300, 30.0),
                      buildButton("5", 1, Colors.grey.shade300, 30.0),
                      buildButton("6", 1, Colors.grey.shade300, 30.0),
                    ]),
                    TableRow(children: [
                      buildButton("1", 1, Colors.grey.shade300, 30.0),
                      buildButton("2", 1, Colors.grey.shade300, 30.0),
                      buildButton("3", 1, Colors.grey.shade300, 30.0),
                    ]),
                    TableRow(children: [
                      buildButton(".", 1, Colors.grey.shade300, 30.0),
                      buildButton("0", 1, Colors.grey.shade300, 30.0),
                      buildButton("km to mil", 1, Colors.grey.shade300, 16.0),
                    ]),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Table(
                  children: [
                    TableRow(children: [
                      buildButton("/", 1, Colors.grey, 30.0),
                    ]),
                    TableRow(children: [
                      buildButton("*", 1, Colors.grey, 30.0),
                    ]),
                    TableRow(children: [
                      buildButton("-", 1, Colors.grey, 30.0),
                    ]),
                    TableRow(children: [
                      buildButton("+", 1, Colors.grey, 30.0),
                    ]),
                    TableRow(children: [
                      buildButton("=", 1, Colors.blue.shade300, 30.0),
                    ]),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget historyScreen() {
    return Scaffold(
        appBar: AppBar(
          title: Text("History"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isHistoryPressed = false;
                });
              },
              child: Text("back", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: firebaseHistory,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                final data = snapshot.requireData;
                return ListView.builder(
                    itemCount: data.size,
                    itemBuilder: (context, index) {
                      return Text("${data.docs[index]['equation']}");
                    });
              }),
        ));
  }

  Widget kmToMil() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Calculator"),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                setState(() {
                  isKmToMil = false;
                });
                print(isKmToMil);
              },
              child: Text(
                "back",
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black,
                ),
              )),
          Container(
            margin: EdgeInsets.fromLTRB(30.0, 10.0, 0, 0),
            child: Text(
              "Kilometre to miles",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          TextField(
            controller: textValue,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Killometre or miles',
            ),
          ),
          Row(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width * .5,
                  color: Colors.black,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white,
                            width: 1,
                            style: BorderStyle.solid)),
                    child: Text("km to mil",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      setState(() {
                        convertionResult =
                            (double.parse(textValue.text) * 0.62137119);
                        print(textValue.text);
                      });
                    },
                  )),
              Container(
                  width: MediaQuery.of(context).size.width * .5,
                  color: Colors.black,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white,
                            width: 1,
                            style: BorderStyle.solid)),
                    child: Text("mil to km",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      setState(() {
                        convertionResult =
                            (double.parse(textValue.text) * 1.609344);
                      });
                    },
                  ))
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text(
              "${convertionResult.toStringAsPrecision(5)}",
              style: TextStyle(fontSize: 40.0),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isKmToMil
        ? kmToMil()
        : (isHistoryPressed ? historyScreen() : simpleCalc());
  }
}
