/**
 * A classe Node representa uma única célula (ou "tile") no nosso mapa.
 * Cada Node sabe sua posição no grid, seu tipo (Grama ou Caminho) e como
 * se desenhar na tela usando as imagens corretas.
 */
class Node {
  // --- TIPOS DE TILE ---
  // Usar 'static final int' cria constantes para deixar o código mais legível.
  static final int GRAMA = 0;
  static final int CAMINHO = 1;

  // Array com as chaves para todas as nossas variações de grama.
  // A ordem aqui deve corresponder às chaves que você usou no tileset.
   final String[] VARIANTS_GRAMA = {
    "GRAMA", 
    "GRAMA_BRANCA", 
    "GRAMA_BRANCA2", 
    "GRAMA_FLORIDA", 
    "GRAMA_PEDRA",
    "GRAMA_COM_FLORES"
  };
  
  int tileType = GRAMA;     // Define o tipo principal da célula.
  int gramaVariant = 0;   // Guarda o índice da variante de grama a ser usada.
  int x, y;               // Posição no grid (coluna e linha).

  /**
   * O Construtor da classe Node. Armazena as coordenadas do grid para esta célula.
   */
  Node(int x_, int y_) {
    this.x = x_;
    this.y = y_;
  }
  
  /**
   * O método de desenho para esta célula específica.
   * Ele decide qual imagem usar com base no 'tileType' e na 'gramaVariant'.
   */
  void drawNode() {
    // Checagem de segurança para evitar erro se as imagens não carregarem.
    if (tileset == null) {
      if (tileType == GRAMA) {
        fill(34, 139, 34); // Verde
      } else if (tileType == CAMINHO) {
        fill(139, 69, 19); // Marrom
      }
      noStroke();
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
      return;
    }

    PImage spriteToDraw = null;

    // Decide qual sprite pegar do nosso tileset
    if (tileType == CAMINHO) {
      spriteToDraw = tileset.get("CAMINHO");
    } else { // Se for grama...
      // 1. Pega a chave da variante correta ("GRAMA_FLORIDA", etc.) usando o índice.
      String chaveDaGrama = VARIANTS_GRAMA[gramaVariant];
      // 2. Pega a imagem do tileset usando essa chave.
      spriteToDraw = tileset.get(chaveDaGrama);
    }
    
    // Se a imagem foi encontrada, desenha na tela.
    if (spriteToDraw != null) {
      image(spriteToDraw, x * cellSize, y * cellSize, cellSize, cellSize);
    } else {
      // Se não encontrou (ex: erro no nome da chave), desenha um quadrado magenta de alerta.
      fill(255, 0, 255);
      noStroke();
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }
  }
}
