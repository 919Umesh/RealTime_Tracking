import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:io';
import '../../../models/product_model.dart';
import '../product_bloc/product_bloc.dart';

class CreateProduct extends StatefulWidget {
  const CreateProduct({super.key});

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  final _formKey = GlobalKey<FormBuilderState>();
  File? _imageFile;
  bool _isLoading = false;


  final ImagePicker _picker = ImagePicker();


  static const String fieldProductName = 'productName';
  static const String fieldCurrentPrice = 'currentPrice';
  static const String fieldSize = 'size';
  static const String fieldCategory = 'category';
  static const String fieldOldPrice = 'oldPrice';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      setState(() => _isLoading = true);

      try {
        final String imageUrl = _imageFile?.path ?? '';

        final product = Product(
          productName: formData[fieldProductName],
          productImageUrl: imageUrl,
          currentPrice: formData[fieldCurrentPrice].toString(),
          productSize: formData[fieldSize],
          categoryName: formData[fieldCategory],
          oldPrice: formData[fieldOldPrice].toString(),
        );

        context.read<ProductBloc>().add(AddProduct(product));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting form: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Product"),
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Product added successfully!")),
            );
            Navigator.pop(context);
          } else if (state is ProductAddError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${state.error}")),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductAdding || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Preview and Picker
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50),
                          SizedBox(height: 8),
                          Text('Tap to add product image'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Fields
                  FormBuilderTextField(
                    name: fieldProductName,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  FormBuilderTextField(
                    name: fieldCurrentPrice,
                    decoration: const InputDecoration(
                      labelText: 'Current Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.min(0),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  FormBuilderTextField(
                    name: fieldSize,
                    decoration: const InputDecoration(
                      labelText: 'Size',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  FormBuilderTextField(
                    name: fieldCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  FormBuilderTextField(
                    name: fieldOldPrice,
                    decoration: const InputDecoration(
                      labelText: 'Old Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.min(0),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Create Product',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}