import 'dart:async';
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

var cg = Colors.green;

class M extends StatelessWidget {
  @override
  Widget build(x) {
    return MaterialApp(
      home: SS(),
      theme: ThemeData(
        primaryColor: cg,
        accentColor: cg,
      ),
    );
  }
}

class SS extends StatefulWidget {
  _SS createState() => _SS();
}

class _SS extends State {
  startCountdown() async {
    var _d = Duration(seconds: 3);
    return Timer(_d, () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
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
  Widget build(x) {
    return Scaffold(
      body: Stack(
        children: [
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

List<dynamic> s = [];

final FlutterLocalNotificationsPlugin f = FlutterLocalNotificationsPlugin();

final BarcodeDetector b = FirebaseVision.instance.barcodeDetector();

SharedPreferences p;

void si() {
  p.setString('u', json.encode('{ \"items\": ' + s.toString() + "}"));
}

var tr = 'http://www.pngmart.com/files/5/Snow-PNG-Transparent-Image.png';

class H extends StatefulWidget {
  @override
  _H createState() => _H();
}

class _H extends State {
  ProgressHUD _progressHUD;

  bool _r = false;
  var ctx;
  var u;

  Future<String> _convertTouA(String uE) async {
    String manufacturerType = uE[6];
    String uA = "0";

    switch (manufacturerType) {
      case "0":
      case "1":
      case "2":
        uA += uE[1] + uE[2] + uE[6] + '0000' + uE.substring(3, 6) + uE[7];
        break;
      case "3":
        uA += uE.substring(1, 4) + '00000' + uE.substring(4, 6) + uE[7];
        break;
      case "4":
        uA += uE.substring(1, 5) + '00000' + uE[5] + uE[7];
        break;
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
        uA += uE.substring(1, 6) + '0000' + uE[6] + uE[7];
    }

    return uA;
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _progressHUD.state.show();
    });

    var ba = image != null
        ? await b.detectInImage(FirebaseVisionImage.fromFile(image))
        : [];

    u = ba.isEmpty ? null : ba[0].rawValue;

    setState(() {
      _progressHUD.state.dismiss();
    });

    if (u != null) {
      if (u.length < 12) {
        u = await _convertTouA(u);
        print("Converted uA: " + u);
      }

      var r = await http.get(
          'https://api.upcitemdb.com/prod/trial/lookup?upc=' + u,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          });

      var d = json.decode(r.body);

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (x) => C(d: d)))
          .then((d) {
        setState(() {});
      });
    } else {
      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: Text('Failed barcode scan, try again!'),
      ));
    }
  }

  void _G() async {
    p = await SharedPreferences.getInstance();

    f.initialize(InitializationSettings(
        AndroidInitializationSettings('@mipmap/my_launcher'), null));

    s = (p.getString('u') != null
        ? json.decode(p.getString('u'))
        : [
            {
              'fr': '3',
              'n': 'Granny Smith Apple',
              'iU':
                  'https://images-na.ssl-images-amazon.com/images/I/81N4hYrr%2BxL._SY355_.jpg',
              'sD': '2019-03-10 00:00:00.000',
              'eD': '2019-03-14 00:00:00.000',
              'p': 0.0,
            },
            {
              'fr': '7',
              'n': 'Broccoli',
              'iU':
                  'https://www.producemarketguide.com/sites/default/files/Commodities.tar/Commodities/broccoli_commodity-page.png',
              'sD': '2019-03-10 00:00:00.000',
              'eD': '2019-03-18 00:00:00.000',
              'p': 0.0,
            },
            {
              'fr': '2',
              'n': 'Pineapple',
              'iU':
                  'https://images-na.ssl-images-amazon.com/images/I/71%2BqAJehpkL._SY355_.jpg',
              'sD': '2019-03-10 00:00:00.000',
              'eD': '2019-03-13 00:00:00.000',
              'p': 0.0,
            },
          ]);

    for (var le in s) {
      var e = DateTime.parse(le['eD']);
      le['dl'] = e.difference(DateTime.now()).inDays;
      le['p'] = le['dl'] / e.difference(DateTime.parse(le['sD'])).inDays;
    }

    s.sort((a, b) => a['p'].compareTo(b['p']));

    setState(() {
      _r = true;
    });
  }

