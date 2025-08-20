// A classe Node agora gerencia seu próprio tipo e desenho
class Node implements Comparable<Node> {
  // Tipos de Tile (usando constantes inteiras)
  static final int GRAMA = 0;
  static final int CAMINHO = 1;
  static final int OBSTACULO = 2;
  
  int tileType = GRAMA; // Por padrão, todo nó é grama
  
  Grid parentGrid;
  int x, y; // Posição no grid
  ArrayList<Node> neighbors;

  // Propriedades para o Dijkstra
  float distance = Float.POSITIVE_INFINITY;
  Node predecessor = null;

  Node(int x_, int y_, Grid g) {
    x = x_;
    y = y_;
    parentGrid = g;
    neighbors = new ArrayList<Node>();
  }
  
  @Override
  int compareTo(Node other) {
    return Float.compare(this.distance, other.distance);
  }

  // Encontra os vizinhos válidos
  void findNeighbors() {
    // Vizinho da direita
    if (x < parentGrid.cols - 1) {
      Node neighbor = parentGrid.nodes[x + 1][y];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
    // Vizinho da esquerda
    if (x > 0) {
      Node neighbor = parentGrid.nodes[x - 1][y];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
    // Vizinho de baixo
    if (y < parentGrid.rows - 1) {
      Node neighbor = parentGrid.nodes[x][y + 1];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
    // Vizinho de cima
    if (y > 0) {
      Node neighbor = parentGrid.nodes[x][y - 1];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
  }

  // A NOVA LÓGICA DE DESENHO COM AUTO-TILING
  void drawNode() {
    PImage spriteToDraw = null;
    
    // Lógica para decidir qual sprite usar
    // Esta é uma versão simplificada. A lógica completa de auto-tiling
    // precisaria verificar os 8 vizinhos para desenhar todas as quinas.
    
    if (tileType == OBSTACULO) {
      // Se for um obstáculo, sempre desenha grama por baixo e o sprite por cima
      image(tileset.get("GRAMA"), x * cellSize, y * cellSize, cellSize, cellSize);
      spriteToDraw = tileset.get("OBSTACULO");
    } 
    else if (tileType == CAMINHO) {
      spriteToDraw = tileset.get("CAMINHO");
    } 
    else if (tileType == GRAMA) {
      // AQUI ENTRA A LÓGICA DE AUTO-TILING
      // Por enquanto, apenas desenha grama. A lógica completa seria bem complexa,
      // verificando o 'tileType' de cada vizinho para escolher um sprite de borda.
      spriteToDraw = tileset.get("GRAMA");
    }

    // Desenha o sprite escolhido
    if (spriteToDraw != null) {
      image(spriteToDraw, x * cellSize, y * cellSize, cellSize, cellSize);
    } else {
      // Fallback para um retângulo colorido se o sprite não for encontrado
      fill(255, 0, 255); // Cor de erro (magenta)
      noStroke();
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }
  }
}
