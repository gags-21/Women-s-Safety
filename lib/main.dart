import 'package:flutter/material.dart';
import 'package:sms_maintained/sms.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:call_number/call_number.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:call_number/call_number.dart';
import 'package:contacts_service/contacts_service.dart';

const apiKEY = 'AIzaSyCbLa4X4aR_Tmj-MJxwrlII4vavtJ7oxWs';

void main() => runApp(WomenSafety());

class WomenSafety extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade900,
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
    String address = '+918879527426';
    sender.sendSms(new SmsMessage(address, 'Please help I am at $address1'));
    String address2 = '+91123456789';
    sender.sendSms(new SmsMessage(address2, 'Please help I am at $address1'));
    String address3 = '+917208523020';
    sender.sendSms(new SmsMessage(address3, 'Please help I am at $address1'));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RawMaterialButton(
        onPressed: () async {
          setState(() {
            getNumber();
            getDetails();
            sendSms();
          });
        },
        onLongPress: () {},
        elevation: 2.0,
        fillColor: Colors.white,
        child: GestureDetector(
          child: Icon(
            Icons.ring_volume,
            size: 80.0,
          ),
        ),
        padding: EdgeInsets.all(15.0),
        shape: CircleBorder(),
      ),
    );
  }
}
