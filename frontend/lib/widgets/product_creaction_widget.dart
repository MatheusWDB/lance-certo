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
  final Map<String, TextEditingController> _productController = {
    'name': TextEditingController(),
    'description': TextEditingController(),
    'category': TextEditingController(),
    'imageUrl': TextEditingController(),
  };

  void _submitProduct() async {
    final Product newProduct = Product(
      name: _productController['name']!.text,
      description: _productController['description']!.text,
      category: _productController['category']!.text,
      imageUrl: _productController['imageUrl']!.text.isNotEmpty
          ? _productController['imageUrl']!.text
          : null,
    );

    ProductService.createProduct(newProduct)
        .then((createdProduct) {
          if (!mounted) return;
          Navigator.of(context).pop();
          widget.onProductCreated();
        })
        .catchError((error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao criar produto: $error')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            decoration: const InputDecoration(
              labelText: 'Nome do Produto:',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ),
          TextField(
            controller: _productController['description'],
            decoration: const InputDecoration(
              labelText: 'Descrição:',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ),
          TextField(
            controller: _productController['category'],
            decoration: const InputDecoration(
              labelText: 'Categoria:',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ),
          TextField(
            controller: _productController['imageUrl'],
            decoration: const InputDecoration(
              labelText: 'URL da Imagem (opcional):',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
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
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: _submitProduct,
            child: const Text('Criar Produto'),
          ),
        ],
      ),
    );
  }
}
