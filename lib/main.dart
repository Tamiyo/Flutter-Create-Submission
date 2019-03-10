import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(M());

class M extends StatelessWidget {
  @override
  Widget build(context) {
    return MaterialApp(
      home: SplashScreen(
        seconds: 2,
        backgroundColor: Color.fromRGBO(255, 204, 102, 1),
        navigateAfterSeconds: H(),
        title: Text(
          '{ spectacle } ',
          style: TextStyle(
            fontSize: 48.0,
            fontFamily: 'AbrilFatface',
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        loadingText: Text(
          'discover excellence',
          style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18.0,
              fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class H extends StatefulWidget {
  /// TODO COLOR PALETTE https://coolors.co/56c450-454851-3454d1-ffffff-34d1bf
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

  ProgressHUD _progressHUD;

  bool _ready = false;
  bool _detected = true;

  Future getImage() async {
    final File image = await ImagePicker.pickImage(source: ImageSource.camera);

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
        );
      }));
    }

    setState(() {
      _ready = true;
    });
  }

  void _G() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
//    widget.savedItems = preferences.getStringList('user-data');

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
      appBar: AppBar(),
      backgroundColor: Color.fromRGBO(255, 204, 102, 1),
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
                          ? null
                          : Image.network(
                              widget.savedItems[4 * index + 2],
                            ).image,
                      child: _ready ? CircularProgressIndicator() : null,
                    ),
                    title: Text(widget.savedItems[4 * index + 1]),
                    subtitle:
                        Text(widget.savedItems[4 * index] + ' days left!'),
                    onTap: () {
                      /// TODO Implement onTap -> DetailsPage
//                    savedItems[4 * index + 2]
                    },
                    trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          widget.savedItems.removeRange(index, index + 4);
                          setState(() {});
                        }),
                  ),
                  color: Colors.white,
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(),
            ),
          ),
          _progressHUD
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: getImage,
        icon: Icon(Icons.camera),
        label: Text('Scan Barcode'),
      ),
    );
  }
}

class C extends StatefulWidget {
  C({this.upc, this.savedItems});

  String upc;
  List<String> savedItems;

  _C createState() => new _C(upc: upc);
}

class _C extends State<C> {
  _C({this.upc});

  String upc;
  DateTime expirationDate;
  Map<String, dynamic> data;

  bool _ready = false;

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

    print(response.body);
    data = json.decode(response.body);

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
      body: _ready ? Container(
        color: Color.fromRGBO(255, 255, 255, 1.0),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(data['items'][0]['title']),
            Divider(
              color: Colors.transparent,
            ),
            Image.network(
              data['items'][0]['images'][0],
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
                    data['items'][0]['lowest_recorded_price']),
                Text('UPC: ' + data['items'][0]['upc'])
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
                    onPressed: () {
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
                        ..add(data['items'][0]['images'][0])
                        ..add(upc);

                      Navigator.of(context).pop();
                    },
                    child: Text('Submit'),
                    color: Colors.amber,
                  ),
                )
              ],
            )
          ],
        )
      ) : CircularProgressIndicator()
    );
  }
}
