import 'package:flutter/foundation.dart';

/// Modelo que representa um nó na árvore de ativos.
///
/// Este modelo implementa uma estrutura de árvore n-ária (cada nó pode ter múltiplos filhos)
/// com as seguintes características:
///
/// 1. Identificador único
/// 2. Dados do ativo
/// 3. Lista de filhos
/// 4. Referência ao nó pai
/// 5. Estado de expansão
/// 6. Notificador para mudanças no estado de expansão
///
/// A estrutura é otimizada para:
/// - Adição e remoção eficiente de filhos
/// - Atualização do estado de expansão
/// - Navegação bidirecional (pai -> filhos)
class TreeNode {
  /// Identificador único do nó
  final String id;

  /// Dados do ativo associado ao nó
  final Map<String, dynamic> data;

  /// Lista de nós filhos
  final List<TreeNode> children;

  /// Referência ao nó pai
  TreeNode? parent;

  /// Estado de expansão do nó
  bool _isExpanded = false;

  /// Notificador para mudanças no estado de expansão
  final ValueNotifier<bool> expansionNotifier = ValueNotifier<bool>(false);

  /// Construtor do nó.
  ///
  /// [id] - Identificador único do nó
  /// [data] - Dados do ativo associado ao nó
  /// [children] - Lista de filhos do nó
  TreeNode({required this.id, required this.data, List<TreeNode>? children})
    : children = children ?? [];

  /// Retorna o estado de expansão do nó.
  bool get isExpanded => _isExpanded;

  /// Define o estado de expansão do nó.
  ///
  /// [value] - Novo estado de expansão
  ///
  /// Atualiza o estado e notifica os ouvintes.
  void setExpanded(bool value) {
    _isExpanded = value;
    expansionNotifier.value = value;
  }

  /// Adiciona um nó filho.
  ///
  /// [child] - Nó filho a ser adicionado
  ///
  /// Atualiza as referências bidirecionais (pai -> filho).
  void addChild(TreeNode child) {
    children.add(child);
    child.parent = this;
  }

  /// Remove um nó filho.
  ///
  /// [child] - Nó filho a ser removido
  ///
  /// Atualiza as referências bidirecionais (pai -> filho).
  void removeChild(TreeNode child) {
    children.remove(child);
    if (child.parent == this) {
      child.parent = null;
    }
  }

  /// Libera os recursos do nó.
  ///
  /// Deve ser chamado quando o nó não for mais necessário.
  void dispose() {
    expansionNotifier.dispose();
  }

  bool get hasChildren => children.isNotEmpty;
  bool get isRoot => parent == null;
  int get depth {
    int count = 0;
    var current = parent;
    while (current != null) {
      count++;
      current = current.parent;
    }
    return count;
  }
}
