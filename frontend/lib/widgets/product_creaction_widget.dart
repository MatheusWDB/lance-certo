import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:lance_certo/models/product.dart';
import 'package:lance_certo/services/product_service.dart';

class ProductCreationWidget extends StatefulWidget {
  const ProductCreationWidget({required this.onProductCreated, super.key});

  final VoidCallback onProductCreated;

  @override
  State<ProductCreationWidget> createState() => _ProductCreationWidgetState();
}

class _ProductCreationWidgetState extends State<ProductCreationWidget> {
  bool _isLoading = false;

  final Map<String, TextEditingController> _productController = {
    'name': TextEditingController(),
    'description': TextEditingController(),
    'category': TextEditingController(),
    'imageUrl': TextEditingController(),
  };
  final Map<String, String?> _productError = {
    'name': null,
    'description': null,
    'category': null,
    'imageUrl': null,
  };

  void _submitProduct() async {
    setState(() {
      _isLoading = true;
    });

    bool hasError = false;

    _productController.forEach((key, value) {
      if (key != 'imageUrl' && value.text.isEmpty) {
        _productError[key] = 'Campo obrigatório.';
        hasError = true;

        return;
      }
    });

    if (hasError) {
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
      ProductService.createProduct(newProduct);

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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16.0,
            children: [
              const Text(
                'Criar Novo Produto',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
              ),
              TextField(
                controller: _productController['name'],
                decoration: InputDecoration(
                  labelText: 'Nome do Produto',
                  errorText: _productError['name'],
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _productError['name'] = null;
                  });
                },
              ),
              TextField(
                controller: _productController['description'],
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  errorText: _productError['description'],
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _productError['description'] = null;
                  });
                },
              ),
              TextField(
                controller: _productController['category'],
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  errorText: _productError['category'],
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _productError['category'] = null;
                  });
                },
              ),
              TextField(
                controller: _productController['imageUrl'],
                decoration: InputDecoration(
                  labelText: 'URL da Imagem (opcional)',
                  errorText: _productError['imageUrl'],
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _productError['imageUrl'] = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 37, 99, 235),
                  foregroundColor: Colors.white,
                  // fixedSize: Size(MediaQuery.of(context).size.width * 0.13, 50),
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
        if (_isLoading) ...[
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.4),
          ),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _productController.forEach((key, value) => value.dispose());
    super.dispose();
  }
}
