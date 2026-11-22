import 'package:flutter/material.dart';
import 'package:flutterbase/domain/entities/code_history_item.dart';
import 'package:flutterbase/presentation/widgets/ui/app_text_field.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// Edits the note of one history entry. Pops with the text, or with null when
/// cancelled.
class CodeNoteDialog extends StatefulWidget {
  const CodeNoteDialog({super.key, required this.item});

  final CodeHistoryItem item;

  @override
  State<CodeNoteDialog> createState() => _CodeNoteDialogState();
}

class _CodeNoteDialogState extends State<CodeNoteDialog> {
  late final _controller = TextEditingController(text: widget.item.note);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(
        widget.item.note == null ? AppStrings.noteAdd : AppStrings.noteEdit,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.item.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _controller,
              label: AppStrings.noteLabel,
              helperText: AppStrings.noteHelper,
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.noteCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text(AppStrings.noteSave),
        ),
      ],
    );
  }
}
