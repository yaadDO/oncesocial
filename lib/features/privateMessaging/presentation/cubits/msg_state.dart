part of 'msg_cubit.dart';

@immutable
sealed class MsgState {}

final class MsgInitial extends MsgState {}

final class MsgLoaded extends MsgState {
  final List<MessagePrivate> messagesPrivate;
  MsgLoaded(this.messagesPrivate);
}

final class MsgError extends MsgState {
  final String error;
  MsgError(this.error);
}