import 'package:wdm_simulation/link.dart';

class Node {
  final List<Link>? links;
  final List<Node>? pairs;
  final int id;

  const Node({
    required this.id,
    required this.links,
    required this.pairs,
  });

  Node copyWith({
    int? id,
    List<Link>? links,
    List<Node>? pairs,
  }) =>
      Node(
        id: id ?? this.id,
        links: links ?? this.links,
        pairs: pairs ?? this.pairs,
      );
}
