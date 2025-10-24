
import 'package:flutter/material.dart';

class GenericCatalogScreen extends StatelessWidget {
  final String catalogName;

  const GenericCatalogScreen({super.key, required this.catalogName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(catalogName),
      ),
      body: Center(
        child: Text('Экран для каталога: $catalogName (в разработке)'),
      ),
    );
  }
}
