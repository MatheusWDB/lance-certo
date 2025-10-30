import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:lance_certo/mixins/validations_mixin.dart';
import 'package:lance_certo/models/product.dart';
import 'package:lance_certo/services/product_service.dart';
import 'package:lance_certo/utils/responsive.dart';

class ProductCreationWidget extends StatefulWidget {
  const ProductCreationWidget({required this.onProductCreated, super.key});

  final VoidCallback onProductCreated;

  @override
  State<ProductCreationWidget> createState() => _ProductCreationWidgetState();
}

class _ProductCreationWidgetState extends State<ProductCreationWidget>
    with ValidationsMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _productController = {
    'name': TextEditingController(),
    'description': TextEditingController(),
    'category': TextEditingController(),
    'imageUrl': TextEditingController(),
  };
  bool _isLoading = false;

  void _submitProduct() async {
    setState(() {
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Product newProduct = Product(
      name: _productController['name']!.text,
      description: _productController['description']!.text,
      category: _productController['category']!.text,
      imageUrl: _productController['imageUrl']!.text.isNotEmpty
          ? _productController['imageUrl']!.text
          : null,
    );

    try {
      await ProductService.createProduct(newProduct);

      if (!mounted) return;

      widget.onProductCreated();

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Erro ao criar produto: $e');
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
    _productController.forEach((key, value) => value.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeTitle = Responsive.valueForBreakpoints(
      context: context,
      xs: 24.0,
      sm: 32.0,
    );

    final fontSizeHintText = Responsive.valueForBreakpoints(
      context: context,
      xs: 16.0,
    );

    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12.0,
                children: [
                  Text(
                    'Criar Novo Produto',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeTitle,
                    ),
                  ),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      spacing: 8.0,
                      children: [
                        TextFormField(
                          controller: _productController['name'],
                          decoration: InputDecoration(
                            labelText: 'Nome do Produto',
                            labelStyle: TextStyle(fontSize: fontSizeHintText),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                          validator: (value) => isNotEmpty(value),
                        ),
                        TextFormField(
                          controller: _productController['description'],
                          decoration: InputDecoration(
                            labelText: 'Descrição',
                            labelStyle: TextStyle(fontSize: fontSizeHintText),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                          validator: (value) => isNotEmpty(value),
                        ),
                        TextFormField(
                          controller: _productController['category'],
                          decoration: InputDecoration(
                            labelText: 'Categoria',
                            labelStyle: TextStyle(fontSize: fontSizeHintText),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                          validator: (value) => isNotEmpty(value),
                        ),
                        TextFormField(
                          controller: _productController['imageUrl'],
                          decoration: InputDecoration(
                            labelText: 'URL da Imagem (opcional)',
                            labelStyle: TextStyle(fontSize: fontSizeHintText),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 37, 99, 235),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _submitProduct,
                    child: const Text('Criar Produto'),
                  ),
                ],
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
    );
  }
}
