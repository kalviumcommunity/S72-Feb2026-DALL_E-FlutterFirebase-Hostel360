import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/motion.dart';

/// Dialog for admins to add notes to complaints
/// Used in admin dashboard to add internal or visible notes
class AddNoteDialog extends StatefulWidget {
  final String complaintId;
  final Function(String noteText, bool isAdminNote) onAddNote;

  const AddNoteDialog({
    super.key,
    required this.complaintId,
    required this.onAddNote,
  });

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  bool _isAdminNote = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onAddNote(_noteController.text.trim(), _isAdminNote);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add note: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.easing,
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Text(
                      'Add Note',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing24),

              // Note input
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Enter note details...',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: 500,
                enabled: !_isSubmitting,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a note';
                  }
                  if (value.trim().length < 3) {
                    return 'Note must be at least 3 characters';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Admin note toggle
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Internal Admin Note',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Only visible to admins',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAdminNote,
                      onChanged: _isSubmitting
                          ? null
                          : (value) => setState(() => _isAdminNote = value),
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Text('Add Note'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
