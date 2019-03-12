import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flare_flutter/flare_actor.dart';

import 'package:http/http.dart' as http;

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(M());

class M extends StatelessWidget {
  @override
  Widget build(context) {
    return MaterialApp(
      home: SplashScreen(),
      theme: ThemeData(
        primaryColor: Colors.green,
        accentColor: Colors.green,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startCountdown() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, () {
      Navigator.of(context)
          .pushReplacement(new MaterialPageRoute(builder: (context) {
        return H();
      }));
    });
  }

  @override
  void initState() {
    startCountdown();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FlareActor(
            'assets/splash_background.flr',
            alignment: Alignment.center,
            fit: BoxFit.contain,
            animation: 'fade',
          ),
        ],
      ),
    );
  }
}

class H extends StatefulWidget {
  /// TODO COLOR PALETTE https://coolors.co/56c450-454851-de1a1a-ffffff-34d1bf
  /// TODO FLARE ASSETS https://www.2dimensions.com/a/tamiyo/files/flare/new-file-2

  List<dynamic> savedItems = [];

//  List<dynamic> savedItems = [
//    {
//      'fromStartToEnd': '3',
//      'name': 'Granny Smith Apple',
//      'imageUrl':
//          'https://images-na.ssl-images-amazon.com/images/I/81N4hYrr%2BxL._SY355_.jpg',
//      'upc': '2134001239012',
//      'startDate': '2019-03-10 00:00:00.000',
//      'endDate': '2019-03-14 00:00:00.000',
//      'percent': 0.0,
//    },
//    {
//      'fromStartToEnd': '7',
//      'name': 'Broccoli',
//      'imageUrl':
//          'https://www.producemarketguide.com/sites/default/files/Commodities.tar/Commodities/broccoli_commodity-page.png',
//      'upc': '2134001239012',
//      'startDate': '2019-03-10 00:00:00.000',
//      'endDate': '2019-03-18 00:00:00.000',
//      'percent': 0.0,
//    },
//    {
//      'fromStartToEnd': '2',
//      'name': 'Pineapple',
//      'imageUrl':
//          'https://images-na.ssl-images-amazon.com/images/I/71%2BqAJehpkL._SY355_.jpg',
//      'upc': '2134001239012',
//      'startDate': '2019-03-10 00:00:00.000',
//      'endDate': '2019-03-13 00:00:00.000',
//      'percent': 0.0,
//    },
//  ];

  @override
  _H createState() => _H();
}

class _H extends State<H> {
  final BarcodeDetector barcodeDetector =
      FirebaseVision.instance.barcodeDetector();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  ProgressHUD _progressHUD;
  SharedPreferences preferences;

  bool _ready = false;
  var upc;

