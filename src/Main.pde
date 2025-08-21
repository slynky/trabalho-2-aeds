// ======================================================================
// ABA PRINCIPAL: Genciador do Jogo (Versão Corrigida e Unificada)
// ======================================================================

// --- OBJETOS DO JOGO ---
ArrayList<Macaco> macacos = new ArrayList<Macaco>();
ArrayList<Balao> baloes = new ArrayList<Balao>();
ArrayList<Projetil> projeteis = new ArrayList<Projetil>();
ArrayList<Explosao> explosoes = new ArrayList<Explosao>();

// --- OBJETOS DO MAPA ---
Grid grid;
HashMap<String, PImage> tileset;          // Para as imagens do mapa (ambiente)
HashMap<String, PImage> spritesBaloes;    // Para as imagens dos inimigos
HashMap<String, PImage> spritesMacacos;   // Para as imagens das torres
ArrayList<PVector> caminhoDosBaloes; // Armazena as coordenadas (em pixels) do caminho

// --- CONFIGURAÇÕES GLOBAIS ---
int cols = 24;
int rows = 16;
int cellSize;

void setup() {
  size(960, 640);
  noSmooth();
  imageMode(CENTER);
  
  cellSize = width / cols;
  loadTileset(); 
  
  // 2. Criar o mapa com um caminho fixo
  criarMapaComCaminhoFixo();
  
  // 3. Adicionar macacos para teste

}

void draw() {

}


// Nova função que substitui a criação de mapa aleatório
void criarMapaComCaminhoFixo() {
  grid = new Grid(cols, rows);
  caminhoDosBaloes = new ArrayList<PVector>();

   // 1. Define todo o mapa como grama com variações aleatórias
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      Node n = grid.nodes[i][j];
      n.tileType = Node.GRAMA;
      
      // CORREÇÃO 2: Adicionada a linha abaixo para que o jogo use as suas diferentes imagens de grama.
      n.gramaVariant = int(random(n.VARIANTS_GRAMA.length));
    }
  }

  // 2. Desenha um caminho fixo e salva as coordenadas dos centros das células
  // Caminho: entra pela esquerda, desce, vai pra direita, sobe um pouco e sai pela direita
  desenharCaminho(0, 7, 5, 7);    // Horizontal
  desenharCaminho(5, 7, 5, 12);   // Vertical
  desenharCaminho(5, 12, 18, 12); // Horizontal
  desenharCaminho(18, 12, 18, 4);  // Vertical
  desenharCaminho(18, 4, 23, 4);   // Horizontal
}

// Função auxiliar para criar segmentos do caminho
void desenharCaminho(int x1, int y1, int x2, int y2) {
  if (x1 == x2) { // Linha Vertical
    for (int y = min(y1, y2); y <= max(y1, y2); y++) {
      Node n = grid.nodes[x1][y];
      if (n.tileType != Node.CAMINHO) {
        n.tileType = Node.CAMINHO;
        caminhoDosBaloes.add(new PVector(x1 * cellSize + cellSize/2, y * cellSize + cellSize/2));
      }
    }
  } else { // Linha Horizontal
    for (int x = min(x1, x2); x <= max(x1, x2); x++) {
       Node n = grid.nodes[x][y1];
      if (n.tileType != Node.CAMINHO) {
        n.tileType = Node.CAMINHO;
        caminhoDosBaloes.add(new PVector(x * cellSize + cellSize/2, y1 * cellSize + cellSize/2));
      }
    }
  }
}

void processarDanos(){
  for (int i = projeteis.size() - 1; i >= 0; i--) {
    Projetil p = projeteis.get(i);
    if (p.atingiuAlvo()) {
      if (p.alvo != null && !p.alvo.estaDestruido()) {
        p.alvo.receberDano(p.dano);
        if (p instanceof ProjetilBomba) {
          ProjetilBomba pb = (ProjetilBomba) p;
          explosoes.add(new Explosao(pb.x, pb.y, pb.raioDaExplosaoEmPixels, pb.dano));
        }
      }
      projeteis.remove(i);
    }
  }
  for (Explosao e : explosoes) {
    if (!e.danoJaAplicado) {
      for (Balao b : baloes) {
        if (!b.imuneAExplosoes && dist(b.pos.x, b.pos.y, e.x, e.y) <= e.raioEmPixels) {
          b.receberDano(e.dano);
        }
      }
      e.danoJaAplicado = true;
    }
  }
}

void limparObjetos() {
    for (int i = baloes.size() - 1; i >= 0; i--) {
    if (baloes.get(i).estaDestruido() || baloes.get(i).chegouAoFim()) {
      baloes.remove(i);
    }
  }
  for (int i = explosoes.size() - 1; i >= 0; i--) {
    if (!explosoes.get(i).estaAtiva()) {
      explosoes.remove(i);
    }
  }
}

void loadTileset() {
// Inicializa os HashMaps
  tileset = new HashMap<String, PImage>();
  spritesBaloes = new HashMap<String, PImage>();
  spritesMacacos = new HashMap<String, PImage>();
  

  // --- Carrega Sprites do Ambiente ---
  tileset.put("GRAMA_PRINCIPAL", loadImage("../resources/Ambiente/grama_principal.png"));
  tileset.put("CAMINHO_TERRA", loadImage("../resources/Ambiente/caminho_terra.png"));
  tileset.put("GRAMA_BRANCA", loadImage("../resources/Ambiente/gramaBranca.png"));
  tileset.put("GRAMA_FLOR", loadImage("../resources/Ambiente/gramaFlor.png"));
  tileset.put("GRAMA_PEDRA", loadImage("../resources/Ambiente/gramaPedra.png"));
  tileset.put("OBSTACULO_ROCHA", loadImage("../resources/Ambiente/obstaculo_rocha.png"));
  // Adicione outros tiles de ambiente aqui...
  
  // --- Carrega Sprites dos Inimigos (Balões) ---
  spritesBaloes.put("AMARELO", loadImage("../resources/Inimigos/balaoAmarelo.png"));
  spritesBaloes.put("AZUL", loadImage("../resources/Inimigos/balaoAzul.png"));
  spritesBaloes.put("VERDE", loadImage("../resources/Inimigos/balaoVerde.png"));
  spritesBaloes.put("PRETO", loadImage("../resources/Inimigos/balaoPreto.png"));
  spritesBaloes.put("CAMUFLADO", loadImage("../resources/Inimigos/balaoCamuflado.png"));

  // --- Carrega Sprites das Torres (Macacos) ---
  spritesMacacos.put("MACACO_DARDO_L1", loadImage("../resources/Torres/MacacoDardo_L1.png"));
  spritesMacacos.put("MACACO_DARDO_L2", loadImage("../resources/Torres/MacacoDardo_L2.png"));
  spritesMacacos.put("MACACO_DARDO_L3", loadImage("../resources/Torres/MacacoDardo_L3.png"));
  // Adicione os outros macacos aqui...
}
