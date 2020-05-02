import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sms_maintained/sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:call_number/call_number.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const apiKEY = 'AIzaSyCbLa4X4aR_Tmj-MJxwrlII4vavtJ7oxWs';

void main() => runApp(WomenSafety());

class WomenSafety extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: SafetyPage(),
          ),
        ),
      ),
    );
  }
}

class SafetyPage extends StatefulWidget {
  @override
  _SafetyPageState createState() => _SafetyPageState();
}

class _SafetyPageState extends State<SafetyPage> {
  double latitude;
  double longitude;
  String placeID = '';
  String policePhone;
  String location;
  String placeIDforNumber;
  final myController = TextEditingController();
  final myController1 = TextEditingController();
  final myController2 = TextEditingController();

  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
    getLocation();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
    getStringValuesSF();
  }

  dynamic getLocation() async {
    latitude = null;
    longitude = null;
    Geolocator()..forceAndroidLocationManager;
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);
    latitude = position.latitude;
    longitude = position.longitude;
    location = ('${latitude.toString()},${longitude.toString()}');
    return location;
  }

  Future getDetails() async {
    try {
      while (placeID == '') {
        http.Response response = await http.get(
            'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=2000&type=police&key=$apiKEY');
        var decodedData = jsonDecode(response.body);
        placeID = decodedData['results'][0]['place_id'];
        placeIDforNumber = placeID;
        print(placeID);
      }
      placeID = '';
    } catch (e) {
      print(e);
    }
  }

  Future getNumber() async {
    if (placeID != null) {
      http.Response response = await http.get(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeIDforNumber&fields=formatted_phone_number&key=$apiKEY');
      var decodedData = jsonDecode(response.body);
      policePhone = decodedData['result']['formatted_phone_number'];
      await new CallNumber().callNumber('+91' + policePhone);
      getDetails();
    }
  }

  void sendSms() async {
    List<Placemark> newPlace =
        await Geolocator().placemarkFromCoordinates(latitude, longitude);
    // List<Placemark>  = await geolocator.placemarkFromCoordinates(_position.latitude, _position.longitude);

    // this is all you need
    Placemark placeMark = newPlace[0];
    String name = placeMark.name;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;
    String address1 =
        "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

    print(address1);

    SmsSender sender = SmsSender();

    if (ph1 == '') {
      String address = '+91$phone1';
      sender.sendSms(new SmsMessage(address, 'Please help I am at $address1'));
      String address2 = '+91$phone2';
      sender.sendSms(new SmsMessage(address2, 'Please help I am at $address1'));
      String address3 = '+91$phone3';
      sender.sendSms(new SmsMessage(address3, 'Please help I am at $address1'));
    } else {
      String address = '+91$ph1';
      sender.sendSms(new SmsMessage(address, 'Please help I am at $address1'));
      String address2 = '+91$ph2';
      sender.sendSms(new SmsMessage(address2, 'Please help I am at $address1'));
      String address3 = '+91$ph3';
      sender.sendSms(new SmsMessage(address3, 'Please help I am at $address1'));
    }
  }

  String ph1 = '';
  String ph2 = '';
  String ph3 = '';
  String phone1;
  String phone2;
  String phone3;

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    phone1 = prefs.getString('ph1');
    phone2 = prefs.getString('ph2');
    phone3 = prefs.getString('ph3');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 15,
        ),
        Container(
          width: 200,
          height: 30,
          child: TextField(
            style: TextStyle(
              color: Colors.white,
            ),
            onEditingComplete: () {},
            controller: myController,
            keyboardType: TextInputType.numberWithOptions(),
            decoration: InputDecoration(
              hintText: 'Ph. no.',
              hintStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        FlatButton(
          shape: CircleBorder(),
          color: Colors.teal[700],
          child: Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            ph1 = myController.text;
            prefs.setString('ph1', "$ph1");
            print(ph1);
          },
        ),
        Container(
          width: 200,
          height: 30,
          child: TextField(
            controller: myController1,
            style: TextStyle(
              color: Colors.white,
            ),
            keyboardType: TextInputType.numberWithOptions(),
            decoration: InputDecoration(
              hintText: 'Ph. no.',
              hintStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        FlatButton(
          shape: CircleBorder(),
          color: Colors.teal[700],
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            ph2 = myController1.text;
            prefs.setString('ph2', "$ph2");
            print(ph2);
          },
        ),
        Container(
          width: 200,
          height: 30,
          child: TextField(
            style: TextStyle(
              color: Colors.white,
            ),
            controller: myController2,
            keyboardType: TextInputType.numberWithOptions(),
            decoration: InputDecoration(
              hintText: 'Ph. no.',
              hintStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        FlatButton(
          color: Colors.teal[700],
          shape: CircleBorder(),
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            ph3 = myController2.text;
            prefs.setString('ph3', "$ph3");
            print(ph3);
          },
        ),
        SizedBox(
          height: 50,
        ),
        Center(
          child: RawMaterialButton(
            onPressed: () async {
              setState(() {
                sendSms();
                getDetails();
              });
            },
            onLongPress: () {
              setState(() {
                getNumber();
              });
            },

            elevation: 2.0,
            fillColor: Colors.white,
//                    child: GestureDetector(
            child: Icon(
              Icons.ring_volume,
              size: 80.0,
            ),
//                    ),
            padding: EdgeInsets.all(15.0),
            shape: CircleBorder(),
          ),
        ),
      ],
    );
  }
}



