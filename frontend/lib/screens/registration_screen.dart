import 'package:flutter/material.dart';
import 'package:lance_certo/models/user.dart';
import 'package:lance_certo/services/user_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isLoading = false;

  Map<String, TextEditingController> controller = {
    'name': TextEditingController(),
    'username': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };
  Map<String, String?> error = {
    'name': null,
    'username': null,
    'email': null,
    'phone': null,
    'password': null,
    'confirmPassword': null,
  };

  bool viewPassword = false;
  bool viewConfirmPassword = false;

  void register() async {
    setState(() {
      _isLoading = true;
    });

    final attributes = [
      'name',
      'username',
      'email',
      'phone',
      'password',
      'confirmPassword',
    ];

    for (var attribute in attributes) {
      if (controller[attribute]!.text.isEmpty) {
        setState(() {
          error[attribute] = 'Campo requerido';
          _isLoading = false;
        });
        return;
      }
    }

    if (!controller['email']!.text.contains('@') ||
        !controller['email']!.text.contains('.')) {
      final int atIndex = controller['email']!.text.indexOf('@');
      final int dotIndex = controller['email']!.text.lastIndexOf('.');
      if (atIndex < 1 ||
          dotIndex < atIndex + 2 ||
          dotIndex == controller['email']!.text.length - 1) {
        setState(() {
          error['email'] = 'Inválido';
          _isLoading = false;
        });        
        return;
      }
    }

    if (controller['password']!.text.length < 8) {
      setState(() {
        error['password'] = 'A senha tem no mínimo 8 caracteres';
        _isLoading = false;
      });
      return;
    }

    if (controller['password']!.text != controller['confirmPassword']!.text) {
      setState(() {
        error['password'] = 'As senha não coincidem!';
        error['confirmPassword'] = 'As senha não coincidem!';
        _isLoading = false;
      });
      return;
    }

    final User newUser = User(
      name: controller['name']!.text,
      username: controller['username']!.text,
      email: controller['email']!.text,
      phone: controller['phone']!.text,
    );

    try {
      await UserService.registerUser(newUser, controller['password']!.text);

      resetController();
      resetError();

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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMessage, textAlign: TextAlign.center),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void resetController() {
    setState(() {
      controller['username']?.clear();
      controller['password']?.clear();
      controller['name']?.clear();
      controller['confirmPassword']?.clear();
    });
  }

  void resetError() {
    setState(() {
      error['name'] = null;
      error['confirmPassword'] = null;
      error['username'] = null;
      error['password'] = null;
    });
  }

  @override
  void dispose() {
    controller.forEach((key, value) => value.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.376,
                  ),
                  height: MediaQuery.of(context).size.height * 0.789,
                  padding: const EdgeInsets.all(32.0),
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey),
                    boxShadow: const [BoxShadow(blurRadius: 10.0)],
                  ),
                  child: Column(
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
                      TextField(
                        autofocus: true,
                        controller: controller['name'],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          errorText: error['name'],
                          labelText: 'Nome',
                        ),
                        onChanged: (value) {
                          setState(() {
                            error['name'] = null;
                          });
                        },
                      ),
                      TextField(
                        controller: controller['username'],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          errorText: error['username'],
                          labelText: 'Username',
                        ),
                        onChanged: (value) {
                          setState(() {
                            error['username'] = null;
                          });
                        },
                      ),
                      TextField(
                        controller: controller['email'],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          errorText: error['username'],
                          labelText: 'Email',
                        ),
                        onChanged: (value) {
                          setState(() {
                            error['username'] = null;
                          });
                        },
                      ),
                      TextField(
                        controller: controller['phone'],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          errorText: error['username'],
                          labelText: 'Telefone',
                        ),
                        onChanged: (value) {
                          setState(() {
                            error['username'] = null;
                          });
                        },
                      ),
                      TextField(
                        autocorrect: false,
                        controller: controller['password'],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          errorText: error['password'],
                          labelText: 'Senha',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                viewPassword = !viewPassword;
                              });
                            },
                            icon: Icon(
                              viewPassword == true
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        obscureText: !viewPassword,
                        obscuringCharacter: '*',
                        onChanged: (value) {
                          setState(() {
                            error['password'] = null;
                          });
                        },
                      ),
                      TextField(
                        autocorrect: false,
                        controller: controller['confirmPassword'],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          errorText: error['confirmPassword'],
                          labelText: 'Confirme a senha',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                viewConfirmPassword = !viewConfirmPassword;
                              });
                            },
                            icon: Icon(
                              viewConfirmPassword == true
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        obscureText: !viewConfirmPassword,
                        obscuringCharacter: '*',
                        onChanged: (value) {
                          setState(() {
                            error['password'] = null;
                          });
                        },
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
                        onPressed: () => register(),
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
                              resetController();
                              resetError();
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
