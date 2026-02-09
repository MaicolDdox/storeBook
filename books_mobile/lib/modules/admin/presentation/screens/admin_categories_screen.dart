import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../shared/models/category_model.dart';
import '../providers/admin_controller.dart';

class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final controller = ref.read(adminControllerProvider.notifier);
      await controller.loadTypes();
      await controller.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);
    final categories = state.categories;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Manage Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openForm,
                icon: const Icon(Symbols.add),
                label: const Text('Add Category'),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isLoading && categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(adminControllerProvider.notifier)
                        .loadTypes();
                    await ref
                        .read(adminControllerProvider.notifier)
                        .loadCategories();
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (categories.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No categories found. Create your first category.',
                            ),
                          ),
                        )
                      else
                        ...categories.map(
                          (category) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(category.name),
                              subtitle: Text(
                                '${category.genre?.name ?? 'No type'}${category.description?.isNotEmpty == true ? ' | ${category.description}' : ''}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit category',
                                    onPressed: () =>
                                        _openForm(category: category),
                                    icon: const Icon(Symbols.edit_square),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete category',
                                    onPressed: () => _confirmDelete(category),
                                    icon: const Icon(Symbols.delete),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _openForm({CategoryModel? category}) async {
    final state = ref.read(adminControllerProvider);
    final types = state.types;
    if (types.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create at least one type before creating categories.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    int selectedTypeId = category?.genre?.id ?? types.first.id;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final liveState = ref.watch(adminControllerProvider);
            final nameError = liveState.validationErrors['name']?.first;
            final typeError = liveState.validationErrors['genre_id']?.first;

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: Text(
                    category == null ? 'Create Category' : 'Edit Category',
                  ),
                  content: SizedBox(
                    width: 420,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<int>(
                          key: ValueKey('category-type-$selectedTypeId'),
                          initialValue: selectedTypeId,
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
                            if (value == null) return;
                            setDialogState(() => selectedTypeId = value);
                          },
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Category name',
                            errorText: nameError,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                        if (liveState.errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              liveState.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: liveState.isSaving
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton.icon(
                      onPressed: liveState.isSaving
                          ? null
                          : () async {
                              final success = await ref
                                  .read(adminControllerProvider.notifier)
                                  .saveCategory(
                                    categoryId: category?.id,
                                    typeId: selectedTypeId,
                                    name: nameController.text.trim(),
                                    description: descriptionController.text
                                        .trim(),
                                  );

                              if (success && context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      category == null
                                          ? 'Category created successfully.'
                                          : 'Category updated successfully.',
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: liveState.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Symbols.check),
                      label: Text(category == null ? 'Create' : 'Save'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    ref.read(adminControllerProvider.notifier).clearValidationErrors();
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final success = await ref
        .read(adminControllerProvider.notifier)
        .deleteCategory(category.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Category deleted successfully.'
              : 'Unable to delete category.',
        ),
        backgroundColor: success ? null : Colors.red,
      ),
    );
  }
}
