/**
 * Calcula o caminho mais rápido usando Dijkstra e ATUALIZA a lista global
 * 'caminhoDosBaloes' que os balões seguem.
 * Retorna true se um caminho foi encontrado e atualizado com sucesso,
 * e false se o caminho estiver bloqueado.
 */
boolean atualizarCaminhoDosBaloes() {
  // Garante que o algoritmo conheça os vizinhos de cada nó (considerando novos obstáculos)
  grid.addNeighbors();
  
  // Roda o Dijkstra para encontrar a lista de nós do caminho mais rápido
  ArrayList<Node> caminhoEncontrado = dijkstra(startNode, endNode);
  
  // Verifica se um caminho foi realmente encontrado
  if (caminhoEncontrado != null) {
    // Sucesso! Vamos converter os nós em coordenadas para os balões
    
    // 1. Inicializa (ou limpa) a lista global.
    caminhoDosBaloes = new ArrayList<PVector>();
    
    // 2. Itera sobre cada nó do caminho encontrado
    for (Node n : caminhoEncontrado) {
      // 3. Converte a posição do nó (grid) para uma posição em pixels (centro da célula)
      PVector coordenada = new PVector(n.x * cellSize + cellSize / 2, n.y * cellSize + cellSize / 2);
      
      // 4. Adiciona a coordenada à lista que os balões seguirão
      caminhoDosBaloes.add(coordenada);
    }
    
    return true; // Caminho encontrado e atualizado com sucesso!
    
  } else {
    // Falha! O caminho está bloqueado.
    // Opcional: Limpar o caminho antigo para que os balões parem.
    if (caminhoDosBaloes != null) {
        caminhoDosBaloes.clear();
    }
    return false; // Caminho não encontrado.
  }
}

/**
 * Calcula o caminho mais RÁPIDO (menor custo) entre dois nós usando Dijkstra.
 * Verifica se um nó possui um "impecilho" (obstaculoVariant != null)
 * para atribuir um custo dobrado (2.0f) àquele movimento.
 */
ArrayList<Node> dijkstra(Node start, Node end) {
  PriorityQueue<Node> openSet = new PriorityQueue<Node>();
  
  // Reseta os nós do grid para um novo cálculo
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

    // Se chegamos ao fim, reconstruímos e retornamos o caminho
    if (current == end) {
      ArrayList<Node> finalPath = new ArrayList<Node>();
      Node temp = current;
      while (temp != null) {
        finalPath.add(0, temp); // Adiciona no início para inverter a ordem
        temp = temp.predecessor;
      }
      return finalPath;
    }
    
    // Itera sobre os vizinhos do nó atual
    for (Node neighbor : current.neighbors) {
      // Define o custo para se mover para o nó vizinho.
      float cost = 1.0f; // Custo padrão para qualquer tile.
      
      // Se o nó vizinho tiver uma decoração de impecilho...
      if (neighbor.obstaculoVariant != null ) {
        cost = 3.5f; // ...o custo para entrar nele é dobrado!
      } else if (neighbor.tileType == Node.GRAMA) {
        cost = 2.5f;
      } else if (neighbor.tileType == Node.OBSTACULO) {
        cost = 1000000f;
      }
      // -----------------------------

      // Calcula a nova distância (distância até o nó atual + custo para o vizinho)
      float newDistance = current.distance + cost;
      
      // Se encontramos um caminho mais barato para o vizinho...
      if (newDistance < neighbor.distance) {
        neighbor.distance = newDistance; // ...atualizamos sua distância
        neighbor.predecessor = current;  // ...definimos o predecessor
        
        // Adiciona o vizinho à fila de prioridade se ele não estiver lá
        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
        }
      }
    }
  }
  
  // Se o loop terminar e não tivermos chegado ao fim, não há caminho
  return null;
}


/**
 * Configura o layout inicial do mapa, desenhando uma estrutura de caminho
 * com uma bifurcação. Esta função cria apenas o traçado "limpo", sem adicionar
 * impecilhos ou obstáculos.
 * * Elementos dinâmicos (torres, impecilhos) devem ser adicionados pela
 * lógica do jogo, e a função `atualizarCaminhoDosBaloes()` deve ser chamada
 * após cada mudança para recalcular a rota ótima.
 */
