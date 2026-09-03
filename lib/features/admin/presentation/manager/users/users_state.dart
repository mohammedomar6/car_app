part of 'users_bloc.dart';

enum UsersStatus {
  initial,
  loading,
  success,
  failure,
}

class UsersState extends Equatable {
  final UsersStatus status;
  final UsersStatus deleteStatus;
  final List<ProfileResponseModel> users;
  final String message;
  final MassageModel? massageModel ;

  const UsersState( {
    this.deleteStatus = UsersStatus.initial,
    this.status = UsersStatus.initial,
    this.users = const [],
    this.message = '',
     this.massageModel ,
  });

  UsersState copyWith({
    UsersStatus? status,
    UsersStatus? deleteStatus,
    List<ProfileResponseModel>? users,
    String? message,
    MassageModel? massageModel ,
  }) {
    return UsersState(
      deleteStatus: deleteStatus ?? this.deleteStatus ,
      massageModel: massageModel?? this.massageModel,
      status: status ?? this.status,
      users: users ?? this.users,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    users,
    message,
    deleteStatus,

  ];
}