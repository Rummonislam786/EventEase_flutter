import 'package:calendar_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app/Models/users.dart';
import 'package:calendar_app/database/database_helper.dart';

import 'package:calendar_app/screens/signup.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SigninState();
}

class _SigninState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoginTrue = false;

  final username = TextEditingController();
  final password = TextEditingController();

  bool isVisible = true;

  final db = DatabaseHelper.instance;

  login() async {
    var response = await db.login(
        Users(username: username.text, email: "", password: password.text));
    if (response == true) {
      if (!mounted) {
        return;
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Image.asset(
                    "assets/calendar.png",
                    height: 100,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Text("Sign In",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                  SizedBox(height: constraints.maxHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: username,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "username is required";
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            label: Text(
                              "Username",
                              style: TextStyle(
                                  color: Color.fromARGB(122, 133, 133, 133),
                                  fontWeight: FontWeight.bold),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0 * 1.5, vertical: 16.0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          onSaved: (phone) {
                            // Save it
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextFormField(
                            controller: password,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "password is required";
                              }
                              return null;
                            },
                            style: const TextStyle(color: Colors.black),
                            obscureText: isVisible,
                            decoration: InputDecoration(
                              label: const Text(
                                "Password",
                                style: TextStyle(
                                    color: Color.fromARGB(122, 133, 133, 133),
                                    fontWeight: FontWeight.bold),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.black,
                              ),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isVisible = !isVisible;
                                    });
                                  },
                                  icon: Icon(
                                    isVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black,
                                  )),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0 * 1.5, vertical: 16.0),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                            ),
                            onSaved: (passaword) {
                              // Save it
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              login();
                              // Navigate to the main screen
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.orange,
                            foregroundColor: const Color(0xFF012924),
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Sign in"),
                        ),
                        const SizedBox(height: 16.0),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupScreen()));
                          },
                          child: Text.rich(
                            const TextSpan(
                              style: TextStyle(color: Colors.black),
                              text: "Don’t have an account? ",
                              children: [
                                TextSpan(
                                  text: "Sign Up!",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withOpacity(0.64),
                                ),
                          ),
                        ),
                        isLoginTrue
                            ? const Text(
                                "Username or Password is incorrect",
                                style: TextStyle(color: Colors.red),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


// class SignInScreen extends StatefulWidget {
  
