import 'package:auth/AuthScreen/RegistrationScreen.dart';
import 'package:auth/AuthScreen/homeScreen.dart';
import 'package:auth/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthClass auth = AuthClass();
  void signInWithEmailPassword() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await auth.signInEmail(_email.text, _password.text, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _email,
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return "Please enter fill the required field";
                        }
                        // if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value!)) {
                        //   return "Please enter a valid email address";
                        // }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Email',
                      ),
                    ),
                    TextFormField(
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Please enter fill the required field";
                        }
                        return null;
                      },
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Password'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        signInWithEmailPassword();
                      },
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Already have an account?'),
                        const SizedBox(
                          width: 3,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const SignUp()),
                                (Route<dynamic> route) => false);
                          },
                          child: const Text(
                            'SignUp Here',
                            style: TextStyle(
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
