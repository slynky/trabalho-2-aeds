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
HashMap<String, PImage> tileset;
ArrayList<PVector> caminhoDosBaloes; // Armazena as coordenadas (em pixels) do caminho

// --- CONFIGURAÇÕES GLOBAIS ---
int cols = 24;
int rows = 16;
int cellSize;

void setup() {
  size(960, 640);
  noSmooth();
  
  cellSize = width / cols;
  loadTileset(); 
  
  // 2. Criar o mapa com um caminho fixo
  criarMapaComCaminhoFixo();
  
  // 3. Adicionar macacos para teste

}

void draw() {
  // 1. DESENHAR O CENÁRIO
  if (grid != null) {
    grid.drawGrid();
  } else {
    background(135, 206, 235); // Cor de fundo fallback
  }

  // 2. SPAWNER DE BALÕES
  if (frameCount % 90 == 0) {
    baloes.add(new BalaoAzul()); 
  }
  if (frameCount % 200 == 0) {
    baloes.add(new BalaoBranco());
  }
  if (frameCount % 500 == 0) {
    baloes.add(new BalaoPreto());
  }

  // 3. ATUALIZAR OBJETOS
  for (Macaco m : macacos) { m.atualizar(baloes); }
  for (Balao b : baloes) { b.atualizar(); }
  for (Projetil p : projeteis) { p.atualizar(); }

  // 4. PROCESSAR DANOS E COLISÕES
  processarDanos();

  // 5. LIMPAR OBJETOS DESTRUÍDOS
  limparObjetos();
  
  // 6. DESENHAR OBJETOS DINÂMICOS
  for (Balao b : baloes) { b.desenhar(); }
  for (Macaco m : macacos) { m.desenhar(); }
  for (Projetil p : projeteis) { p.desenhar(); }
  for (Explosao e : explosoes) { e.desenhar(); }
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

void loadTileset() {//o tileset nao tem mt oq falar

  tileset = new HashMap<String, PImage>();

  tileset.put("GRAMA", loadImage("../resources/grama.png"));
  tileset.put("GRAMA_BRANCA", loadImage("../resources/gramaBranca2.png"));
  tileset.put("GRAMA_BRANCA2", loadImage("../resources/gramaBranca4.png"));
  tileset.put("GRAMA_FLORIDA", loadImage("../resources/gramaFlorida.png"));
  tileset.put("GRAMA_PEDRA", loadImage("../resources/gramaPedra.png"));
  tileset.put("GRAMA_COM_FLORES", loadImage("../resources/gramaFlor.png"));
 
  tileset.put("CAMINHO", loadImage("../resources/caminho_terra.png")); 
}
