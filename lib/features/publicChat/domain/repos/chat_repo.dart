import '../entities/message.dart';

abstract class ChatRepo {
  Stream<List<Message>> getMessages();
  Future<void> sendMessage(String text);
  Future<void> deleteMessage(String messageId);
}