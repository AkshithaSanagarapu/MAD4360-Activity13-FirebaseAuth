import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProductManagerApp());
}

class ProductManagerApp extends StatelessWidget {
  const ProductManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Product Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const ProductHomePage(),
    );
  }
}

class ProductHomePage extends StatefulWidget {
  const ProductHomePage({super.key});

  @override
  State<ProductHomePage> createState() => _ProductHomePageState();
}

class _ProductHomePageState extends State<ProductHomePage> {
  final CollectionReference<Map<String, dynamic>> products =
      FirebaseFirestore.instance.collection('products');

  final TextEditingController searchController =
      TextEditingController();
  final TextEditingController minimumController = TextEditingController();
  final TextEditingController maximumController = TextEditingController();
  String? filterError;

  String searchText = '';
  double? minimumPrice;
  double? maximumPrice;

  @override
  void dispose() {
    searchController.dispose();
    minimumController.dispose();
    maximumController.dispose();
    super.dispose();
  }

  Future<void> showProductDialog({
    DocumentSnapshot<Map<String, dynamic>>? document,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => ProductFormDialog(
        products: products,
        document: document,
      ),
    );
  }

  Future<void> deleteProduct(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text(
          'Delete "${document.data()?['name'] ?? 'this product'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await products.doc(document.id).delete();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $error'),
        ),
      );
    }
  }

  void resetFilters() {
    searchController.clear();
    minimumController.clear();
    maximumController.clear();

    setState(() {
      searchText = '';
      minimumPrice = null;
      maximumPrice = null;
      filterError = null;
    });
  }


  double? _parseBound(String value) {
    final text = value.trim();
    return text.isEmpty ? null : double.tryParse(text);
  }

  String? _validateBounds() {
    for (final value in [minimumController.text, maximumController.text]) {
      if (value.trim().isEmpty) continue;
      final number = double.tryParse(value.trim());
      if (number == null || !number.isFinite || number < 0) {
        return 'Enter valid nonnegative price limits.';
      }
    }
    if (minimumPrice != null && maximumPrice != null && minimumPrice! > maximumPrice!) {
      return 'Minimum price cannot exceed maximum price.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Product Manager'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search products',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText =
                          value.toLowerCase().trim();
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minimumController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Minimum price',
                          hintText: 'No minimum',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            minimumPrice = _parseBound(value);
                            filterError = _validateBounds();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maximumController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Maximum price',
                          hintText: 'No maximum',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            maximumPrice = _parseBound(value);
                            filterError = _validateBounds();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: resetFilters,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                if (filterError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(filterError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: products.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Firestore error:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (filterError != null) {
                  return const Center(child: Text('Please correct the price limits.'));
                }

                final documents =
                    snapshot.data!.docs.where((document) {
                  final data = document.data();

                  final name = (data['name'] ?? '')
                      .toString()
                      .toLowerCase();

                  final rawPrice = data['price'];

                  final price = rawPrice is num
                      ? rawPrice.toDouble()
                      : double.tryParse(
                          rawPrice?.toString() ?? '',
                        );

                  final matchesName =
                      name.contains(searchText);

                  final matchesPrice =
                      (minimumPrice == null || (price != null && price >= minimumPrice!)) &&
                      (maximumPrice == null || (price != null && price <= maximumPrice!));

                  return matchesName && matchesPrice;
                }).toList();

                documents.sort((a, b) {
                  final aName = (a.data()['name'] ?? '')
                      .toString()
                      .toLowerCase();

                  final bName = (b.data()['name'] ?? '')
                      .toString()
                      .toLowerCase();

                  return aName.compareTo(bName);
                });

                if (documents.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching products found.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 90,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final data = document.data();
                    final rawPrice = data['price'];

                    final price = rawPrice is num
                        ? rawPrice.toDouble()
                        : double.tryParse(
                            rawPrice?.toString() ?? '',
                          );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      child: ListTile(
                        title: Text(
                          (data['name'] ??
                                  'Unnamed product')
                              .toString(),
                        ),
                        subtitle: Text(
                          price != null
                              ? '\$${price.toStringAsFixed(2)}'
                              : 'Price unavailable',
                        ),
                        trailing: Wrap(
                          spacing: 0,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(
                                Icons.edit_outlined,
                              ),
                              onPressed: () =>
                                  showProductDialog(
                                document: document,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(
                                Icons.delete_outline,
                              ),
                              onPressed: () =>
                                  deleteProduct(document),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Separate stateful dialog manages its own controllers.
// Controllers are disposed only when the dialog is unmounted.
class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({
    super.key,
    required this.products,
    this.document,
  });

  final CollectionReference<Map<String, dynamic>> products;
  final DocumentSnapshot<Map<String, dynamic>>? document;

  @override
  State<ProductFormDialog> createState() =>
      _ProductFormDialogState();
}

class _ProductFormDialogState
    extends State<ProductFormDialog> {
  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController priceController;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    final data = widget.document?.data();

    nameController = TextEditingController(
      text: data?['name']?.toString() ?? '',
    );

    priceController = TextEditingController(
      text: data?['price']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> saveProduct() async {
    if (saving) return;

    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    final productData = <String, dynamic>{
      'name': nameController.text.trim(),
      'price': double.parse(
        priceController.text.trim(),
      ),
    };

    try {
      if (widget.document == null) {
        await widget.products.add(productData);
      } else {
        await widget.products
            .doc(widget.document!.id)
            .update(productData);
      }

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.document == null
            ? 'Add Product'
            : 'Edit Product',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                enabled: !saving,
                textCapitalization:
                    TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Product name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter a product name';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                enabled: !saving,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final price = double.tryParse(
                    value?.trim() ?? '',
                  );

                  if (price == null ||
                      !price.isFinite ||
                      price < 0) {
                    return 'Enter a valid non-negative price';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : saveProduct,
          child: Text(
            saving ? 'Saving...' : 'Save',
          ),
        ),
      ],
    );
  }
}
