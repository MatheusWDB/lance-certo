import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  Map<String, TextEditingController> controller = {
    'name': TextEditingController(),
    'username': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };
  Map<String, String?> error = {
    'name': null,
    'username': null,
    'password': null,
    'confirmPassword': null,
  };

  bool viewPassword = false;
  bool viewConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(64.0),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(blurStyle: BlurStyle.outer, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    spacing: 8,
                    children: [
                      Text('Bem-vindo ao Lance Certo'),
                      Text('Registrar'),
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
                          labelText: 'Email',
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
                        onPressed: () => register(),
                        child: Text('Registrar'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Já tem uma conta?'),
                          TextButton(
                            onPressed: () {
                              resetController();
                              resetError();
                              Navigator.pop(context);
                            },
                            child: Text('Faça login.'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void register() async {
    final attributes = ['name', 'username', 'password', 'confirmPassword'];

    for (var attribute in attributes) {
      if (controller[attribute]!.text.isEmpty) {
        setState(() {
          error[attribute] = 'Campo requerido';
        });
        return;
      }
    }

    if (!controller['username']!.text.contains('@') ||
        !controller['username']!.text.contains('.')) {
      final int atIndex = controller['username']!.text.indexOf('@');
      final int dotIndex = controller['username']!.text.lastIndexOf('.');
      if (atIndex < 1 ||
          dotIndex < atIndex + 2 ||
          dotIndex == controller['username']!.text.length - 1) {
        setState(() {
          error['username'] = 'Inválido';
        });
        return;
      }
    }

    if (controller['password']!.text.length < 8) {
      setState(() {
        error['password'] = 'A senha tem no mínimo 8 caracteres';
      });
      return;
    }

    if (controller['password']!.text != controller['confirmPassword']!.text) {
      setState(() {
        error['password'] = 'As senha não coincidem!';
        error['confirmPassword'] = 'As senha não coincidem!';
      });
      return;
    }

    resetController();
    resetError();

    if (!mounted) return;

    Navigator.pop(context);
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
}
