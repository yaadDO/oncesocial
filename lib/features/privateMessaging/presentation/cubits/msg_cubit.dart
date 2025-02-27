import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repo.dart';


part 'msg_state.dart';

class MsgCubit extends Cubit<MsgState> {
  final MsgRepo msgRepo;
  StreamSubscription? _messagesSubscription;

  MsgCubit({required this.msgRepo}) : super(MsgInitial());

  void loadMessages(String chatRoomId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = msgRepo.getMessages(chatRoomId).listen(
          (messages) {
        emit(MsgLoaded(messages.cast<MessagePrivate>()));
      },
      onError: (error) => emit(MsgError(error.toString())),
    );
  }

  void sendMessage(MessagePrivate messagepriv) async {
    try {
      await msgRepo.sendMessage(messagepriv);
    } catch (e) {
      emit(MsgError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }

  void deleteMessage(String messageId) async {
    try {
      await msgRepo.deleteMessage(messageId);
    } catch (e) {
      emit(MsgError(e.toString()));
    }
  }
}

