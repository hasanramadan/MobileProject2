import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'doctors.dart';
import 'students.dart';
import 'register.dart';

const String _baseURL = 'https://hassanramadan.000webhostapp.com';
final EncryptedSharedPreferences _encryptedData =
EncryptedSharedPreferences();
class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _id = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loaded = false;

  @override
  void dispose(){
    _id.dispose();
    _password.dispose();
    super.dispose();
  }
  void update(String success){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
    checkifLogged();
    setState(() {
      _loaded = false;
    });
  }
  void checkifLogged() async {
   String id = await _encryptedData.getString('myKey');
    if(id != ''){
      if(id == '11111111' || id == '22222222' || id == '33333333' || id == '44444444'){
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Doctors()));

      }else{
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Students()));
      }
    }
  }
  
  void initState(){
    super.initState();
    checkifLogged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LIU SignIn',
          style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context)=> Register())
            );
          }, icon: const Icon(Icons.app_registration_sharp, color: Colors.yellow,))
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _id,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your id',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter id';
                      }else {
                        return null;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your password',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }else {
                        return null;
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loaded = true;
                        });
                        lookUser(update, _id.text, _password.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor:  Colors.blue[900]),
                    child:  const Text(
                      'SignIn',
                      style: TextStyle(fontSize: 24, color:Colors.yellow),
                    )),
                const SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: _loaded,
                  child: const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
void lookUser(Function(String update) update, String id, String password) async {
  try {
    final response = await http
        .post(Uri.parse('$_baseURL/mobile/signin.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: convert
            .jsonEncode(<String, String>{'id': id, 'pass': password}))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      var row = jsonResponse[0];
      String id = row['id'];
      _encryptedData.setString('myKey', id);
      update('success');
    }
  } catch (e) {
    update('login failed');
  }
}
