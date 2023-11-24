import 'package:wdm_simulation/link.dart';

class Node {
  final List<Link> links;
  final List<Node> pairs;

  const Node({
    required this.links,
    required this.pairs,
  });
}