void criarMapaComBifurcacao() {
  // PASSO 1: Limpa o grid e prepara para o desenho do novo caminho.
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid.nodes[i][j].tileType = Node.GRAMA;
      grid.nodes[i][j].obstaculoVariant = null; // Limpa impecilhos de um jogo anterior
    }
  }

  // --- Ponto de partida ---
  int currentX = 0;
  int currentY = rows / 2;
  grid.nodes[currentX][currentY].tileType = Node.CAMINHO;

  // --- Trecho Comum (antes da bifurcação) ---
  // 3 para direita
  for (int i = 0; i < 3; i++) {
    currentX++;
    if (currentX < cols) grid.nodes[currentX][currentY].tileType = Node.CAMINHO;
  }
  // 2 para baixo
  for (int i = 0; i < 2; i++) {
    currentY++;
    if (currentY < rows) grid.nodes[currentX][currentY].tileType = Node.CAMINHO;
  }
  // 2 para direita
  for (int i = 0; i < 2; i++) {
    currentX++;
    if (currentX < cols) grid.nodes[currentX][currentY].tileType = Node.CAMINHO;
  }
  // 5 para cima
  for (int i = 0; i < 5; i++) {
    currentY--;
    if (currentY >= 0) grid.nodes[currentX][currentY].tileType = Node.CAMINHO;
  }
  // 4 para direita
  for (int i = 0; i < 4; i++) {
    currentX++;
    if (currentX < cols) grid.nodes[currentX][currentY].tileType = Node.CAMINHO;
  }
  // 1 para cima
  currentY--;
  if (currentY >= 0) grid.nodes[currentX][currentY].tileType = Node.CAMINHO;
  // 3 para direita
  for (int i = 0; i < 3; i++) {
    currentX++;
    if (currentX < cols) grid.nodes[currentX][currentY].tileType = Node.CAMINHO;
  }
  // 6 para baixo
  for (int i = 0; i < 6; i++) {
    currentY++;
    if (currentY < rows) grid.nodes[currentX][currentY].tileType = Node.CAMINHO;
  }

  // --- Ponto da Bifurcação ---
  int forkX = currentX;
  int forkY = currentY;

  // --- Ramo A (Caminho superior) ---
  int currentX_A = forkX;
  int currentY_A = forkY;
  // 6 para direita
  for (int i = 0; i < 6; i++) {
    currentX_A++;
    if (currentX_A < cols) grid.nodes[currentX_A][currentY_A].tileType = Node.CAMINHO;
  }
  // 5 para cima
  for (int i = 0; i < 5; i++) {
    currentY_A--;
    if (currentY_A >= 0) grid.nodes[currentX_A][currentY_A].tileType = Node.CAMINHO;
  }
  // 2 para direita
  for (int i = 0; i < 2; i++) {
    currentX_A++;
    if (currentX_A < cols) grid.nodes[currentX_A][currentY_A].tileType = Node.CAMINHO;
  }
  // 2 para baixo
  for (int i = 0; i < 2; i++) {
    currentY_A++;
    if (currentY_A < rows) grid.nodes[currentX_A][currentY_A].tileType = Node.CAMINHO;
  }
  // 4 para direita
  for (int i = 0; i < 4; i++) {
    currentX_A++;
    if (currentX_A < cols) grid.nodes[currentX_A][currentY_A].tileType = Node.CAMINHO;
  }

  // --- Ramo B (Caminho inferior) ---
  int currentX_B = forkX;
  int currentY_B = forkY;
  // 4 para baixo
  for (int i = 0; i < 4; i++) {
    currentY_B++;
    if (currentY_B < rows) grid.nodes[currentX_B][currentY_B].tileType = Node.CAMINHO;
  }
  // 12 para direita
  for (int i = 0; i < 12; i++) {
    currentX_B++;
    if (currentX_B < cols) grid.nodes[currentX_B][currentY_B].tileType = Node.CAMINHO;
  }
  // Sobe para encontrar o final do Ramo A
  while(currentY_B > currentY_A){
    currentY_B--;
    grid.nodes[currentX_B - 1][currentY_B].tileType = Node.CAMINHO;
  }

  // --- PASSO 2: Definir os nós de início e fim globais. ---
  startNode = grid.nodes[0][rows / 2];
  endNode = grid.nodes[currentX_A - 1][currentY_A];
}
