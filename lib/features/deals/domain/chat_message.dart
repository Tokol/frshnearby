enum ChatSenderType { customer, farmer }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderType,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String threadId;
  final String senderId;
  final ChatSenderType senderType;
  final String text;
  final DateTime createdAt;
}
