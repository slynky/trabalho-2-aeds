// ======================================================================
// ABA: Grid_e_Node (Com Explicações e Desenho de Imagens)
// ======================================================================

/**
 * A classe Grid representa o nosso mapa de jogo completo.
 * Sua principal função é ser um "container" que armazena todos os 
 * objetos Node (as células do mapa) em uma matriz 2D.
 */
class Grid {
  int cols, rows;   // Armazena as dimensões do grid (ex: 24 colunas por 16 linhas).
  Node[][] nodes;   // A matriz 2D que guardará cada célula individual do mapa.

  /**
   * O Construtor da classe Grid. É executado quando você cria um novo Grid.
   * Ele prepara o mapa, criando todos os objetos Node necessários.
   */
  Grid(int c, int r) {
    this.cols = c;
    this.rows = r;
    this.nodes = new Node[cols][rows]; // Inicializa a matriz com o tamanho correto.

    // Usa um loop aninhado para passar por cada posição da matriz.
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        // Em cada posição, cria um novo objeto Node, passando suas coordenadas (i, j).
        nodes[i][j] = new Node(i, j);
      }
    }
  }
  
  /**
   * Este método desenha o mapa inteiro na tela.
   * Ele faz isso percorrendo cada Node na matriz e pedindo para que ele se desenhe.
   */
  void drawGrid() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        nodes[i][j].drawNode();
      }
    }
  }
}
