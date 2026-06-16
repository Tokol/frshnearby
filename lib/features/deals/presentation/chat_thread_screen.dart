import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/loading_state.dart';
import 'deal_controller.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({required this.threadId, super.key});

  final String threadId;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messages = ref.watch(chatMessagesProvider(widget.threadId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatTitle)),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () => LoadingState(message: l10n.loadingMessage),
              error: (_, _) => Center(child: Text(l10n.genericErrorMessage)),
              data: (items) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final message = items[index];
                  return Align(
                    alignment: message.senderId == 'system'
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(message.text),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(labelText: l10n.messageLabel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    label: l10n.sendButton,
                    onPressed: () {
                      ref
                          .read(dealControllerProvider.notifier)
                          .sendMessage(
                            threadId: widget.threadId,
                            text: _messageController.text,
                          );
                      _messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
