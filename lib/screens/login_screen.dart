import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _authEventsSub;

  @override
  void initState() {
    super.initState();
    // 1) Initialize Google Sign-In (required in v7)
    unawaited(GoogleSignIn.instance
        .initialize(
      // Use your iOS/macOS OAuth client ID:
      clientId: 'YOUR_IOS_OR_MACOS_CLIENT_ID.apps.googleusercontent.com',
      // If you exchange server auth codes on your backend, also set:
      // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    )
        .then((_) {
      // Optional: try lightweight auth on app start.
      GoogleSignIn.instance.attemptLightweightAuthentication();
    }));

    // (Optional) Listen for auth events to update UI
    _authEventsSub = GoogleSignIn.instance.authenticationEvents.listen((_) {});
  }

  @override
  void dispose() {
    _authEventsSub?.cancel();
    super.dispose();
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // 2) Trigger interactive sign-in (v7)
      final account = await GoogleSignIn.instance.authenticate();

      // 3) Get the idToken (v7 exposes only idToken)
      final idToken = (await account.authentication).idToken;
      if (idToken == null) {
        throw Exception('No idToken from Google Sign-In');
      }

      // 4) Sign in to Firebase with idToken
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _auth.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on GoogleSignInException catch (e) {
      debugPrint('GoogleSignInException: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      // Trigger Facebook login
      final LoginResult result = await FacebookAuth.instance.login();

      // Check if the login was successful
      if (result.status == LoginStatus.success && result.accessToken != null) {
        // Create Facebook OAuth credential
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        // Sign in using the generated credential
        await _auth.signInWithCredential(credential);

        // Navigate to HomeScreen if the user is signed in and context is mounted
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // Handle cases where login was not successful
        print("Facebook login failed: ${result.status}");
      }
    } catch (e) {
      // Catch and log any exceptions during the login process
      print("Facebook Sign-In Error: $e");
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential appleCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
      );

      await _auth.signInWithCredential(appleCredential);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      print("Apple Sign-In Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _signInWithGoogle(context),
              child: const Text("Sign in with Google"),
            ),
            ElevatedButton(
              onPressed: () => _signInWithFacebook(context),
              child: const Text("Sign in with Facebook"),
            ),
            ElevatedButton(
              onPressed: () => _signInWithApple(context),
              child: const Text("Sign in with Apple"),
            ),
          ],
        ),
      ),
    );
  }
}

extension on GoogleSignInException {
  get message => null;
}
