import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:wdm_simulation/link.dart';
import 'package:wdm_simulation/node.dart' as nd;
import 'package:wdm_simulation/map_topology.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({Key? key}) : super(key: key);

  @override
  _SimulationScreenState createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Topology',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 48),
          ),
          Text(
            'Number of Nodes: ${topologyData['nodes']?.map((e) => e).toList().length}',
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          ),
          Text(
            'Number of Edges: ${topologyData['edges']?.map((e) => e).toList().length}',
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              color: Colors.grey,
              child: InteractiveViewer(
                constrained: false,
                boundaryMargin: EdgeInsets.all(100),
                minScale: 0.01,
                maxScale: 0.5,
                child: GraphView(
                  graph: graph,
                  algorithm: FruchtermanReingoldAlgorithm(
                      attractionRate: 0, repulsionPercentage: 0.1),
                  paint: Paint()
                    ..color = Colors.green
                    ..strokeWidth = 10
                    ..strokeCap = StrokeCap.round
                    ..style = PaintingStyle.stroke,
                  builder: (Node node) {
                    // I can decide what widget should be shown here based on the id
                    var a = node.key?.value as int;
                    return rectangleWidget(a);
                  },
                ),
              ),
            ),
          ),
          const Text(
            'Topology',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 48),
          ),
        ],
      ),
    ));
  }

  Random r = Random();

  Widget rectangleWidget(int a) {
    return InkWell(
      onTap: () {
        print('clicked');
      },
      child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
            boxShadow: [
              BoxShadow(color: Colors.cyanAccent, spreadRadius: 1),
            ],
          ),
          child: Text('Node $a')),
    );
  }

  final Graph graph = Graph()..isTree = false;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  SugiyamaConfiguration builder2 = SugiyamaConfiguration();
  late Edge a;

  List<Link> linksData = [];
  List<nd.Node> nodesData = [];

  @override
  void initState() {
    super.initState();

    List<Map<String, dynamic>> edges =
        topologyData['edges']!.map((e) => e).toList();
    List<Map<String, dynamic>> nodes =
        topologyData['nodes']!.map((e) => e).toList();

    // initiate Nodes
    for (var element in nodes) {
      var fromNodeId = element['id'];
      graph.addNode(Node.Id(fromNodeId));
      nd.Node n = nd.Node(
        id: fromNodeId,
        pairs: [],
        links: [],
      );
      nodesData.add(n);
    }

    // initiate Links
    for (var element in edges) {
      var pairNodeId = element['pair_node'];
      var linkId = element['id'];
      var baseNodeId = element['base_node'];
      graph.addEdge(Node.Id(pairNodeId), Node.Id(baseNodeId));
      Link l = Link(
        baseNode: baseNodeId,
        pairNode: pairNodeId,
        id: linkId,
      );
      linksData.add(l);
    }

    // rearrange the nodes
    // - input node links
    var nodeIndex = 0;
    for (var node in nodesData) {
      List<Link> links = [];
      for (var link in linksData) {
        if (node.id == link.pairNode || node.id == link.baseNode) {
          links.add(link);
          var a = node.copyWith(links: links);
          nodesData[nodeIndex] = a;
        }
      }
      nodeIndex += 1;
    }

    // - input the node nodes
    for (var node in nodesData) {
      if (node.links!.isNotEmpty) {
        for (var link in node.links!) {
          if (link.pairNode == node.id) {
            node.pairs!.add(link.baseNode);
          } else if (link.baseNode == node.id) {
            node.pairs!.add(link.pairNode);
          }
        }
      }
    }

    for (var y in nodesData) {
      print(y.id.toString() +
          ' ' +
          y.links.toString() +
          ' ' +
          y.pairs.toString());
    }

    print(nodesData.first.links!.length);
    print(nodesData.first.pairs!.length);
  }

  void changeColor() async {
    var isBlue = false;
    Timer.periodic(const Duration(milliseconds: 750), (timer) {
      a.paint = Paint()..color = isBlue ? Colors.blue : Colors.red;
      isBlue = !isBlue;
      setState(() {});
    });
  }
}
