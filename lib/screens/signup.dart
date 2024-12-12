import 'package:flutter/material.dart';
import 'package:calendar_app/Models/users.dart';
import 'package:calendar_app/database/database_helper.dart';
import 'package:calendar_app/screens/signin.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final username = TextEditingController();
  final password = TextEditingController();
  final confPassword = TextEditingController();
  final email = TextEditingController();

  bool isVisible = true;
  bool isconfVisible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: constraints.maxHeight * 0.08),
                Image.asset(
                  "assets/calendar.png",
                  height: 100,
                ),
                SizedBox(height: constraints.maxHeight * 0.08),
                Text(
                  "Sign Up",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: constraints.maxHeight * 0.05),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: username,
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "username is required";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          label: Text(
                            "Username",
                            style: TextStyle(
                                color: Color.fromARGB(122, 133, 133, 133),
                                fontWeight: FontWeight.bold),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0 * 1.5, vertical: 16.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                        onSaved: (name) {
                          // Save it
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Email Address is required";
                          }
                          return null;
                        },
                        controller: email,
                        decoration: const InputDecoration(
                          filled: true,
                          label: Text(
                            "Email",
                            style: TextStyle(
                                color: Color.fromARGB(122, 133, 133, 133),
                                fontWeight: FontWeight.bold),
                          ),
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0 * 1.5, vertical: 16.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (em) {
                          // Save it
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        controller: password,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "password is required";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text(
                            "Password",
                            style: TextStyle(
                                color: Color.fromARGB(122, 133, 133, 133),
                                fontWeight: FontWeight.bold),
                          ),
                          filled: true,
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
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0 * 1.5, vertical: 16.0),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                        obscureText: isVisible,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: confPassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Confirm password is required";
                            } else if (value != password.text) {
                              return "Confirm password should be same";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text(
                              "Confirm Password",
                              style: TextStyle(
                                  color: Color.fromARGB(122, 133, 133, 133),
                                  fontWeight: FontWeight.bold),
                            ),
                            filled: true,
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isconfVisible = !isconfVisible;
                                  });
                                },
                                icon: Icon(
                                  isconfVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.black,
                                )),
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0 * 1.5, vertical: 16.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                          obscureText: isconfVisible,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final db = DatabaseHelper.instance;

                              db
                                  .signup(Users(
                                      username: username.text,
                                      email: email.text,
                                      password: password.text))
                                  .whenComplete(() {
                                Navigator.push(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignInScreen()));
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Sign Up"),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()));
                        },
                        child: Text.rich(
                          const TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Sign in",
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(0.64),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
