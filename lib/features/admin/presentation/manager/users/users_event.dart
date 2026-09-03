part of 'users_bloc.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();
}
class GetAllUser extends UsersEvent
{
  @override

  List<Object?> get props => [];


}
class DeleteUserEvent extends UsersEvent{
  final int userId ;

 const DeleteUserEvent({required this.userId});

  @override
  // TODO: implement props
  List<Object?> get props => [userId];
}