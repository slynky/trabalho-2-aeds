
/**
 * VERIFICA se ainda existe um caminho válido entre o início e o fim.
 * Não altera mais o estado visual do mapa. Apenas retorna true ou false.
 * Usada para checar se a colocação de uma torre bloqueia o caminho.
 */
boolean atualizarCaminhoDosBaloes() {
  // Garante que o algoritmo conheça os vizinhos de cada nó (considerando novos obstáculos)
  grid.addNeighbors();
  
  // Roda o Dijkstra para ver se um caminho QUALQUER ainda pode ser encontrado
  ArrayList<Node> caminhoEncontrado = dijkstra(startNode, endNode);
  
  // Retorna true se um caminho foi encontrado, false caso contrário.
  return caminhoEncontrado != null;
}

ArrayList<Node> dijkstra(Node start, Node end) {
  PriorityQueue<Node> openSet = new PriorityQueue<Node>();
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid.nodes[i][j].distance = Float.POSITIVE_INFINITY;
      grid.nodes[i][j].predecessor = null;
    }
  }
  
  start.distance = 0;
  openSet.add(start);
  
  while (!openSet.isEmpty()) {
    Node current = openSet.poll();
    if (current == end) {
      ArrayList<Node> finalPath = new ArrayList<Node>();
      Node temp = current;
      while (temp != null) {
        finalPath.add(0, temp);
        temp = temp.predecessor;
      }
      return finalPath;
    }
    
    for (Node neighbor : current.neighbors) {
      float newDistance = current.distance + 1;
      if (newDistance < neighbor.distance) {
        neighbor.distance = newDistance;
        neighbor.predecessor = current;
        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
        }
      }
    }
  }
  return null;
}


/**
 * Cria um caminho pré-definido manualmente, ignorando o Dijkstra na inicialização.
 * Segue as instruções de movimento para marcar as células do grid como 'CAMINHO'.
 */
void criarCaminhoManualmente() {
  // Limpa o caminho antigo para garantir
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid.nodes[i][j].tileType = Node.GRAMA;
    }
  }

  // Lista temporária para guardar os nós do caminho na ordem correta
  ArrayList<Node> nodesDoCaminho = new ArrayList<Node>();

  // Ponto de partida
  int currentX = 0;
  int currentY = rows / 2; // Começa no meio da borda esquerda

  // Adiciona o ponto de partida
  nodesDoCaminho.add(grid.nodes[currentX][currentY]);

  // Sequência de movimentos para desenhar o caminho
  // Cada loop corresponde a uma das suas instruções.
  
  // 3 para direita
  for (int i = 0; i < 3; i++) {
    currentX++;
    if (currentX < cols) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }
  // 2 para baixo
  for (int i = 0; i < 2; i++) {
    currentY++;
    if (currentY < rows) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }
  // 2 para direita
    for (int i = 0; i < 2; i++) {
  currentX++;
  if (currentX < cols) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
   }
  // 5 para cima
  for (int i = 0; i < 5; i++) {
    currentY--;
    if (currentY >= 0) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }
  // 4 para direita
  for (int i = 0; i < 4; i++) {
    currentX++;
    if (currentX < cols) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }
  // 1 para cima
  currentY--;
  if (currentY >= 0) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  
  // 3 para direita
  for (int i = 0; i < 3; i++) {
    currentX++;
    if (currentX < cols) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }
  // 6 para baixo
  for (int i = 0; i < 6; i++) {
    currentY++;
    if (currentY < rows) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }
  // 6 para direita
  for (int i = 0; i < 6; i++) {
    currentX++;
    if (currentX < cols) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }
  // 5 para cima
  for (int i = 0; i < 5; i++) {
    currentY--;
    if (currentY >= 0) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }
  // 2 para direita
  for (int i = 0; i < 2; i++) {
    currentX++;
    if (currentX < cols) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }
  // 2 para baixo
  for (int i = 0; i < 2; i++) {
    currentY++;
    if (currentY < rows) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }
  // 4 para direita
  for (int i = 0; i < 4; i++) {
    currentX++;
    if (currentX < cols) nodesDoCaminho.add(grid.nodes[currentX][currentY]);
  }

  // Agora, com a lista de nós pronta, atualiza o jogo
  caminhoDosBaloes = new ArrayList<PVector>();
  for (Node n : nodesDoCaminho) {
    n.tileType = Node.CAMINHO; // Marca o nó como parte do caminho
    // Adiciona a coordenada em pixels para os balões seguirem
    caminhoDosBaloes.add(new PVector(n.x * cellSize + cellSize/2, n.y * cellSize + cellSize/2));
  }
  
  // Define os nós de início e fim globais com base no caminho criado
  if (!nodesDoCaminho.isEmpty()) {
    startNode = nodesDoCaminho.get(0);
    endNode = nodesDoCaminho.get(nodesDoCaminho.size() - 1);
  }
}
