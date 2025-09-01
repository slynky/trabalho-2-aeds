/**
 * Representa uma única célula (tile) no grid do mapa.
 */
class Node implements Comparable<Node> {
  // --- Constantes de Tipo de Tile ---
  static final int GRAMA = 0;
  static final int CAMINHO = 1;
  static final int OBSTACULO = 2;
  static final int IMPECILIO = 3;
  // --- Atributos Visuais ---
  final String[] VARIANTS_GRAMA = { 
    "GRAMA_PRINCIPAL", 
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

  /**
   * Construtor para criar um novo Node.
   */
  Node(int x_, int y_, Grid g) {
    this.x = x_;
    this.y = y_;
    this.parentGrid = g;
    this.neighbors = new ArrayList<Node>();
  }
  
  /**
   * Encontra e armazena os vizinhos diretos.
   */
  void findNeighbors() {
    neighbors.clear();
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
  
  /**
   * Compara este Node com outro baseado na sua distância.
   */
  @Override
  int compareTo(Node other) {
    return Float.compare(this.distance, other.distance);
  }

  /**
   * Desenha a representação visual deste Node na tela,
   * usando a lógica de bordas para o tileset fornecido.
   */
  void drawNode() {
    float drawX = x * cellSize + cellSize/2;
    float drawY = y * cellSize + cellSize/2;

    // --- Passo 1: Desenha a base de grama para todos os tiles ---
    String chaveDaGrama = VARIANTS_GRAMA[gramaVariant];
    PImage gramaSprite = tileset.get(chaveDaGrama);
    if (gramaSprite != null) {
      image(gramaSprite, drawX, drawY, cellSize, cellSize);
    }

    // --- Passo 2: Desenha o caminho e suas bordas ---
    if (tileType == CAMINHO) {
      // Desenha a base de terra do caminho.
      PImage terraSprite = tileset.get(random(1) < 0.5 ? "CAMINHO_TERRA" : "CAMINHO_TERRA_2");
      if (terraSprite != null) {
        image(terraSprite, drawX, drawY, cellSize, cellSize);
      }

      // ✨ LÓGICA ATUALIZADA COM OS NOVOS SPRITES ✨
      // Desenha as bordas por cima, se o vizinho for grama.
      // Como não são 'else if', múltiplos sprites podem ser desenhados, criando os cantos.
      
      // Borda de Cima
      if (y > 0 && parentGrid.nodes[x][y-1].tileType == GRAMA) {
        image(tileset.get("CAMINHO_SUPERIOR"), drawX, drawY, cellSize, cellSize);
      }
      // Borda de Baixo
      if (y < parentGrid.rows - 1 && parentGrid.nodes[x][y+1].tileType == GRAMA) {
        // Usando o novo sprite CAMINHO_INFERIOR
        image(tileset.get("CAMINHO_INFERIOR"), drawX, drawY, cellSize, cellSize);
      }
      // Borda da Esquerda
      if (x > 0 && parentGrid.nodes[x-1][y].tileType == GRAMA) {
        image(tileset.get("CAMINHO_LATERAL_ESQUERDO"), drawX, drawY, cellSize, cellSize);
      }
      // Borda da Direita
      if (x < parentGrid.cols - 1 && parentGrid.nodes[x+1][y].tileType == GRAMA) {
        image(tileset.get("CAMINHO_LATERAL_DIREITO"), drawX, drawY, cellSize, cellSize);
      }
    }
    
    // --- Passo 3: Desenha a entrada e a saída por último ---
    if (this == startNode) {
      image(tileset.get("ENTRADA_BALOES"), drawX, drawY, cellSize, cellSize);
    } else if (this == endNode) {
      image(tileset.get("NUCLEO_DEFENSAVEL"), drawX, drawY, cellSize, cellSize);
    }
  }
}
