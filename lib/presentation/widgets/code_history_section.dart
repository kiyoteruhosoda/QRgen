import 'package:flutter/material.dart';
import 'package:flutterbase/domain/entities/code_history_item.dart';
import 'package:flutterbase/presentation/viewmodels/code_history_viewmodel.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// History list shared by the scanner and generator tabs.
///
/// Tapping an entry hands its value to [onSelect] and moves it to the top.
/// Each entry can be deleted, and the whole list cleared after confirmation.
class CodeHistorySection extends StatelessWidget {
  const CodeHistorySection({
    super.key,
    required this.viewModel,
    required this.emptyText,
    required this.onSelect,
    this.listHeight,
  });

  final CodeHistoryViewModel viewModel;
  final String emptyText;
  final ValueChanged<String> onSelect;

  /// Fixed, scrollable list height. When null the list takes the height of
  /// its entries, for use inside an outer scroll view.
  final double? listHeight;

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.historyClearTitle),
        content: const Text(AppStrings.historyClearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.historyCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.historyClearConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) await viewModel.clear();
  }

  Future<void> _delete(BuildContext context, String value) async {
    final messenger = ScaffoldMessenger.of(context);
    await viewModel.delete(value);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(AppStrings.historyDeleted)));
  }

  void _select(String value) {
    onSelect(value);
    viewModel.recordUse(value);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final history = viewModel.items;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.historyTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed:
                      history.isEmpty ? null : () => _confirmClear(context),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text(AppStrings.historyClearAll),
                ),
              ],
            ),
            if (history.isEmpty)
              SizedBox(
                height: listHeight ?? AppSpacing.xxxl,
                child: Center(
                  child: Text(
                    emptyText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
            else if (listHeight != null)
              SizedBox(
                height: listHeight,
                child: ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _buildTile(context, history[index]),
                ),
              )
            else
              for (final (index, item) in history.indexed) ...[
                if (index > 0) const Divider(height: 1),
                _buildTile(context, item),
              ],
          ],
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, CodeHistoryItem item) {
    return Dismissible(
      key: ValueKey(item.value),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => _delete(context, item.value),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(
          item.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          item.usedAt
              .toLocal()
              .toIso8601String()
              .replaceFirst('T', ' ')
              .split('.')
              .first,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: AppStrings.historyDelete,
          onPressed: () => _delete(context, item.value),
        ),
        onTap: () => _select(item.value),
      ),
    );
  }
}
