import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const String _baseURL = 'https://hassanramadan.000webhostapp.com';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _id = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loaded = false;

  void update(String success){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
    setState(() {
      _loaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIU REGISTER', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 100,),
                SizedBox(width: 300,
                child: TextFormField(
                  controller: _id,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your id',
                  ),
                  validator: (String? value){
                    if(value == null || value.isEmpty){
                      return 'Please enter id';
                    }else if(value.length !=8){
                      return 'Please enter a valid id';
                    }else {
                      return null;
                    }
                  },
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(width: 300,
                  child: TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your name',
                    ),
                    validator: (String? value){
                      if(value == null || value.isEmpty){
                        return 'Please enter name';
                      }else {
                        return null;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(width: 300,
                  child: TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your email',
                    ),
                    validator: (String? value){
                      if(value == null || value.isEmpty){
                        return 'Please enter email';
                      }else {
                        return null;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(width: 300,
                  child: TextFormField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your password',
                    ),
                    validator: (String? value){
                      if(value == null || value.isEmpty){
                        return 'Please enter password';
                      }else if(value.length <8){
                        return 'Please enter a longer password';
                      }else {
                        return null;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loaded = true;
                        });
                      registerStudent(update, _id.text, _name.text, _email.text, _password.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
                    child: const Text(
                      'SignUp',
                      style: TextStyle(fontSize: 24, color: Colors.yellow),
                    )),
                Visibility(visible: _loaded, child: const CircularProgressIndicator(),)
              ],
            ),
          ),
        ),
      )
    );
  }
}
void registerStudent(Function(String success) update,String id, String name,String email, String password) async{
  try{
    final response = await http.post(
        Uri.parse('$_baseURL/mobile/registration.php'),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'id': id,
          'name': name,
          'email': email,
          'pass': password
        }))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      update(response.body);
    }
  }catch(e){
    update('connection error');
  }
}