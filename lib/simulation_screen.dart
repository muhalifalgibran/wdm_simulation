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
          Wrap(
            alignment: WrapAlignment.start,
            children: [
              // Container(
              //   width: 100,
              //   child: TextFormField(
              //     initialValue: builder.siblingSeparation.toString(),
              //     decoration: InputDecoration(labelText: "Sibling Separation"),
              //     onChanged: (text) {
              //       builder.siblingSeparation = int.tryParse(text) ?? 100;
              //       setState(() {});
              //     },
              //   ),
              // ),
              // Container(
              //   width: 100,
              //   child: TextFormField(
              //     initialValue: builder.levelSeparation.toString(),
              //     decoration: InputDecoration(labelText: "Level Separation"),
              //     onChanged: (text) {
              //       builder.levelSeparation = int.tryParse(text) ?? 100;
              //       setState(() {});
              //     },
              //   ),
              // ),
              // Container(
              //   width: 100,
              //   child: TextFormField(
              //     initialValue: builder.subtreeSeparation.toString(),
              //     decoration: InputDecoration(labelText: "Subtree separation"),
              //     onChanged: (text) {
              //       builder.subtreeSeparation = int.tryParse(text) ?? 100;
              //       setState(() {});
              //     },
              //   ),
              // ),
              // Container(
              //   width: 100,
              //   child: TextFormField(
              //     initialValue: builder.orientation.toString(),
              //     decoration: InputDecoration(labelText: "Orientation"),
              //     onChanged: (text) {
              //       builder.orientation = int.tryParse(text) ?? 100;
              //       setState(() {});
              //     },
              //   ),
              // ),
              // ElevatedButton(
              //   onPressed: () {
              //     final node12 = Node.Id(r.nextInt(100));
              //     var edge =
              //         graph.getNodeAtPosition(r.nextInt(graph.nodeCount()));
              //     print(edge);
              //     graph.addEdge(edge, node12);
              //     setState(() {});
              //   },
              //   child: Text("Add"),
              // )
            ],
          ),
          const Text(
            'Topology',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 48),
          ),
          Text(
            'Number of Nodes: ${topologyData['nodes']?.map((e) => e).toList().length}',
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          ),
          Text(
            'Number of Edge: ${topologyData['edges']?.map((e) => e).toList().length}',
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
          Text(
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
      Link l = Link(baseNode: pairNodeId, pairNode: baseNodeId, id: linkId);
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

    for (var y in nodesData) {
      print(y.id.toString() +
          ' ' +
          y.links.toString() +
          ' ' +
          y.pairs.toString());
    }
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
