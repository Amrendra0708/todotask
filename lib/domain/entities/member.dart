import 'package:equatable/equatable.dart';

class Member extends Equatable {
  final String id;
  final String name;

  const Member({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

