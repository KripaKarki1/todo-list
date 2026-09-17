import 'package:flutter/material.dart';
import 'package:ncmt_kripa/constants/colors.dart';
import 'package:ncmt_kripa/providers/auth_provider.dart';
import 'package:ncmt_kripa/screens/dashboard.dart';
import 'package:ncmt_kripa/screens/registration_screen.dart';
import 'package:ncmt_kripa/widgets/primary_button.dart';
import 'package:ncmt_kripa/widgets/secondary_outlined_icon_button.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordHidden = true;


Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Trigger the register action via Provider
    final result = await context.read<AuthenticationProvider>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    // Guard against calling context methods if the widget was unmounted while waiting
    if (!mounted) return;

    // Handle Sealed Class Result (or String error depending on your AuthProvider structure)
    switch (result) {
      case AuthSuccess():
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
        );
      case AuthFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthenticationProvider>();

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          top: 100,
          right: 16,
          bottom: 100,
        ),
        child: Container(
          decoration: BoxDecoration(
            // color: whiteColor,
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          width: double.infinity,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/todo.png', width: 120, height: 120),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            hintText: 'Your Email',
                            labelText: 'Email',
                          ),
                        ),
                        SizedBox(height: 18),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            hintText: 'Your Password',
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordHidden
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordHidden = !_isPasswordHidden;
                                });
                              },
                            ),
                          ),

                          obscureText: _isPasswordHidden,
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                             _handleLogin();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: whiteColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: provider.isLoading ? CircularProgressIndicator() : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Dont have an account?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface
                              // color: Theme.of(context).colorScheme.
                            ),
                            ),
                            TextButton(
                              child: Text(
                                'Register',
                                style: TextStyle(color: primaryColor),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return RegistrationScreen();
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
