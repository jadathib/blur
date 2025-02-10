import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> _signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
    await _auth.signInWithCredential(credential);
  }

  Future<void> _signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName]);
    final OAuthCredential appleCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
    );
    await _auth.signInWithCredential(appleCredential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _signInWithGoogle, child: Text("Sign in with Google")),
            ElevatedButton(onPressed: _signInWithFacebook, child: Text("Sign in with Facebook")),
            ElevatedButton(onPressed: _signInWithApple, child: Text("Sign in with Apple")),
          ],
        ),
      ),
    );
  }
}
