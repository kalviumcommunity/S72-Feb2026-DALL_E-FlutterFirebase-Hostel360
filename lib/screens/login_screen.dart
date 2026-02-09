import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/form_validator.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isFormValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    final authProvider = Provider.of<ChangeNotifier>(context, listen: false) as dynamic;
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      // Navigation will be handled by the main app based on auth state
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ChangeNotifier>(
            builder: (context, authProvider, child) {
              final provider = authProvider as dynamic;
              return Form(
                key: _formKey,
                onChanged: _validateForm,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome to Hostel360',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Email field
                    TextFormField(
                      key: const Key('email'),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: FormValidator.validateEmail,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password field
                    TextFormField(
                      key: const Key('password'),
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: FormValidator.validatePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 24),
                    
                    // Error message
                    if (provider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          provider.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // Login button
                    ElevatedButton(
                      key: const Key('loginButton'),
                      onPressed: provider.isLoading || !_isFormValid
                          ? null
                          : _handleLogin,
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Navigate to signup
                    TextButton(
                      key: const Key('goToSignup'),
                      onPressed: provider.isLoading
                          ? null
                          : () {
                              provider.clearError();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                      child: const Text('Don\'t have an account? Sign up'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
