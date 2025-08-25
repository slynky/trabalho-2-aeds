/**
 * Representa uma única célula (tile) no grid do mapa. Cada Node armazena sua
 * posição, tipo (grama, caminho, obstáculo) e informações necessárias
 * para o algoritmo de pathfinding Dijkstra.
 */
class Node implements Comparable<Node> {
  // --- Constantes de Tipo de Tile ---
  /** Define o tipo da célula como grama, onde torres podem ser construídas. */
  static final int GRAMA = 0;
  /** Define o tipo da célula como parte do caminho que os balões seguem. */
  static final int CAMINHO = 1;
  /** Define o tipo da célula como um obstáculo intransponível. */
  static final int OBSTACULO = 2;
  
  // --- Atributos Visuais ---
  /** Array com as chaves das diferentes imagens de grama para variação visual. */
  final String[] VARIANTS_GRAMA = { 
      "GRAMA_PRINCIPAL", 
      "GRAMA_BRANCA", 
      "GRAMA_BRANCA_2", 
      "GRAMA_FLOR", 
      "GRAMA_PEDRA"
  };
  /** Armazena o tipo atual deste Node (GRAMA, CAMINHO ou OBSTACULO). */
  int tileType = GRAMA;
  /** Armazena o índice da variante de grama a ser usada para o desenho. */
  int gramaVariant = 0;
  
  // --- Atributos de Posição e Estrutura ---
  /** A coordenada da coluna (eixo X) deste Node no grid. */
  int x;
  /** A coordenada da linha (eixo Y) deste Node no grid. */
  int y;
  /** Uma referência ao objeto Grid ao qual este Node pertence. */
  Grid parentGrid;
  
  // --- Atributos para Pathfinding (Dijkstra) ---
  /** Lista de Nodes vizinhos que são acessíveis (não são obstáculos). */
  ArrayList<Node> neighbors;
  /** A distância calculada do nó inicial até este nó. */
  float distance = Float.POSITIVE_INFINITY;
  /** O nó anterior no caminho mais curto encontrado pelo Dijkstra. */
  Node predecessor = null;

  /**
   * Construtor para criar um novo Node.
   * @param x_ A coordenada da coluna (x) do Node no grid.
   * @param y_ A coordenada da linha (y) do Node no grid.
   * @param g  A instância do Grid "pai" que contém este Node.
   */
  Node(int x_, int y_, Grid g) {
    this.x = x_;
    this.y = y_;
    this.parentGrid = g;
    this.neighbors = new ArrayList<Node>();
  }
  
  /**
   * Encontra e armazena os vizinhos diretos (cima, baixo, esquerda, direita)
   * que não são do tipo OBSTACULO. Essencial para o pathfinding.
   */
  void findNeighbors() {
    neighbors.clear(); // Limpa a lista para garantir que não haja vizinhos de um cálculo anterior.
    // Checa o vizinho da Direita
    if (x < parentGrid.cols - 1) {
      Node neighbor = parentGrid.nodes[x + 1][y];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
    // Checa o vizinho da Esquerda
    if (x > 0) {
      Node neighbor = parentGrid.nodes[x - 1][y];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
    // Checa o vizinho de Baixo
    if (y < parentGrid.rows - 1) {
      Node neighbor = parentGrid.nodes[x][y + 1];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
    // Checa o vizinho de Cima
    if (y > 0) {
      Node neighbor = parentGrid.nodes[x][y - 1];
      if (neighbor.tileType != OBSTACULO) neighbors.add(neighbor);
    }
  }
  
  /**
   * Compara este Node com outro baseado na sua distância.
   * Este método é obrigatório por causa do "implements Comparable" e é
   * usado pela PriorityQueue no algoritmo de Dijkstra para sempre
   * processar o nó com a menor distância primeiro.
   * @param other O outro Node com o qual este será comparado.
   * @return Um valor negativo se a distância deste Node for menor, 
   * zero se for igual, ou um valor positivo se for maior.
   */
  @Override
  int compareTo(Node other) {
    return Float.compare(this.distance, other.distance);
  }

  /**
   * Desenha a representação visual deste Node na tela,
   * escolhendo a imagem correta do tileset com base no seu tipo.
   */
  void drawNode() {
    PImage spriteToDraw = null;
    if (tileset != null) {
      // Se for parte do caminho, usa a imagem de caminho.
      if (tileType == CAMINHO) {
        spriteToDraw = tileset.get("CAMINHO_TERRA");
      } else { 
        // Se for GRAMA ou OBSTACULO, desenha uma variante de grama por baixo.
        // (Obstáculos visuais como árvores seriam desenhados por cima da grama em outra camada).
        String chaveDaGrama = VARIANTS_GRAMA[gramaVariant];
        spriteToDraw = tileset.get(chaveDaGrama);
      }
      
      // Se a imagem foi encontrada com sucesso, desenha na tela.
      if (spriteToDraw != null) {
        image(spriteToDraw, x * cellSize + cellSize/2, y * cellSize + cellSize/2, cellSize, cellSize);
      }
    } else {
      // Se as imagens não carregaram, desenha cores sólidas como alternativa (fallback).
      if (tileType == GRAMA) { fill(34, 139, 34); }
      else if (tileType == CAMINHO) { fill(139, 69, 19); }
      else if (tileType == OBSTACULO) { fill(100); }
      noStroke();
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }
  }
}
