import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/features/wallet/data/wallet_controller.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class TransactionReceiptScreen extends ConsumerStatefulWidget {
  const TransactionReceiptScreen({super.key, required this.journalId});

  final String journalId;

  @override
  ConsumerState<TransactionReceiptScreen> createState() =>
      _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState
    extends ConsumerState<TransactionReceiptScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(walletControllerProvider.notifier)
            .loadJournal(widget.journalId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final state = ref.watch(walletControllerProvider);
    final journal = state.journal;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionReceiptTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ScreenStateView(
            isLoading: journal == null,
            isEmpty: false,
            error: state.error,
            onRetry: () => ref
                .read(walletControllerProvider.notifier)
                .loadJournal(widget.journalId),
            builder: (_) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 56,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.moneyMoveRecordedText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(l10n.referenceLabel),
                              const SizedBox(height: AppSpacing.xs),
                              Text(formatNPR(_walletCredit(journal!))),
                              const SizedBox(height: AppSpacing.md),
                              Text(l10n.journalIdLine(journal.id)),
                              Text(l10n.journalTypeLine(journal.kind.name)),
                              Text(l10n.journalCreatedLine(
                                journal.createdAt.toLocal(),
                              )),
                              if (state.lastReceipt?.replayed ?? false) ...[
                                const SizedBox(height: AppSpacing.sm),
                                StatusChip(
                                  label: l10n.replayedRequestChip,
                                  tone: AppTone.warning,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.ledgerEntriesTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ...journal.entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.xs,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(entry.accountId)),
                                      Text(formatNPR(entry.amountPaisa)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  /// Shows the wallet-side magnitude of the journal.
  static int _walletCredit(JournalTransaction journal) {
    for (final entry in journal.entries) {
      if (LedgerAccount.isUserWallet(entry.accountId)) {
        return entry.amountPaisa.abs();
      }
    }
    return 0;
  }
}
