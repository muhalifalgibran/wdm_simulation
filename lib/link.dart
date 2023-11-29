import 'package:equatable/equatable.dart';
import 'package:wdm_simulation/node.dart';

class Link extends Equatable {
  final int baseNode, pairNode;
  final int id;

  const Link({
    required this.id,
    required this.baseNode,
    required this.pairNode,
  });

  @override
  List<Object?> get props => [
        id,
        baseNode,
        pairNode,
      ];
}
