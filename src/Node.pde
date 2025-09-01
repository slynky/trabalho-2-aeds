import java.util.Random;

/**
 * Representa uma única célula (tile) no grid do mapa.
 * Impecilhos são tratados como decorações sobrepostas.
 */
class Node implements Comparable<Node> {
  // --- Constantes de Tipo de Tile ---
  static final int GRAMA = 0;
  static final int CAMINHO = 1;
  static final int OBSTACULO = 2; // Para torres que bloqueiam o caminho
  
  // --- Atributos Visuais ---
  String obstaculoVariant = null; // Guarda o sprite da decoração (impecilho)
  
  final String[] VARIANTS_GRAMA = { 
    "GRAMA_PRINCIPAL", 
    "GRAMA",
    "GRAMA_FLORIDA",
    "GRAMA_BRANCA", 
    "GRAMA_BRANCA_2", 
    "GRAMA_FLOR", 
    "GRAMA_PEDRA"
  };
  int tileType = GRAMA;
  int gramaVariant = 0;
  
  // --- Atributos de Posição e Estrutura ---
  int x;
  int y;
  Grid parentGrid;
  
  // --- Atributos para Pathfinding (Dijkstra) ---
  ArrayList<Node> neighbors;
  float distance = Float.POSITIVE_INFINITY;
  Node predecessor = null;

  Node(int x_, int y_, Grid g) {
    this.x = x_;
    this.y = y_;
    this.parentGrid = g;
    this.neighbors = new ArrayList<Node>();
  }
  
  void findNeighbors() {
    neighbors.clear();
    // A lógica de encontrar vizinhos não muda. 
    // Impecilhos não afetam o tileType, então o pathfinding já os ignora.
    if (x < parentGrid.cols - 1) {
      Node neighbor = parentGrid.nodes[x + 1][y];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
    if (x > 0) {
      Node neighbor = parentGrid.nodes[x - 1][y];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
    if (y < parentGrid.rows - 1) {
      Node neighbor = parentGrid.nodes[x][y + 1];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
    if (y > 0) {
      Node neighbor = parentGrid.nodes[x][y - 1];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
  }
  
  @Override
  int compareTo(Node other) {
    return Float.compare(this.distance, other.distance);
  }

  /**
   * Desenha a célula em camadas para permitir que impecilhos
   * fiquem por cima do caminho.
   */
  void drawNode() {
    float drawX = x * cellSize + cellSize/2;
    float drawY = y * cellSize + cellSize/2;

    // --- Passo 1: Desenha a base de grama por baixo de tudo ---
    String chaveDaGrama = VARIANTS_GRAMA[gramaVariant];
    image(tileset.get(chaveDaGrama), drawX, drawY, cellSize, cellSize);

    // --- Passo 2: Desenha o caminho (se for um tile de caminho) ---
    if (tileType == CAMINHO) {
      boolean vizinhoCima = (y > 0 && parentGrid.nodes[x][y-1].tileType == CAMINHO);
      boolean vizinhoBaixo = (y < parentGrid.rows - 1 && parentGrid.nodes[x][y+1].tileType == CAMINHO);
      boolean vizinhoEsq = (x > 0 && parentGrid.nodes[x-1][y].tileType == CAMINHO);
      boolean vizinhoDir = (x < parentGrid.cols - 1 && parentGrid.nodes[x+1][y].tileType == CAMINHO);
      
      String chaveDoCaminho = "CAMINHO_HORIZONTAL"; // Padrão
      if (vizinhoCima && vizinhoBaixo) { chaveDoCaminho = "CAMINHO_VERTICAL"; }
      else if (vizinhoEsq && vizinhoDir) { chaveDoCaminho = "CAMINHO_HORIZONTAL"; }
      else if (vizinhoBaixo && vizinhoDir) { chaveDoCaminho = "CURVA_CIMA_ESQUERDA"; }
      else if (vizinhoBaixo && vizinhoEsq) { chaveDoCaminho = "CURVA_CIMA_DIREITA"; }
      else if (vizinhoCima && vizinhoDir) { chaveDoCaminho = "CURVA_BAIXO_ESQUERDA"; }
      else if (vizinhoCima && vizinhoEsq) { chaveDoCaminho = "CURVA_BAIXO_DIREITA"; }
      image(tileset.get(chaveDoCaminho), drawX, drawY, cellSize, cellSize);
    }
    
    // --- Passo 3: Desenha a decoração (impecilho) por cima, se existir ---
    if (this.obstaculoVariant != null) {
        image(tileset.get(this.obstaculoVariant), drawX, drawY, cellSize, cellSize);
    }
    
    // --- Passo 4: Desenha a entrada e a saída (sempre por cima de tudo) ---
    if (this == startNode) {
      image(tileset.get("ENTRADA_BALOES"), drawX, drawY, cellSize, cellSize);
    } else if (this == endNode) {
      image(tileset.get("NUCLEO_DEFENSAVEL"), drawX, drawY, cellSize, cellSize);
    }
  }
}
