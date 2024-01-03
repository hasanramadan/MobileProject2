import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'signin.dart';

const String _baseURL = 'https://hassanramadan.000webhostapp.com';
const String _baseURL2 = 'hassanramadan.000webhostapp.com';

final EncryptedSharedPreferences _encryptedData =
EncryptedSharedPreferences();

List<String> _Drnames = ['Select Doctor'];
List<String> _officeHours = ['temp'];
List<String> _Requests = ['Empty'];

class Students extends StatefulWidget {
  const Students({super.key});

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  bool _loaded = false;
  bool _loaded2 = false;
  String doctor = '';
  void update(bool success){
    if(success){
      setState(() {
        doctor =_Drnames.first;
      });
    }
    setState(() {
      _loaded = success;
    });
  }
  void update2(bool success){
    setState(() {
      _loaded2 = success;
    });
  }
  void update3(String text){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
  @override
  void initState() {
    getRequestForStudent(update);
    drnames(update);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Hours', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(onPressed: (){
          _encryptedData.remove('myKey');
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SignIn())
          );
          }, icon: Icon(Icons.logout, color: Colors.white,))
        ],
      ),
      body: SingleChildScrollView(child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20,),
                DropdownMenu(
                  width: 200,
                  dropdownMenuEntries: _Drnames.map<DropdownMenuEntry<String>>((String name){
                    return DropdownMenuEntry(value: name, label: name);
                  }).toList(),
                  initialSelection: _Drnames.first,
                  onSelected: (String? name){
                    setState(() {
                      doctor = name as String;
                      officeHours(update2, doctor);
                    });
                  },
                ),

            const SizedBox(height: 30,),
            Visibility(visible: _loaded2, child:  SizedBox(
              width: 300,
              height: 400,
              child:ListView.builder(
                  itemCount: _officeHours.length,

                  itemBuilder: (context,index){
                    return Column(
                      children: [
                        Text(_officeHours[index],style: TextStyle(fontWeight: FontWeight.bold),),
                        Center(
                          child: ElevatedButton(
                            onPressed: (){
                                Request(update3, _officeHours[index], doctor);
                                getRequestForStudent(update);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor:  Colors.blue[900]),
                            child: const Text('request', style: TextStyle(color: Colors.yellow),),
                          ),
                        ),
                        const SizedBox(height: 20,)
                      ],
                    );
                  }) ,
            )),
            SizedBox(
              width: 300,
              height: 400,
              child:ListView.builder(
                  itemCount: _Requests.length,

                  itemBuilder: (context,index){
                    return Column(
                      children: [
                        Text(_Requests[index],style: TextStyle(fontWeight: FontWeight.bold),),
                        const SizedBox(height: 20,)
                      ],
                    );
                  }) ,
            )
          ],
        ),
      )

    ));
  }
}
void drnames(Function(bool success) update) async {
  try {
    final url = Uri.https(_baseURL2,'mobile/getDr.php');
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    _Drnames.clear();
    _Drnames.add('Select Doctor');

    if(response.statusCode == 200){
      final jsonResponse = convert.jsonDecode(response.body);
      for(var row in jsonResponse){
        _Drnames.add(row['name']);
      }
      update(true);
    }
  } catch (e) {
    update(false);
  }
}
void officeHours(Function(bool success) update2,String drname) async {
  try {
    final response = await http
        .post(Uri.parse('$_baseURL/mobile/getOH.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: convert
            .jsonEncode(<String, String>{'name': drname}))
        .timeout(const Duration(seconds: 5));
    _officeHours.clear();
    if(response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      for (var row in jsonResponse) {
        _officeHours
            .add(
            '''
            Day: ${row['Day']}
            Hours: ${row['hours']}
            Room: ${row['room']}
            ''');
      }
      update2(true);
    }
  } catch (e) {
    update2(false);
  }
}

void Request(Function(String text) update3,String choice,String drname) async {
  try {
    String studentID = await _encryptedData.getString('myKey');
    final response = await http
        .post(Uri.parse('$_baseURL/mobile/request.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: convert
            .jsonEncode(<String, String>{'choice': choice,'name':drname,'sid': studentID}))
        .timeout(const Duration(seconds: 5));
    if(response.statusCode == 200) {
      update3(response.body);
    }
  } catch (e) {
    update3('request failed');
  }
}
void getRequestForStudent(Function(bool success) update) async {
  try {
    String studentID = await _encryptedData.getString('myKey');
    final response = await http
        .post(Uri.parse('$_baseURL/mobile/getRequestForStudent.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: convert
            .jsonEncode(<String, String>{'sid': studentID}))
        .timeout(const Duration(seconds: 5));
    _Requests.clear();
    if(response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      for (var row in jsonResponse) {
        _Requests
            .add(
            '''
            Status: ${row['isconfirmed']}
${row['choice']}
            ''');
      }
      update(true);
    }
  } catch (e) {
    update(false);
  }
}




