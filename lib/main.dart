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
  List<String> savedItems = [
    '4',
    'Rosmary Spices',
    'https://cdn.shopify.com/s/files/1/1225/3182/products/rosemary-tea-top-close.jpg?v=1504589423',
    '2134001239012',
    '4',
    'Rosmary Spices',
    'https://cdn.shopify.com/s/files/1/1225/3182/products/rosemary-tea-top-close.jpg?v=1504589423',
    '2134001239012',
    '4',
    'Rosmary Spices',
    'https://cdn.shopify.com/s/files/1/1225/3182/products/rosemary-tea-top-close.jpg?v=1504589423',
    '2134001239012',
  ];

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
      print(barcodes[0].rawValue);
    }

    setState(() {
      _progressHUD.state.dismiss();
    });

    if (_detected) {
      Navigator.push(context,
          new MaterialPageRoute(builder: (BuildContext context) {
        return C(
          upc: barcodes[0].rawValue,
          savedItems: widget.savedItems,
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        );
      }));
    }
  }

  void _G() async {
    preferences = await SharedPreferences.getInstance();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        new InitializationSettings(initializationSettingsAndroid, null);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    widget.savedItems = preferences.getStringList('user-data') ?? [];
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
      body: Stack(
        children: <Widget>[
          Center(
            child: ListView.separated(
              itemCount: (widget.savedItems.length / 4).floor(),
              padding: EdgeInsets.all(8.0),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: _ready
                          ? Image.network(
                              widget.savedItems[4 * index + 2],
                            ).image
                          : null,
                      child: _ready ? null : CircularProgressIndicator(),
                    ),
                    title: Text(widget.savedItems[4 * index + 1], maxLines: 2,),
                    subtitle: Row(children: <Widget>[
                      Text('0'),
                      /// If percent is < 0 .3 change to red
                      LinearPercentIndicator(width: 200, percent: 0.5, progressColor: Colors.red,),
                      Text('3')
                    ],),
//                        Text(widget.savedItems[4 * index] + ' days left!'),
                    onTap: () {
                      /// TODO Implement onTap -> DetailsPage
//                    savedItems[4 * index + 2]
                    },
                    trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Are you sure?',
                                  ),
                                  actions: <Widget>[
                                    MaterialButton(
                                      textColor: Colors.white,
                                      child: Text('Cancel'),
                                      color: Colors.red,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    MaterialButton(
                                      textColor: Colors.white,
                                      child: Text('Remove'),
                                      color: Colors.green,
                                      onPressed: () {
                                        widget.savedItems.removeRange(
                                            4 * index, 4 * index + 4);
                                        preferences.setStringList(
                                            'user-data', widget.savedItems);
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
              separatorBuilder: (BuildContext context, int index) => Divider(
                    color: Colors.transparent,
                height: 8.0,
                  ),
            ),
          ),
          _progressHUD
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: getImage,
        icon: Icon(Icons.photo_camera),
        label: Text('Scan A Barcode'),
      ),
    );
  }
}

class C extends StatefulWidget {
  C(
      {this.upc,
      this.savedItems,
      this.fcm,
      this.flutterLocalNotificationsPlugin});

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String upc;
  String fcm;
  List<String> savedItems;

  _C createState() => new _C(upc: upc);
}

class _C extends State<C> {
  _C({this.upc});

  String upc;
  DateTime expirationDate;
  Map<String, dynamic> data;

  SharedPreferences preferences;

  bool _ready = false;

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
        UPCA += UPCE.substring(1, 4) + '00000' + UPCE.substring(4, 6) + UPCE[7];
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

  void _G() async {
    preferences = await SharedPreferences.getInstance();

    data = {
      'items': [
        {
          'ean': 0078742040370,
          'title':
              'Primal Strips Meatless Vegan Jerky-Variety Gift Pack Sampler; 24 Assorted 1 Ounce Strips',
          'description': 'This is a description',
          'upc': 078742040370,
          'asin': 'B00L9IS504',
          'brand': 'Primal Spirit Food, Inc.',
          'model': null,
          'lowest_recorded_price': 9.99,
          'highest_recorded_price': 174.99,
          'images': [],
          'elid': 283158252884
        }
      ]
    };
//    if (upc.length < 12) {
//      upc = await _convertToUPCA(upc);
//      print("Converted UPCA: " + upc);
//    }
//
//    var response = await http.get(
//        'https://api.upcitemdb.com/prod/trial/lookup?upc=' + upc,
//        headers: {
//          'Content-Type': 'application/json',
//          'Accept': 'application/json'
//        });
//
//    data = json.decode(response.body);
//    print('Body: ' + data.toString());
//    print('Items: ' + data['items'].toString());

    setState(() {
      _ready = true;
    });
  }

  @override
  void initState() {
    _G();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: _ready
            ? Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(data['items'][0]['title'].toString()),
                    Divider(
                      color: Colors.transparent,
                    ),
                    Image.network(
                      data['items'][0]['images'].length > 0
                          ? data['items'][0]['images'][0].toString()

                          /// TODO Change to null image hosted @ Cloud Firestore
                          : 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/NA_cap_icon.svg/423px-NA_cap_icon.svg.png',
                      fit: BoxFit.cover,
                      scale: 1.5,
                    ),
                    Divider(
                      color: Colors.transparent,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Average Price: \$' +
                            data['items'][0]['lowest_recorded_price']
                                .toString()),
                        Text('UPC: ' + data['items'][0]['upc'].toString())
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: DateTimePickerFormField(
                            inputType: InputType.date,
                            onChanged: (d) {
                              expirationDate = d;
                            },
                            format: DateFormat('yyyy-MM-dd'),
                            editable: false,
                            decoration: InputDecoration(
                              labelText: 'Expiration Date',
                              counterText: 'Expiration Date',
                              hasFloatingPlaceholder: false,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: MaterialButton(
                            onPressed: () async {
                              /// TODO Note the way this is setup
                              /// 1. Days Left TODO Parse this value
                              /// 2. Name
                              /// 3. ImageURL

                              widget.savedItems
                                ..add(expirationDate
                                    .difference(DateTime.now())
                                    .inDays
                                    .toString())
                                ..add(data['items'][0]['title'])
                                ..add(data['items'][0]['images'].length > 0
                                    ? data['items'][0]['images'][0]

                                    /// TODO Change this hardcoded value to something on Firestore...
                                    : 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/NA_cap_icon.svg/423px-NA_cap_icon.svg.png')
                                ..add(upc);

                              preferences.setStringList(
                                  'user-data', widget.savedItems);

                              print('Days Diff: ' +
                                  (new Duration(
                                          days: expirationDate
                                              .difference(DateTime.now())
                                              .inDays)
                                      .toString()));

                              var scheduledNotificationDateTime =
                                  new DateTime.now().add(new Duration(
                                      days: expirationDate
                                          .difference(DateTime.now())
                                          .inDays));
                              var androidPlatformChannelSpecifics =
                                  new AndroidNotificationDetails(
                                      'Eden-Push-Notifications',
                                      'Push Notifications',
                                      'Push Notifications about your Eden food items!',
                                      priority: Priority.High,
                                      channelAction:
                                          AndroidNotificationChannelAction
                                              .CreateIfNotExists);
                              NotificationDetails platformChannelSpecifics =
                                  new NotificationDetails(
                                      androidPlatformChannelSpecifics, null);
                              await widget.flutterLocalNotificationsPlugin
                                  .schedule(
                                      0,
                                      'Eden Test!',
                                      'Eden Test scheduled body',
                                      scheduledNotificationDateTime,
                                      platformChannelSpecifics);

                              Navigator.of(context).pop();
                            },
                            child: Text('Submit'),
                          ),
                        )
                      ],
                    )
                  ],
                ))
            : CircularProgressIndicator());
  }
}
