class Grid {
  int cols, rows;
  Node[][] nodes;
  float obstacleDensity;

  Grid(int c, int r, float density) {
    cols = c;
    rows = r;
    obstacleDensity = density;
    nodes = new Node[cols][rows];

    // Cria todos os nós do grid
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        nodes[i][j] = new Node(i, j, this);
        // Define se é um obstáculo com base na densidade
        if (random(1) < obstacleDensity) {
          nodes[i][j].tileType = Node.OBSTACULO;
        }
      }
    }
  }
  
  // Encontra e armazena os vizinhos para cada nó
  void addNeighbors() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        nodes[i][j].findNeighbors();
      }
    }
  }

  // Desenha o mapa na tela usando os sprites
  void drawGrid() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        nodes[i][j].drawNode();
      }
    }
  }
}
