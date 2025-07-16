import 'package:flutter/material.dart';
import 'package:lance_certo/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, TextEditingController> controller = {
    'username': TextEditingController(),
    'password': TextEditingController(),
  };
  Map<String, String?> error = {'username': null, 'password': null};

  bool viewPassword = false;

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
                      Text('Entrar'),
                      TextField(
                        autofocus: true,
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
                      ElevatedButton(onPressed: () {}, child: Text('Login')),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Não tem uma conta?'),
                          TextButton(
                            onPressed: () {},
                            child: Text('Registre-se aqui'),
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

  void login() async {
    final attributes = ['username', 'password'];

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

    resetController();
    resetError();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void resetController() {
    setState(() {
      controller['username']?.clear();
      controller['password']?.clear();
    });
  }

  void resetError() {
    setState(() {
      error['username'] = null;
      error['password'] = null;
    });
  }
}
