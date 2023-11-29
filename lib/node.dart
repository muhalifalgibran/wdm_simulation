import 'package:equatable/equatable.dart';
import 'package:wdm_simulation/link.dart';

class Node extends Equatable {
  final List<Link>? links;
  final List<int>? pairs;
  final int id;

  const Node({
    required this.id,
    required this.links,
    required this.pairs,
  });

  Node copyWith({
    int? id,
    List<Link>? links,
    List<int>? pairs,
  }) =>
      Node(
        id: id ?? this.id,
        links: links ?? this.links,
        pairs: pairs ?? this.pairs,
      );

  @override
  List<Object?> get props => [
        id,
        links,
        pairs,
      ];
}
