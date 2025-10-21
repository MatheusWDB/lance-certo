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
  bool _isLoading = false;
  bool viewPassword = false;
  Map<String, String?> error = {'username': null, 'password': null};
  final _formKey = GlobalKey<FormState>();
  Map<String, TextEditingController> controller = {
    'username': TextEditingController(text: 'seller@gmail.com'),
    'password': TextEditingController(text: '12345678'),
  };

  void login() async {
    setState(() {
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      _isLoading = false;
      return;
    }

    /** 
    if (!controller['username']!.text.contains('@') ||
        !controller['username']!.text.contains('.')) {
      final int atIndex = controller['username']!.text.indexOf('@');
      final int dotIndex = controller['username']!.text.lastIndexOf('.');
      if (atIndex < 1 ||
          dotIndex < atIndex + 2 ||
          dotIndex == controller['username']!.text.length - 1) {
        setState(() {
          error['username'] = 'Inválido';
          
          _isLoading = false;
        });
        return;
      }
    }
    */

    try {
      await UserService.login(
        controller['username']!.text,
        controller['password']!.text,
      );
      resetController();
      resetError();

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

  @override
  Widget build(BuildContext context) {
    // Âncora

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    /** 
    X-Small	None	<576px
    Small	sm	≥576px
    Medium	md	≥768px
    Large	lg	≥992px
    Extra large	xl	≥1200px
    Extra extra large	xxl	≥1400px    

    final xsm = width < 576;
    final sm = width >= 576;
    final md = width >= 768;
    final lg = width >= 992;
    final xl = width >= 1200;
    final xxl = width >= 1400;
    */
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: width * 0.376),
                  height: height * 0.523,
                  padding: const EdgeInsets.all(32.0),
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [BoxShadow(blurRadius: 10.0)],
                  ),
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
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email ou Nome de Usuário:'),
                                TextFormField(
                                  autofocus: true,
                                  controller: controller['username'],
                                  decoration: InputDecoration(
                                    errorText: error['username'],
                                    hintText: 'Email ou Nome de Usuário',
                                    //constraints: BoxConstraints(maxWidth: 300.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) => isNotEmpty(value),
                                  onChanged: (value) {
                                    setState(() {
                                      error['username'] = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Senha:'),
                                TextFormField(
                                  autocorrect: false,
                                  controller: controller['password'],
                                  decoration: InputDecoration(
                                    errorText: error['password'],
                                    hintText: 'Senha',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
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
                                  validator: (value) => combine([
                                    () => isNotEmpty(value),
                                    () => hasEightChars(value),
                                  ]),
                                  onChanged: (value) {
                                    setState(() {
                                      error['password'] = null;
                                    });
                                  },
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
                        onPressed: () => login(),
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
                              resetController();
                              resetError();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Registre-se aqui',
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

  @override
  void dispose() {
    controller.forEach((key, value) => value.dispose());
    super.dispose();
  }
}
