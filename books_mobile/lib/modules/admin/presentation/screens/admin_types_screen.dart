import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../shared/models/genre_model.dart';
import '../providers/admin_controller.dart';

class AdminTypesScreen extends ConsumerStatefulWidget {
  const AdminTypesScreen({super.key});

  @override
  ConsumerState<AdminTypesScreen> createState() => _AdminTypesScreenState();
}

class _AdminTypesScreenState extends ConsumerState<AdminTypesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminControllerProvider.notifier).loadTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);
    final types = state.types;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Manage Types',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openForm,
                icon: const Icon(Symbols.add),
                label: const Text('Add Type'),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isLoading && types.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(adminControllerProvider.notifier).loadTypes(),
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
                      if (types.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No types found. Create your first type.',
                            ),
                          ),
                        )
                      else
                        ...types.map(
                          (type) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(type.name),
                              subtitle: Text(
                                type.description ?? 'No description',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit type',
                                    onPressed: () => _openForm(type: type),
                                    icon: const Icon(Symbols.edit_square),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete type',
                                    onPressed: () => _confirmDelete(type),
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

  Future<void> _openForm({GenreModel? type}) async {
    final nameController = TextEditingController(text: type?.name ?? '');
    final descriptionController = TextEditingController(
      text: type?.description ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(adminControllerProvider);
            final nameError = state.validationErrors['name']?.first;

            return AlertDialog(
              title: Text(type == null ? 'Create Type' : 'Edit Type'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Type name',
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
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          state.errorMessage!,
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
                  onPressed: state.isSaving
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          final success = await ref
                              .read(adminControllerProvider.notifier)
                              .saveType(
                                typeId: type?.id,
                                name: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                              );
                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  type == null
                                      ? 'Type created successfully.'
                                      : 'Type updated successfully.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: state.isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Symbols.check),
                  label: Text(type == null ? 'Create' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    ref.read(adminControllerProvider.notifier).clearValidationErrors();
  }

  Future<void> _confirmDelete(GenreModel type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Type'),
        content: Text('Delete "${type.name}" permanently?'),
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
        .deleteType(type.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Type deleted successfully.' : 'Unable to delete type.',
        ),
        backgroundColor: success ? null : Colors.red,
      ),
    );
  }
}
