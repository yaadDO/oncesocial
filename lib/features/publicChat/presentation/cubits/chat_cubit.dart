import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message.dart';
import '../../domain/repos/chat_repo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepo;
  StreamSubscription? _messagesSub;

  ChatCubit({required this.chatRepo}) : super(ChatInitial()) {
    _messagesSub = chatRepo.getMessages().listen((messages) {
      emit(ChatLoaded(messages));
    }, onError: (e) {
      emit(ChatError('Error loading messages: ${e.toString()}'));
    });
  }

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


  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }

  Future<void> deleteMessage(String messageId) async {
    if (state is! ChatLoaded) return;

    final originalMessages = (state as ChatLoaded).messages;
    final newMessages = originalMessages.where((m) => m.id != messageId).toList();

    // Optimistic update
    emit(ChatLoaded(newMessages));

    try {
      await chatRepo.deleteMessage(messageId);
    } catch (e) {
      // Revert on error
      emit(ChatLoaded(originalMessages));
      emit(ChatError('Delete failed: ${e.toString()}'));
    }
  }
}
