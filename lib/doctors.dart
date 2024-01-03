import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'signin.dart';
final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();
const String _baseURL = 'https://hassanramadan.000webhostapp.com';
const String _baseURL2 = 'hassanramadan.000webhostapp.com';

List<String> _Requests = ['No requests'];
List<String> _Requestids = [];

class Doctors extends StatefulWidget {
  const Doctors({super.key});

  @override
  State<Doctors> createState() => _DoctorsState();
}

class _DoctorsState extends State<Doctors> {
  bool _loaded = false;

  void update(bool success){
    setState(() {
      _loaded = success;
    });
  }
  void update2(String text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
  @override
  void initState() {
    getRequests(update);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor\'s Dashboard', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
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
      body: Visibility(visible: _loaded, child:  SizedBox(
        width: 300,
        height: 400,
        child:ListView.builder(
            itemCount: _Requests.length,

            itemBuilder: (context,index){
              return Column(
                children: [
                  Text(_Requests[index]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: (){
                            checkRequests(update2,_Requestids[index], 'accept');
                            getRequests(update);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor:  Colors.green),
                        child: const Text('accept', style: TextStyle(color: Colors.yellow),),
                      ),
                      const SizedBox(width: 20,),
                      ElevatedButton(
                        onPressed: (){
                          checkRequests(update2,_Requestids[index], 'deny');
                          getRequests(update);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor:  Colors.red),
                        child: const Text('deny', style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,)
                ],
              );
            }) ,
      )),
    );
  }
}
void getRequests(Function(bool success) update) async {
  try {
    String teacherID = await _encryptedData.getString('myKey');
    final response = await http
        .post(Uri.parse('$_baseURL/mobile/getRequests.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: convert
            .jsonEncode(<String, String>{'tid': teacherID}))
        .timeout(const Duration(seconds: 5));
    _Requests.clear();
    _Requestids.clear();
    if(response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      for (var row in jsonResponse) {
        _Requests
            .add(
            '''
            Student ID: ${row['studentID']}
            Name: ${row['name']}
${row['choice']}
            ''');
        _Requestids.add(row['requestID']);
      }
      update(true);
    }
  } catch (e) {
    update(false);
  }
}
void checkRequests(Function(String text) update2,String rid,String type) async {
  try {
    final response = await http
        .post(Uri.parse('$_baseURL/mobile/updateRequests.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: convert
            .jsonEncode(<String, String>{'rid': rid,'type':type}))
        .timeout(const Duration(seconds: 5));
    _Requests.clear();
    if(response.statusCode == 200) {
      update2(response.body);
      }
    }
   catch (e) {
    update2('error occurred');
  }
}
