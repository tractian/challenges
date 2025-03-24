import 'package:flutter/material.dart';

import '../models/tree_node.dart';

class TreeNodeWidget extends StatelessWidget {
  final Map<String?, List> hierarchy;
  final String? parentId;
  final int level;
  final int index;
  final Map<String, TreeNode> nodeMap;
  final Function(String) onToggleExpansion;

  const TreeNodeWidget({
    super.key,
    required this.hierarchy,
    required this.parentId,
    required this.level,
    required this.index,
    required this.nodeMap,
    required this.onToggleExpansion,
  });

  @override
  Widget build(BuildContext context) {
    if (!hierarchy.containsKey(parentId)) {
      return const SizedBox.shrink();
    }
    if (index < 0 || index >= hierarchy[parentId]!.length) {
      return const SizedBox.shrink();
    }

    final nodeData = hierarchy[parentId]![index];
    final nodeId = nodeData['id'] as String?;
    final node = nodeMap[nodeId ?? ''];
    final hasChildren =
        nodeData['children'] != null &&
        (nodeData['children'] as List).isNotEmpty;
    final isLastChild = index == hierarchy[parentId]!.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: level * 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linhas verticais da hierarquia
              if (level > 0) ...[
                SizedBox(
                  width: 24.0,
                  child: Stack(
                    children: [
                      // Linha vertical
                      Positioned(
                        left: 11.5,
                        top: 0,
                        bottom: 0,
                        child: Container(width: 1, color: Colors.grey[300]),
                      ),
                      // Linha horizontal
                      if (!isLastChild)
                        Positioned(
                          left: 11.5,
                          top: 20,
                          right: 0,
                          child: Container(height: 1, color: Colors.grey[300]),
                        ),
                    ],
                  ),
                ),
              ],
              // Ícone de expansão
              if (hasChildren)
                ValueListenableBuilder<bool>(
                  valueListenable:
                      node?.expansionNotifier ?? ValueNotifier<bool>(false),
                  builder: (context, isExpanded, child) {
                    return IconButton(
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        if (nodeId != null) {
                          onToggleExpansion(nodeId);
                        }
                      },
                    );
                  },
                )
              else
                SizedBox(width: 40),
              // Conteúdo do nó
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    nodeData['sensorType'] != null
                        ? Icons.sensors
                        : Icons.precision_manufacturing,
                    color: Colors.blue,
                  ),
                  title: Text(
                    nodeData['name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle:
                      nodeData['description'] != null
                          ? Text(
                            nodeData['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          )
                          : null,
                ),
              ),
            ],
          ),
        ),
        if (node?.isExpanded ??
            false && nodeId != null && hierarchy[nodeId] != null)
          ...hierarchy[nodeId]!.asMap().entries.map(
            (entry) => TreeNodeWidget(
              hierarchy: hierarchy,
              parentId: nodeId,
              level: level + 1,
              index: entry.key,
              nodeMap: nodeMap,
              onToggleExpansion: onToggleExpansion,
            ),
          ),
      ],
    );
  }
}
