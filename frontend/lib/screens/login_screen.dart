import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:lance_certo/mixins/validations_mixin.dart';
import 'package:lance_certo/screens/home_screen.dart';
import 'package:lance_certo/screens/registration_screen.dart';
import 'package:lance_certo/services/user_service.dart';
import 'package:lance_certo/services/web_socket_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with ValidationsMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controller = {
    'username': TextEditingController(),
    'password': TextEditingController(),
  };
  bool _isLoading = false;
  bool _viewPassword = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      _isLoading = false;
      return;
    }

    try {
      await UserService.login(
        _controller['username']!.text,
        _controller['password']!.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      WebSocketService.connect();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      debugPrint('Erro ao logar: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final String errorMessage = e.toString();
        final String cleanMessage = errorMessage.replaceFirst(
          'Exception: ',
          '',
        );

        AlertInfo.show(
          context: context,
          text: cleanMessage,
          typeInfo: TypeInfo.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    const textFormFieldMaxWidth = 300.0;
    const textFormFieldBorderRadius = 10.0;
    const hintTextColor = Colors.grey;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
              child: Center(
                child: Container(
                  width: width * .9,
                  constraints: const BoxConstraints(
                    maxWidth: 450.0,
                    maxHeight: 525.0,
                  ),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [BoxShadow(blurRadius: 10.0)],
                  ),
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 20.0,
                      children: [
                        const Text(
                          'Bem-vindo ao Lance Certo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Entrar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: _formKey,
                          child: Column(
                            spacing: 8.0,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Email:'),
                                  TextFormField(
                                    autofocus: true,
                                    controller: _controller['username'],
                                    decoration: InputDecoration(
                                      hintText: 'email@gmail.com',
                                      hintStyle: const TextStyle(
                                        color: hintTextColor,
                                      ),
                                      constraints: const BoxConstraints(
                                        maxWidth: textFormFieldMaxWidth,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          textFormFieldBorderRadius,
                                        ),
                                      ),
                                    ),
                                    validator: (value) => combine([
                                      () => isNotEmpty(value),
                                      () => isValidEmail(value),
                                    ]),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Senha:'),
                                  TextFormField(
                                    autocorrect: false,
                                    controller: _controller['password'],
                                    decoration: InputDecoration(
                                      hintText: 'senha123',
                                      hintStyle: const TextStyle(
                                        color: hintTextColor,
                                      ),
                                      constraints: const BoxConstraints(
                                        maxWidth: textFormFieldMaxWidth,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          textFormFieldBorderRadius,
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _viewPassword = !_viewPassword;
                                          });
                                        },
                                        icon: Icon(
                                          _viewPassword == true
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                      ),
                                    ),
                                    obscureText: !_viewPassword,
                                    obscuringCharacter: '*',
                                    validator: (value) => combine([
                                      () => isNotEmpty(value),
                                      () => hasEightChars(value),
                                    ]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 52.0,
                              vertical: 16.0,
                            ),
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () => _login(),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Não tem uma conta?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Registre-se.',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading) ...[
              ModalBarrier(
                dismissible: false,
                color: Colors.black.withValues(alpha: 0.4),
              ),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.forEach((key, value) => value.dispose());
    super.dispose();
  }
}