  Future getImage() async {
    final File image = await ImagePicker.pickImage(source: ImageSource.camera);
    bool _detected = true;

    setState(() {
      _progressHUD.state.show();
    });

    List<Barcode> barcodes;
    image != null
        ? barcodes = await barcodeDetector
            .detectInImage(FirebaseVisionImage.fromFile(image))
        : barcodes = [];

    if (barcodes.length < 1) {
      _detected = false;
      print('Barcode Detection Failed');
    } else {
      upc = barcodes[0].rawValue;
    }

    setState(() {
      _progressHUD.state.dismiss();
    });

    if (_detected) {
      /// TODO Convert this to a Cloud Firestore function
      Future<String> _convertToUPCA(String UPCE) async {
        String manufacturerType = UPCE[6];
        String UPCA = "0";

        switch (manufacturerType) {
          case "0":
          case "1":
          case "2":
            UPCA += UPCE[1] +
                UPCE[2] +
                UPCE[6] +
                '0000' +
                UPCE.substring(3, 6) +
                UPCE[7];
            break;
          case "3":
            UPCA +=
                UPCE.substring(1, 4) + '00000' + UPCE.substring(4, 6) + UPCE[7];
            break;
          case "4":
            UPCA += UPCE.substring(1, 5) + '00000' + UPCE[5] + UPCE[7];
            break;
          case "5":
          case "6":
          case "7":
          case "8":
          case "9":
            UPCA += UPCE.substring(1, 6) + '0000' + UPCE[6] + UPCE[7];
        }

        return UPCA;
      }

      if (upc.length < 12) {
        upc = await _convertToUPCA(upc);
        print("Converted UPCA: " + upc);
      }

      var response = await http.get(
          'https://api.upcitemdb.com/prod/trial/lookup?upc=' + upc,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          });

      var data = json.decode(response.body);
      print('Body: ' + data.toString());
      print('Items: ' + data['items'].toString());

      showDialog(
          context: this.context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return C(
              data: data,
              preferences: preferences,
              savedItems: widget.savedItems,
              flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
            );
          }).then((d) {
        setState(() {});
      });
    }
  }

  void _G() async {
    preferences = await SharedPreferences.getInstance();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        new InitializationSettings(initializationSettingsAndroid, null);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    widget.savedItems = (preferences.getString('user-data') != null
        ? json.decode(preferences.getString('user-data'))
        : [
            {
              'fromStartToEnd': '3',
              'name': 'Granny Smith Apple',
              'imageUrl':
                  'https://images-na.ssl-images-amazon.com/images/I/81N4hYrr%2BxL._SY355_.jpg',
              'upc': '2134001239012',
              'startDate': '2019-03-10 00:00:00.000',
              'endDate': '2019-03-14 00:00:00.000',
              'percent': 0.0,
            },
            {
              'fromStartToEnd': '7',
              'name': 'Broccoli',
              'imageUrl':
                  'https://www.producemarketguide.com/sites/default/files/Commodities.tar/Commodities/broccoli_commodity-page.png',
              'upc': '2134001239012',
              'startDate': '2019-03-10 00:00:00.000',
              'endDate': '2019-03-18 00:00:00.000',
              'percent': 0.0,
            },
            {
              'fromStartToEnd': '2',
              'name': 'Pineapple',
              'imageUrl':
                  'https://images-na.ssl-images-amazon.com/images/I/71%2BqAJehpkL._SY355_.jpg',
              'upc': '2134001239012',
              'startDate': '2019-03-10 00:00:00.000',
              'endDate': '2019-03-13 00:00:00.000',
              'percent': 0.0,
            },
          ]);

    for (int i = 0; i < widget.savedItems.length; i++) {
      widget.savedItems[i]['daysLeft'] =
          (DateTime.parse(widget.savedItems[i]['endDate'])
                  .difference(DateTime.now()))
              .inDays;
      widget.savedItems[i]['percent'] = widget.savedItems[i]['daysLeft'] /
          DateTime.parse(widget.savedItems[i]['endDate'])
              .difference(DateTime.parse(widget.savedItems[i]['startDate']))
              .inDays;
    }

    widget.savedItems.sort((a, b) => a['percent'].compareTo(b['percent']));

    print('Done with stuff, calling setState()');
    setState(() {
      _ready = true;
    });
  }

  @override
  void initState() {
    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black12,
      loading: false,
      color: Colors.white,
      containerColor: Colors.blue,
      borderRadius: 5.0,
      text: 'Loading...',
    );
    _G();
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Items'),
        centerTitle: true,
      ),
      body: _ready
          ? Stack(
              children: <Widget>[
                Center(
                  child: ListView.separated(
                    itemCount: widget.savedItems.length,
                    padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: _ready
                                ? Image.network(
                                    widget.savedItems[index]['imageUrl'],
                                  ).image
                                : null,
                            child: _ready ? null : CircularProgressIndicator(),
                          ),
                          title: Text(
                            widget.savedItems[index]['name'],
                            maxLines: 2,
                          ),
                          subtitle: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('0'),
                                  LinearPercentIndicator(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    percent: widget.savedItems[index]
                                        ['percent'],
                                    progressColor: (widget.savedItems[index]
                                                ['percent'] >
                                            .5)
                                        ? Colors.green
                                        : Colors.amber,
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  Text(
                                    widget.savedItems[index]['fromStartToEnd'],
                                  )
                                ],
                              ),
                              Text(
                                  'Expires in ${widget.savedItems[index]['daysLeft']} day(s)')
                            ],
                          ),
                          trailing: IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Remove Item?',
                                        ),
                                        content: RichText(
                                            text: TextSpan(
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                                children: [
                                              TextSpan(
                                                  text:
                                                      'Are you sure you want to remove '),
                                              TextSpan(
                                                  text:
                                                      '${widget.savedItems[index]['name']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text: ' from your items?')
                                            ])),
                                        actions: <Widget>[
                                          MaterialButton(
                                            textColor: Colors.red,
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          MaterialButton(
                                            textColor: Colors.green,
                                            child: Text('Remove'),
                                            onPressed: () async {
                                              preferences.setString(
                                                  'user-data',
                                                  json.encode('{ \"items\": ' +
                                                      widget.savedItems
                                                          .toString() +
                                                      "}"));
                                              await flutterLocalNotificationsPlugin
                                                  .cancel(widget
                                                      .savedItems[index]['name']
                                                      .hashCode);
                                              widget.savedItems.removeAt(index);

                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    }).then((d) {
                                  setState(() {});
                                });
                              }),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(
                          color: Colors.transparent,
                          height: 24.0,
                        ),
                  ),
                ),
                _progressHUD,
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {},
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.add),
                            Padding(
                              child: Text('Add an Item'),
                              padding: EdgeInsets.only(left: 8.0),
                            )
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: getImage,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.add_a_photo),
                            Padding(
                              child: Text('Scan a Barcode'),
                              padding: EdgeInsets.only(left: 8.0),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class C extends StatelessWidget {
  C(
      {this.data,
      this.preferences,
      this.savedItems,
      this.flutterLocalNotificationsPlugin});

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Map<String, dynamic> data;
  SharedPreferences preferences;
  List<dynamic> savedItems;
  DateTime expirationDate;

  @override
  Widget build(BuildContext context) {
    var d = data['items'][0];

    return SimpleDialog(
      titlePadding: EdgeInsets.all(16.0),
      title: Text(
        d['title'].toString(),
        maxLines: 2,
      ),
      contentPadding: EdgeInsets.all(16.0),
      children: <Widget>[
        Image.network(
            d['images'].length > 0
                ? d['images'][0].toString()

                /// TODO Change to null image hosted @ Cloud Firestore
                : 'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg',
            fit: BoxFit.cover),
        DateTimePickerFormField(
          inputType: InputType.date,
          onChanged: (d) {
            expirationDate = d;
          },
          format: DateFormat('yyyy-MM-dd'),
          editable: false,
          decoration: InputDecoration(
            labelText: 'Expiration Date',
            prefixIcon: Icon(Icons.date_range),
            hasFloatingPlaceholder: false,
          ),
        ),
        Divider(
          color: Colors.transparent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                var fromStartToEnd =
                    expirationDate.difference(DateTime.now()).inDays;

                savedItems.add({
                  'fromStartToEnd': fromStartToEnd.toString(),
                  'daysLeft': fromStartToEnd.toString(),
                  'name': d['title'],
                  'imageUrl': d['images'].length > 0
                      ? d['images'][0]
                      : 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/NA_cap_icon.svg/423px-NA_cap_icon.svg.png',
                  'upc': d['upc'],
                  'startDate': DateTime.now().toIso8601String(),
                  'percent': 1.0,
                  'endDate': expirationDate.toIso8601String()
                });

                preferences.setString('user-data',
                    json.encode('{ \"items\": ' + savedItems.toString() + "}"));

                var scheduledNotificationDateTime =
                    new DateTime.now().add(new Duration(days: fromStartToEnd));
                var androidPlatformChannelSpecifics =
                    new AndroidNotificationDetails(
                        'Eden-Push-Notifications',
                        'Push Notifications',
                        'Push Notifications about your Eden food items!',
                        priority: Priority.High,
                        channelAction:
                            AndroidNotificationChannelAction.CreateIfNotExists);
                NotificationDetails platformChannelSpecifics =
                    new NotificationDetails(
                        androidPlatformChannelSpecifics, null);
                await flutterLocalNotificationsPlugin.schedule(
                    d['title'].hashCode,
                    'Spoil Alert!',
                    '${d['title']} is going to spoil! Check up on it!',
                    scheduledNotificationDateTime,
                    platformChannelSpecifics);
                Navigator.of(context).pop();
              },
              child: Text('Submit', style: TextStyle(color: Colors.green)),
            ),
          ],
        )
      ],
    );
  }
}
