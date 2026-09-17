import 'package:flutter/material.dart';
import 'package:ncmt_kripa/constants/colors.dart';
import 'package:ncmt_kripa/providers/auth_provider.dart';
import 'package:ncmt_kripa/screens/dashboard.dart';
import 'package:ncmt_kripa/widgets/custom_textformfield.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();



  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Trigger the register action via Provider
    final result = await context.read<AuthenticationProvider>().register(
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
final isLoading = context.watch<AuthenticationProvider>().isLoading;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Create Account"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/todo.png',
                      width: 110,
                      height: 110,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Start organizing your tasks today",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                   CustomTextFormField(controller: _nameController, labelText: 'Name', hintText: 'Full Name', validator: (p0) {
                     if(p0 == null || p0.isEmpty){
                      return 'Cant be empty';
                     }
                     return null;
                   },),

                    const SizedBox(height: 18),

                    CustomTextFormField(controller: _emailController, labelText: 'Email', hintText: 'Email'),

                    const SizedBox(height: 18),

                   CustomTextFormField(controller: _passwordController, labelText: "Password", hintText: "Password", isPassword: true,),

                    const SizedBox(height: 18),

                   CustomTextFormField(controller: _confirmPasswordController, labelText: "Confirm Password", hintText: "Confirm Password", isPassword: true,),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: whiteColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                         _handleRegister();
                        },
                        child: isLoading ? CircularProgressIndicator() : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("OR"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
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