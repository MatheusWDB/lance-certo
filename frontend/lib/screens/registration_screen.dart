import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:lance_certo/mixins/validations_mixin.dart';
import 'package:lance_certo/models/user.dart';
import 'package:lance_certo/models/user_role.dart';
import 'package:lance_certo/services/user_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with ValidationsMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controller = {
    'name': TextEditingController(),
    'username': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };
  bool _isLoading = false;
  bool _viewConfirmPassword = false;
  bool _viewPassword = false;

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      _isLoading = false;
      return;
    }

    final newUser = User(
      name: _controller['name']!.text,
      username: _controller['email']!.text,
      email: _controller['email']!.text,
      phone: _controller['phone']!.text,
      role: UserRole.SELLER,
    );

    try {
      await UserService.registerUser(newUser, _controller['password']!.text);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao cadastrar: $e');
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
  void dispose() {
    _controller.forEach((key, value) => value.dispose());
    super.dispose();
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
          children: [
            Container(
              decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
              child: Center(
                child: Container(
                  width: width * .9,
                  constraints: const BoxConstraints(
                    maxWidth: 450.0,
                    maxHeight: 770.0,
                  ),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey),
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
                          'Registrar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            spacing: 8.0,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Nome:'),
                                  TextFormField(
                                    autofocus: true,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _controller['name'],
                                    decoration: InputDecoration(
                                      hintText: 'João Maria',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          textFormFieldBorderRadius,
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        maxWidth: textFormFieldMaxWidth,
                                      ),
                                      hintStyle: const TextStyle(
                                        color: hintTextColor,
                                      ),
                                    ),
                                    validator: (value) => isNotEmpty(value),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Email:'),
                                  TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _controller['email'],
                                    decoration: InputDecoration(
                                      hintText: 'email@gmail.com',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          textFormFieldBorderRadius,
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        maxWidth: textFormFieldMaxWidth,
                                      ),
                                      hintStyle: const TextStyle(
                                        color: hintTextColor,
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
                                  const Text('Telefone:'),
                                  TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _controller['phone'],
                                    decoration: InputDecoration(
                                      constraints: const BoxConstraints(
                                        maxWidth: textFormFieldMaxWidth,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          textFormFieldBorderRadius,
                                        ),
                                      ),
                                      hintText: '(00) 9 1234-5678',
                                      hintStyle: const TextStyle(
                                        color: hintTextColor,
                                      ),
                                    ),
                                    validator: (value) =>
                                        combine([() => isNotEmpty(value)]),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Senha:'),
                                  TextFormField(
                                    controller: _controller['password'],
                                    autocorrect: false,
                                    obscureText: !_viewPassword,
                                    obscuringCharacter: '*',
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      constraints: const BoxConstraints(
                                        maxWidth: textFormFieldMaxWidth,
                                      ),
                                      hintText: 'senha123',
                                      hintStyle: const TextStyle(
                                        color: hintTextColor,
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
                                    validator: (value) => combine([
                                      () => isNotEmpty(value),
                                      () => hasEightChars(value),
                                    ]),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Confirme a senha:'),
                                  TextFormField(
                                    controller: _controller['confirmPassword'],
                                    autocorrect: false,
                                    obscureText: !_viewConfirmPassword,
                                    obscuringCharacter: '*',
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      constraints: const BoxConstraints(
                                        maxWidth: textFormFieldMaxWidth,
                                      ),
                                      hintText: 'senha123',
                                      hintStyle: const TextStyle(
                                        color: hintTextColor,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          textFormFieldBorderRadius,
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _viewConfirmPassword == true
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _viewConfirmPassword =
                                                !_viewConfirmPassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) => combine([
                                      () => isNotEmpty(value),
                                      () => hasEightChars(value),
                                      () => confirmPassword(
                                        value,
                                        _controller['password']?.text,
                                      ),
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
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () => _register(),
                          child: const Text(
                            'Registrar',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Já tem uma conta?'),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Faça login.',
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
}
