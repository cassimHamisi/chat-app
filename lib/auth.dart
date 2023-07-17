import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    // : implement createState
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoggingIn = true;

  // initialize the firebase authentication sdk
  final _firebase = FirebaseAuth.instance;

  //form values
  final TextEditingController _enteredEmail = TextEditingController();
  final TextEditingController _enteredPassword = TextEditingController();

  // connect our form in order for us to trigger it
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _enteredEmail.dispose();
    _enteredPassword.dispose();
    super.dispose();
  }

  // Submit function handler
  void _submit() async {
    // code when the form is submitted

    // trigger our form validators
    final formIsValid = _form.currentState!.validate();

    if (!formIsValid) return;

    _form.currentState!.save();

    // check the screen that we are in
    try {
      if (_isLoggingIn) {
        // in the login screen
        _firebase.signInWithEmailAndPassword(
            email: _enteredEmail.value.text,
            password: _enteredEmail.value.text);
        print('we are done here');
      } else {
        // in the sign up screen
        await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail.value.text,
          password: _enteredPassword.value.text,
        );
        _enteredEmail.clear();
        _enteredPassword.clear();

        print(_firebase.currentUser?.uid);
      }
    } on FirebaseAuthException catch (e) {
      var message = e.message;
      if (e.code == 'weak-password') {
        message = ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        message = ('The account already exists for that email.');
      }
      // error in sending signup credentia
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Authentication Failed!'),
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    // : implement build
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  bottom: 20,
                  top: 30,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLoggingIn) const UserImagePicker(),
                          TextFormField(
                            controller: _enteredEmail,
                            decoration:
                                const InputDecoration(labelText: 'E-Mail'),
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            autocorrect: false,
                            validator: (value) {
                              // validate email
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _enteredPassword,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              // validate email
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ElevatedButton(
                            onPressed: _submit, //submit the form
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(_isLoggingIn ? 'login' : 'Signup'),
                          ),
                          TextButton(
                            onPressed: () {
                              //toggle between create account and login
                              setState(() {
                                _isLoggingIn = !_isLoggingIn;
                              });
                            },
                            child: Text(_isLoggingIn
                                ? 'Create an account.'
                                : 'Already have an account? Login.'),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
