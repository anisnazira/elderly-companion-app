import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'role_selection.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final TextEditingController usernameController =
      TextEditingController(text: kDebugMode ? 'anisnaziraa78@gmail.com' : '');
  final TextEditingController passwordController =
      TextEditingController(text: kDebugMode ? '100394an' : '');

  void signUserIn(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.05),

                    // Smaller logo
                    Image.asset(
                      'assets/buddi-logo.png',
                      width: size.width * 0.35,
                      height: size.width * 0.35,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Welcome text
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: size.width * 0.04,
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // Username field
                    MyTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false,
                    ),

                    SizedBox(height: size.height * 0.015),

                    // Password field
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    SizedBox(height: size.height * 0.015),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600], fontSize: size.width * 0.035),
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // Smaller sign in button
                    MyButton(
                      height: size.height * 0.06,
                      fontSize: size.width * 0.04,
                      onTap: () => signUserIn(context),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Divider with "or continue with"
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[400], thickness: 0.5)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.grey[700], fontSize: size.width * 0.035),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[400], thickness: 0.5)),
                      ],
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Social buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final user = await signInWithGoogle();
                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
                              );
                            }
                          },
                          child: SquareTile(imagePath: 'assets/google.png', size: 50),
                        ),
                        SizedBox(width: size.width * 0.05),
                        SquareTile(imagePath: 'assets/apple.png', size: 50),
                      ],
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Register prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Not a member?',
                          style: TextStyle(color: Colors.grey[700], fontSize: size.width * 0.035),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Register now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- CUSTOM WIDGETS --------------------

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final double? height;
  final double? fontSize;

  const MyButton({super.key, required this.onTap, this.height, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: Color(0xFF345EE9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            "Sign In",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize ?? 16,
            ),
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
        ),
      ),
    );
  }
}

class SquareTile extends StatelessWidget {
  final String imagePath;
  final double? size;

  const SquareTile({super.key, required this.imagePath, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: Image.asset(
        imagePath,
        height: size ?? 40,
        width: size ?? 40,
      ),
    );
  }
}
