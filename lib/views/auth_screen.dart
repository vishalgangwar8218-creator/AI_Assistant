import 'package:ai_chat_assistant/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class AuthScreen extends StatefulWidget{
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignUp = false;
  bool isLoading = false;
  String errorMessage = "";

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if(email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty)) {
      setState(() {
        errorMessage = "Please fill in all fields.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    if (isSignUp) {
      var response = await _apiService.signUp(name, email, password);
      setState(() => isLoading = false);

      if(response != null) {
        Provider.of<AuthViewmodel>(context, listen: false).login(
          response['email'],
          response['name'],
        );
      } else {
        setState(() {
          errorMessage = "Signup failed! Email might already be registered.";
        });
      }
    } else {
      var response = await _apiService.signIn(email, password);
      setState(() => isLoading = false);

      if (response != null) {
        Provider.of<AuthViewmodel>(context, listen: false).login(
            response['email'],
            response['name']
        );
      } else {
        setState(() {
          errorMessage = "Invalid email or password!";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF343541),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF202123),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isSignUp ? "Create Account" : "Welcome Back",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
                ),
              if(isSignUp) ...[
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Full Name",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF343541),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16)
              ],
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF343541),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF343541),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                  onPressed: isLoading ? null : _handleSubmit,
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isSignUp ? "Sign Up" : "Sign In", style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: () {
                    setState(() {
                      isSignUp = !isSignUp;
                      errorMessage = "";
                    });
                  },
                  child: Text(
                    isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up",
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}