  @override
  void initState() {
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.black12,
      loading: false,
      color: Colors.white,
      containerColor: cg,
      borderRadius: 5.0,
      text: 'Processing...',
    );

    _G();
    super.initState();
  }

  @override
  Widget build(x) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Pantry'),
          centerTitle: true,
        ),
        body: Builder(builder: (x) {
          ctx = x;
          return _r
              ? Stack(
                  children: [
                    ListView.separated(
                      itemCount: s.length,
                      padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                      itemBuilder: (x, i) {
                        var e = s[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                _r ? Image.network(e['iU']).image : tr,
                            child: _r ? null : CircularProgressIndicator(),
                          ),
                          title: Text(e['n'], maxLines: 2),
                          subtitle: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('0'),
                                  LinearPercentIndicator(
                                    width: MediaQuery.of(x).size.width / 2,
                                    percent: e['p'],
                                    progressColor: e['p'] > .5
                                        ? cg
                                        : e['p'] > .2
                                            ? Colors.amber
                                            : Colors.red,
                                    backgroundColor: e['p'] > 0
                                        ? Color(0xFFD3D3D3)
                                        : Colors.red,
                                  ),
                                  Text(e['fr'])
                                ],
                              ),
                              Text('Expires in ${e['dl']} day(s)')
                            ],
                          ),
                          trailing: IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () {
                                showDialog(
                                    context: x,
                                    builder: (x) {
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
                                                  text: '${e['n']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text: ' from your items?')
                                            ])),
                                        actions: [
                                          MaterialButton(
                                            textColor: Colors.red,
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.pop(x);
                                            },
                                          ),
                                          MaterialButton(
                                            textColor: cg,
                                            child: Text('Remove'),
                                            onPressed: () async {
                                              await f.cancel(e['n'].hashCode);
                                              s.removeAt(i);
                                              Navigator.pop(x);
                                            },
                                          ),
                                        ],
                                      );
                                    }).then((d) {
                                  setState(() {});
                                });
                              }),
                        );
                      },
                      separatorBuilder: (x, i) => Divider(
                            color: Colors.transparent,
                            height: 24.0,
                          ),
                    ),
                    _progressHUD,
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: getImage,
          child: Icon(Icons.add_a_photo),
        ));
  }
}

class C extends StatefulWidget {
  C({this.d});

  var d;

  _C createState() => _C(da: d);
}

class _C extends State {
  _C({
    this.da,
  });

  var da;
  var n;
  var image;

  var eD;

  @override
  Widget build(x) {
    print(da);
    var d = da['items'][0];

    image = Image.network(d['images'].isEmpty ? tr : d['images'][0]);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF454851)),
      ),
      body: Stack(
        children: <Widget>[
          FlareActor(
            'assets/stopwatch.flr',
            alignment: Alignment.center,
            fit: BoxFit.contain,
            animation: 'tick',
          ),
          Align(
            alignment: Alignment(0, 0.8),
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: DateTimePickerFormField(
                        inputType: InputType.date,
                        format: DateFormat('yyyy-MM-dd'),
                        editable: false,
                        decoration: InputDecoration(
                          labelText: 'Expiration Date',
                          prefixIcon: Icon(Icons.date_range),
                        ),
                        onChanged: (D) {
                          eD = D;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: MaterialButton(
                        child: Text('Submit'),
                        onPressed: () async {
                          var dt = DateTime.now();
                          int fr = eD.difference(dt).inDays;

                          s.add({
                            'fr': fr > 0 ? fr.toString() : 1,
                            'dl': fr > 0 ? fr.toString() : 1,
                            'n': d['title'],
                            'iU': d['images'].length > 0 ? d['images'][0] : tr,
                            'sD': dt,
                            'p': 1.0,
                            'eD': eD
                          });

                          si();

                          await f.schedule(
                              d['title'].hashCode,
                              'Spoil Alert!',
                              '${d['title']} is going to spoil! Check up on it!',
                              dt.add(Duration(days: fr)),
                              NotificationDetails(
                                  AndroidNotificationDetails(
                                      'epn',
                                      'Push Notifications',
                                      'Push Notifications about your Eden food items!',
                                      priority: Priority.High,
                                      channelAction:
                                          AndroidNotificationChannelAction
                                              .CreateIfNotExists),
                                  null));
                          Navigator.of(x).pop();
                        },
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
