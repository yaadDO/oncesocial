import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/message.dart';
import '../../domain/repos/chat_repo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepo;

  ChatCubit({required this.chatRepo}) : super(ChatInitial());

  Stream<List<Message>> getMessagesStream() {
    return chatRepo.getMessages();
  }

  void sendMessage(String text) async {
    try {
      await chatRepo.sendMessage(text);
    } catch (e) {
      emit(ChatError('Failed to send message: ${e.toString()}'));
    }
  }

  void deleteMessage(String messageId) async {
    try {
      await chatRepo.deleteMessage(messageId);
    } catch (e) {
      emit(ChatError('Failed to delete message: ${e.toString()}'));
    }
  }
}