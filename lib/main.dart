import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:http/http.dart' as http;

final xbox =  IconData(0xe800, fontFamily: 'Xbox');
final ps =  IconData(0xe801, fontFamily: 'Playstation');

final platforms = {
  5: 'PC',
  2: 'PS4',
  1: 'XBOX'
};

void main() => runApp(MaterialApp(
      home: Scaffold(
        body: H(),
      ),
    ));

class H extends StatefulWidget {
  _H createState() => new _H();
}

class _H extends State<H> {
  final TextEditingController _controller = new TextEditingController();

  int platform = 5;

  ProgressHUD _progressHUD;

  Future<void> _getPlayerStats(
      String playerName, int platform, BuildContext context) async {

    FocusScope.of(context).requestFocus(new FocusNode());
    print('Gathering datat for $playerName');

    final response = await http.get(
        'https://public-api.tracker.gg/apex/v1/standard/profile/$platform/$playerName',
        headers: {'TRN-Api-Key': '3ac4362a-8357-4855-89aa-c3c7444382ca'}).timeout(const Duration(seconds: 10));

    final body = json.decode(response.body);
    print(body);

    if(body.keys.contains('errors') || body['data']['children'].length == 0) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Couldn\'t Find Stats for $playerName on ${platforms[platform]}' ),));
    } else {
      Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
        return PlayerDetails(
          json: body,
        );
      }));
    }

  }

  @override
  void initState() {
    _progressHUD = new ProgressHUD(
      color: Colors.white,
      loading: false,
      containerColor: Color(0xFFbd3d3d),
      borderRadius: 5.0,
      text: 'Loading...',
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: Image.asset('assets/background.png').image,
                  fit: BoxFit.cover)),
          padding: EdgeInsets.all(12.0),
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Parallelogram(
                cutLength: 15.0,
                child: Container(
                  color: Colors.white,
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 24.0, right: 8.0),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                  value: platform,
                                  items: [
                                    DropdownMenuItem<int>(
                                      child: Icon(Icons.desktop_windows),
                                      value: 5,
                                    ),
                                    DropdownMenuItem(
                                      child: Icon(xbox),
                                      value: 1,
                                    ),
                                    DropdownMenuItem(
                                      child: Icon(ps),
                                      value: 2,
                                    )
                                  ],
                                  onChanged: (p) {
                                    setState(() {
                                      platform = p;
                                    });
                                  })),
                        ),
                        suffixIcon: Parallelogram(
                            cutLength: 15.0,
                            child: MaterialButton(
                              onPressed: () async {

                                setState(() {
                                  _progressHUD.state.show();
                                });

                                await _getPlayerStats(_controller.text, platform, context);
                                setState(() {
                                  _progressHUD.state.dismiss();
                                });
                              },
                              color: Colors.amber,
                              child: Text(
                                'Search',
                                style: TextStyle(fontSize: 14.0),
                              ),
                            )),
                        contentPadding: EdgeInsets.only(left: 24.0, top: 16.0),
                        hintText: 'Player Name',
                        hintStyle: TextStyle(fontSize: 14.0)),
                  ),
                )),
          ),
        ),
        _progressHUD
      ],
    );
  }
}

class PlayerDetails extends StatefulWidget {
  PlayerDetails({this.json});

  final json;

  _PlayerDetailsState createState() => new _PlayerDetailsState(json: json);
}

class _PlayerDetailsState extends State<PlayerDetails> {
  _PlayerDetailsState({this.json});

  final Map<String, dynamic> json;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> champion = {};

    for (Map<String, dynamic> hero in json['data']['children']) {
      print(hero.toString());
      if (hero['metadata']['legend_name'] != 'Unknown') {
        champion = hero;
        print('Champion: ${champion.toString()}');
        break;
      }
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: MediaQuery.of(context).size.width /
                MediaQuery.of(context).size.height,
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Image.network(
                      champion['metadata']['bgimage'],
                      fit: BoxFit.cover,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Transform(
                        transform: Matrix4.translationValues(0.0, 30.0, 0.0),
                        child: Column(
                          children: <Widget>[
                            Image.network(
                              champion['metadata']['icon'],
                              scale: 3.0,
                              fit: BoxFit.cover,
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  json['data']['metadata']
                                      ['platformUserHandle'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 48.0),
                                ),
                                Text(
                                  '${champion['metadata']['legend_name']} Main',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.0),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.transparent,
                  height: 48.0,
                ),
                Column(
                    children: json['data']['stats']
                        .map<Widget>(
                          (d) => Container(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      '${d['metadata']['name']}:',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      d['displayValue'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        )
                        .toList()),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 8.0, top: 32.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFFbd3d3d),
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
