import '../entities/message.dart';

abstract class MsgRepo {
  Future<void> sendMessage(MessagePrivate message);
  Stream<List<MessagePrivate>> getMessages(String chatRoomId);
  Future<void> deleteMessage(String messageId);
}