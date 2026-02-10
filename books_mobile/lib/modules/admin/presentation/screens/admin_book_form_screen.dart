import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/utils/resolve_image_url.dart';
import '../../../../shared/models/book_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../models/admin_book_payload.dart';
import '../../models/admin_image_selection.dart';
import '../providers/admin_controller.dart';

class AdminBookFormScreen extends ConsumerStatefulWidget {
  const AdminBookFormScreen({super.key, this.book});

  final BookModel? book;

  bool get isEditing => book != null;

  @override
  ConsumerState<AdminBookFormScreen> createState() =>
      _AdminBookFormScreenState();
}

class _AdminBookFormScreenState extends ConsumerState<AdminBookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _publisherController = TextEditingController();
  final _publishedYearController = TextEditingController();
  final _pageCountController = TextEditingController();
  final _stockController = TextEditingController(text: '1');
  final _priceCentsController = TextEditingController(text: '1000');

  int? _selectedTypeId;
  int? _selectedCategoryId;
  String _status = 'available';
  bool _removeImage = false;
  AdminImageSelection? _selectedImage;
  String? _existingImageUrl;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    Future.microtask(_ensureCatalogDependencies);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _publisherController.dispose();
    _publishedYearController.dispose();
    _pageCountController.dispose();
    _stockController.dispose();
    _priceCentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);
    final types = adminState.types;
    final categories = adminState.categories;
    final filteredCategories = categories
        .where((item) => item.genre?.id == _selectedTypeId)
        .toList();

    if (_selectedTypeId == null && types.isNotEmpty) {
      _selectedTypeId = types.first.id;
    }
    if (_selectedCategoryId == null && filteredCategories.isNotEmpty) {
      _selectedCategoryId = filteredCategories.first.id;
    } else if (_selectedCategoryId != null &&
        filteredCategories.every((item) => item.id != _selectedCategoryId)) {
      _selectedCategoryId = filteredCategories.isEmpty
          ? null
          : filteredCategories.first.id;
    }

    final typeError = _fieldError(adminState, 'genre_id');
    final categoryError = _fieldError(adminState, 'category_id');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Book' : 'Create Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                key: ValueKey('book-type-${_selectedTypeId ?? 0}'),
                initialValue: _selectedTypeId,
                decoration: InputDecoration(
                  labelText: 'Type',
                  errorText: typeError,
                ),
                items: types
                    .map(
                      (type) => DropdownMenuItem<int>(
                        value: type.id,
                        child: Text(type.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  final categoriesForType = categories
                      .where((item) => item.genre?.id == value)
                      .toList();
                  setState(() {
                    _selectedTypeId = value;
                    _selectedCategoryId = categoriesForType.isEmpty
                        ? null
                        : categoriesForType.first.id;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: ValueKey('book-category-${_selectedCategoryId ?? 0}'),
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category',
                  errorText: categoryError,
                ),
                items: filteredCategories
                    .map(
                      (category) => DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
                validator: (value) {
                  if (value == null || value <= 0) {
                    return 'Category is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  errorText: _fieldError(adminState, 'title'),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  errorText: _fieldError(adminState, 'author'),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  errorText: _fieldError(adminState, 'description'),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _publisherController,
                decoration: InputDecoration(
                  labelText: 'Publisher',
                  errorText: _fieldError(adminState, 'publisher'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _publishedYearController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Published year',
                        errorText: _fieldError(adminState, 'published_year'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _pageCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Page count',
                        errorText: _fieldError(adminState, 'page_count'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stock quantity',
                        errorText: _fieldError(adminState, 'stock_quantity'),
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _priceCentsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price cents',
                        errorText: _fieldError(adminState, 'price_cents'),
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey('book-status-$_status'),
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  errorText: _fieldError(adminState, 'status'),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'available',
                    child: Text('available'),
                  ),
                  DropdownMenuItem(
                    value: 'out_of_stock',
                    child: Text('out_of_stock'),
                  ),
                  DropdownMenuItem(value: 'archived', child: Text('archived')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _status = value);
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Cover image',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Symbols.upload_file),
                label: const Text('Select image from device'),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _selectedImage!.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_fieldError(adminState, 'image') != null) ...[
                const SizedBox(height: 6),
                Text(
                  _fieldError(adminState, 'image')!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              _buildImagePreview(context),
              const SizedBox(height: 8),
              if (_selectedImage != null || _existingImageUrl != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _existingImageUrl = null;
                      _removeImage = true;
                    });
                  },
                  icon: const Icon(Symbols.delete),
                  label: const Text('Remove image'),
                ),
              if (_localError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _localError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (adminState.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  adminState.errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: adminState.isSaving ? null : _submit,
                  icon: adminState.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Symbols.save),
                  label: Text(
                    widget.isEditing ? 'Save changes' : 'Create book',
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    if (_selectedImage?.bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          Uint8List.fromList(_selectedImage!.bytes!),
          width: 120,
          height: 160,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      final imageUrl = resolveImageUrl(_existingImageUrl);
      if (imageUrl == null) {
        return const SizedBox.shrink();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 120,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox(
            width: 120,
            height: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFFEFF5FA)),
              child: Center(child: Icon(Symbols.broken_image)),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _ensureCatalogDependencies() async {
    final controller = ref.read(adminControllerProvider.notifier);
    final state = ref.read(adminControllerProvider);
    if (state.types.isEmpty) {
      await controller.loadTypes();
    }
    if (state.categories.isEmpty) {
      await controller.loadCategories();
    }

    if (!mounted) return;
    _resolveTypeAndCategoryDefaults();
  }

  void _initializeForm() {
    final book = widget.book;
    if (book == null) {
      return;
    }

    _titleController.text = book.title;
    _authorController.text = book.author;
    _descriptionController.text = book.description;
    _publisherController.text = book.publisher ?? '';
    _publishedYearController.text = book.publishedYear?.toString() ?? '';
    _pageCountController.text = book.pageCount?.toString() ?? '';
    _stockController.text = book.stockQuantity.toString();
    _priceCentsController.text = book.priceCents.toString();
    _status = book.status;
    _selectedCategoryId = book.category?.id;
    _selectedTypeId = book.category?.genre?.id;
    _existingImageUrl = book.imageUrl ?? book.coverImageUrl ?? book.coverImage;
  }

  void _resolveTypeAndCategoryDefaults() {
    final state = ref.read(adminControllerProvider);
    final types = state.types;
    final categories = state.categories;

    if (_selectedTypeId == null && types.isNotEmpty) {
      _selectedTypeId = types.first.id;
    }

    if (_selectedCategoryId == null && _selectedTypeId != null) {
      final firstCategory = categories.firstWhere(
        (item) => item.genre?.id == _selectedTypeId,
        orElse: () => categories.isNotEmpty
            ? categories.first
            : const CategoryModel(id: 0, name: ''),
      );
      if (firstCategory.id > 0) {
        _selectedCategoryId = firstCategory.id;
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    final files = result?.files;
    final file = files != null && files.isNotEmpty ? files.first : null;
    if (file == null) {
      return;
    }

    setState(() {
      _selectedImage = AdminImageSelection(
        name: file.name,
        path: file.path,
        bytes: file.bytes,
      );
      _removeImage = false;
      _localError = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoryId = _selectedCategoryId;
    if (categoryId == null || categoryId <= 0) {
      setState(() => _localError = 'Category is required.');
      return;
    }

    final stockQuantity = int.tryParse(_stockController.text.trim());
    final priceCents = int.tryParse(_priceCentsController.text.trim());
    final publishedYear = _parseOptionalInt(_publishedYearController.text);
    final pageCount = _parseOptionalInt(_pageCountController.text);

    if (stockQuantity == null || stockQuantity < 0) {
      setState(
        () => _localError = 'Stock quantity must be a valid positive number.',
      );
      return;
    }
    if (priceCents == null || priceCents < 1) {
      setState(
        () =>
            _localError = 'Price cents must be a valid number greater than 0.',
      );
      return;
    }

    setState(() => _localError = null);

    final payload = AdminBookPayload(
      categoryId: categoryId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      author: _authorController.text.trim(),
      publisher: _publisherController.text.trim().isEmpty
          ? null
          : _publisherController.text.trim(),
      publishedYear: publishedYear,
      pageCount: pageCount,
      stockQuantity: stockQuantity,
      priceCents: priceCents,
      status: _status,
      image: _selectedImage,
      removeImage: _removeImage,
    );

    final success = await ref
        .read(adminControllerProvider.notifier)
        .saveBook(bookId: widget.book?.id, payload: payload);

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  int? _parseOptionalInt(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    return int.tryParse(cleaned);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  String? _fieldError(AdminState state, String field) {
    final errors = state.validationErrors[field];
    if (errors == null || errors.isEmpty) {
      return null;
    }
    return errors.first;
  }
}
