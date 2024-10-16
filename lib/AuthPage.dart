import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker_app/HomePage.dart';
import 'package:task_tracker_app/data_manager.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); 

  @override
 @override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            Image.asset(
              'assets/icon/icon.png',  
              height: 100,        
            ),
            const SizedBox(height: 20), 
            Text(
              isLogin ? "Welcome to\nTask Tracker!" : "Sign Up",
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            Text(
              isLogin ? "Enter your credentials" : "Create your account",
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 40),
            isLogin ? _loginForm(context) : _signupForm(context),
            const SizedBox(height: 20),
            _toggleButton(context),
          ],
        ),
      ),
    ),
  );
}

  Widget _loginForm(BuildContext context) {
    return Form(
      key: _formKey, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField("Email", Icons.email, controller: _emailController, validate: true),
          const SizedBox(height: 12),
          _buildTextField("Password", Icons.lock, obscureText: true, controller: _passwordController, validate: true),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _login();
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              _showForgotPasswordDialog(context);
            },
            child: const Text(
              "Forgot password?",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signupForm(BuildContext context) {
    return Form(
      key: _formKey, // Wrap the form in a Form widget
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField("Username", Icons.person, controller: _usernameController, validate: true),
          const SizedBox(height: 12),
          _buildTextField("Email", Icons.email, controller: _emailController, validate: true),
          const SizedBox(height: 12),
          _buildTextField("Password", Icons.lock, obscureText: true, controller: _passwordController, validate: true),
          const SizedBox(height: 12),
          _buildTextField("Confirm Password", Icons.lock, obscureText: true, controller: _confirmPasswordController, validate: true),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _signup();
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              "Sign Up",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hintText, IconData icon, {bool obscureText = false, TextEditingController? controller, bool validate = false}) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.black54,
        filled: true,
        prefixIcon: Icon(icon, color: Colors.blue),
      ),
      validator: (value) {
        if (validate && (value == null || value.isEmpty)) {
          return '$hintText cannot be empty';
        }
        if (hintText == "Email" && value != null && !RegExp("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}").hasMatch(value)) {
          return 'Enter a valid email';
        }
        if (hintText == "Confirm Password" && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _toggleButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? "Don't have an account? " : "Already have an account? ",
          style: const TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: Text(
            isLogin ? "Sign Up" : "Login",
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  void _signup() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      String data = "[]";

      // Write to Firebase Realtime Database
      await _dbRef.child("users").child(uid).set({
        'username': username,
        'data': data,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid);

      _showDialog("Success", "Account created successfully");
    } catch (error) {
      _showDialog("Error", "Failed to create account");
    }
  }

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );

      String uid = userCredential.user!.uid;

      DatabaseEvent event = await _dbRef.child("users").child(uid).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var userData = snapshot.value as Map;
        String fetchedUsername = userData['username'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', uid);
        await prefs.setString('username', fetchedUsername);
        await DataManager.initializeData();
       // DataManager.startPeriodic();

        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
      } else {
        _showDialog("Error", "Invalid Credentials!");
      }
    } catch (error) {
      _showDialog("Error", "Invalid Credentials!");
    }
  }

  void _showDialog(String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          title,
          style: const TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.blue), 
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      );
    },
  );
}


  void _showForgotPasswordDialog(BuildContext context) {
  final TextEditingController _forgotEmailController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text(
        "Reset Password",
        style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: TextFormField(
        controller: _forgotEmailController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter your email",
          hintStyle: TextStyle(color: Colors.grey[500]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty || !RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
            return "Please enter a valid email";
          }
          return null;
        },
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
          onPressed: () {
            _resetPassword(_forgotEmailController.text);
            Navigator.of(context).pop();
          },
          child: const Text("Send", style: TextStyle(color: Colors.blue)),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
  );
}
 void _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showDialog("Success", "Password reset email sent. Check your inbox.");
    } catch (error) {
      _showDialog("Error", "Failed to send password reset email. Please try again.");
    }
  }
}
