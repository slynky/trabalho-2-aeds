import java.util.PriorityQueue;

// ======================================================================
// ABA PRINCIPAL: Genciador do Jogo (Versão Completa)
// ======================================================================

// --- OBJETOS DO JOGO ---
ArrayList<Macaco> macacos = new ArrayList<Macaco>();
ArrayList<Balao> baloes = new ArrayList<Balao>();
ArrayList<Projetil> projeteis = new ArrayList<Projetil>();
ArrayList<Explosao> explosoes = new ArrayList<Explosao>();

// --- OBJETOS DO MAPA ---
Grid grid;
HashMap<String, PImage> tileset;
HashMap<String, PImage> spritesBaloes;
HashMap<String, PImage> spritesMacacos;
HashMap<String, PImage> spritesVFX;
HashMap<String, PImage> spritesProjeteis;
HashMap<String, PImage> spritesUI;
//hashMap<String, Pimage> spritesProjeteis;
//hashMap<String, Pimage> spritesVFX;
ArrayList<PVector> caminhoDosBaloes;
Node startNode;
Node endNode;

// --- CONFIGURAÇÕES GLOBAIS ---
int cols = 24;
int rows = 16;
int cellSize;
int rodada = 0;

void setup() {
  size(960, 640);
  noSmooth();
  imageMode(CENTER);
  
  cellSize = width / cols;
  
  carregarTodosOsSprites();
  
  // 1. Cria o mapa vazio
  grid = new Grid(cols, rows);
  for (int i=0; i<cols; i++) {
    for (int j=0; j<rows; j++) {
      Node currentNode = grid.nodes[i][j];
      currentNode.gramaVariant = int(random(currentNode.VARIANTS_GRAMA.length));
    }
  }
  
  // 2. Define os pontos de início e fim
  startNode = grid.nodes[0][rows/2];
  endNode = grid.nodes[cols-1][rows/2];
  
  // 3. Calcula o caminho inicial
  atualizarCaminhoDosBaloes();
}

void draw() {

  grid.drawGrid();


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
  
  rodada++;
}

void mousePressed() {
  int gridX = int(mouseX / cellSize);
  int gridY = int(mouseY / cellSize);

  if (gridX >= 0 && gridX < cols && gridY >= 0 && gridY < rows) {
    Node noClicado = grid.nodes[gridX][gridY];
    
    if (noClicado.tileType == Node.CAMINHO || noClicado.tileType == Node.OBSTACULO || noClicado == startNode || noClicado == endNode) {
      return;
    }
    
    noClicado.tileType = Node.OBSTACULO;
    boolean caminhoExiste = atualizarCaminhoDosBaloes();
    
    if (caminhoExiste) {
      float pixelX = gridX * cellSize + cellSize/2;
      float pixelY = gridY * cellSize + cellSize/2;
      macacos.add(new MacacoDardo(pixelX, pixelY));
    } else {
      noClicado.tileType = Node.GRAMA;
      atualizarCaminhoDosBaloes();
    }
  }
}

boolean atualizarCaminhoDosBaloes() {
  grid.addNeighbors();
  ArrayList<Node> novoCaminhoNodes = dijkstra(startNode, endNode);
  
  if (novoCaminhoNodes == null) {
    return false;
  }
  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (grid.nodes[i][j].tileType == Node.CAMINHO) {
        grid.nodes[i][j].tileType = Node.GRAMA;
      }
    }
  }

  caminhoDosBaloes = new ArrayList<PVector>();
  for (Node n : novoCaminhoNodes) {
    n.tileType = Node.CAMINHO;
    caminhoDosBaloes.add(new PVector(n.x * cellSize + cellSize/2, n.y * cellSize + cellSize/2));
  }
  return true;
}

ArrayList<Node> dijkstra(Node start, Node end) {
  PriorityQueue<Node> openSet = new PriorityQueue<Node>();
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
    if (current == end) {
      ArrayList<Node> finalPath = new ArrayList<Node>();
      Node temp = current;
      while (temp != null) {
        finalPath.add(0, temp);
        temp = temp.predecessor;
      }
      return finalPath;
    }
    
    for (Node neighbor : current.neighbors) {
      float newDistance = current.distance + 1;
      if (newDistance < neighbor.distance) {
        neighbor.distance = newDistance;
        neighbor.predecessor = current;
        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
        }
      }
    }
  }
  return null;
}

void carregarTodosOsSprites() {
  tileset = new HashMap<String, PImage>();
  spritesBaloes = new HashMap<String, PImage>();
  spritesMacacos = new HashMap<String, PImage>();
  spritesProjeteis = new HashMap<String, PImage>();
  spritesVFX = new HashMap<String, PImage>();
  spritesUI = new HashMap<String, PImage>();
  
  // --- Ambiente ---
  
  tileset.put("CAMINHO_BORDA", loadImage("../resources/Ambiente/caminho_borda.png"));
  tileset.put("CAMINHO_LATERAL", loadImage("../resources/Ambiente/caminho_lateral.png"));
  tileset.put("CAMINHO_SUPERIOR", loadImage("../resources/Ambiente/caminho_superior.png"));
  tileset.put("CAMINHO_TERRA", loadImage("../resources/Ambiente/caminho_terra.png"));
  tileset.put("CAMINHO_TERRA_2", loadImage("../resources/Ambiente/caminho_terra_2.png"));
  tileset.put("ENTRADA_BALOES", loadImage("../resources/Ambiente/entrada_baloes.gif"));
  tileset.put("GRAMA_BRANCA", loadImage("../resources/Ambiente/gramaBranca.png"));
  tileset.put("GRAMA_BRANCA_2", loadImage("../resources/Ambiente/gramaBranca2.png"));
  tileset.put("GRAMA_FLOR", loadImage("../resources/Ambiente/gramaFlor.png"));
  tileset.put("GRAMA_PEDRA", loadImage("../resources/Ambiente/gramaPedra.png"));
  tileset.put("GRAMA_PRINCIPAL", loadImage("../resources/Ambiente/grama_principal.png"));
  tileset.put("NUCLEO_DEFENSAVEL", loadImage("../resources/Ambiente/nucleo_defensavel.png"));
  tileset.put("OBSTACULO_PALMEIRA", loadImage("../resources/Ambiente/obstaculo_palmeira.png"));
  tileset.put("OBSTACULO_ROCHA", loadImage("../resources/Ambiente/obstaculo_rocha.png"));
  tileset.put("PEDRA", loadImage("../resources/Ambiente/Pedra.png"));

  // --- Inimigos ---
  
  spritesBaloes.put("AMARELO", loadImage("../resources/Inimigos/balao_amarelo.png"));
  spritesBaloes.put("AZUL", loadImage("../resources/Inimigos/balao_azul.png"));
  spritesBaloes.put("VERDE", loadImage("../resources/Inimigos/balao_verde.png"));
  spritesBaloes.put("PRETO", loadImage("../resources/Inimigos/balao_preto.png"));
  spritesBaloes.put("CAMUFLADO", loadImage("../resources/Inimigos/balao_camuflado.png"));
  spritesBaloes.put("DIRIGIVEL", loadImage("../resources/Inimigos/dirigivel.png"));

  // --- Torres ---
  
  spritesMacacos.put("MACACO_DARDO_L1", loadImage("../resources/Torres/MacacoDardo_L1.png"));
  spritesMacacos.put("MACACO_DARDO_L2", loadImage("../resources/Torres/MacacoDardo_L2.png"));
  spritesMacacos.put("MACACO_DARDO_L3", loadImage("../resources/Torres/MacacoDardo_L3.png"));
  
  spritesMacacos.put("MACACO_BOMBA_L1", loadImage("../resources/Torres/MacacoBomba_L1.png"));
  spritesMacacos.put("MACACO_BOMBA_L2", loadImage("../resources/Torres/MacacoBomba_L2.png"));
  spritesMacacos.put("MACACO_BOMBA_L3", loadImage("../resources/Torres/MacacoBomba_L3.png"));
  
  spritesMacacos.put("MACACO_GELO_L1", loadImage("../resources/Torres/MacacoGelo_L1.png"));
  spritesMacacos.put("MACACO_GELO_L2", loadImage("../resources/Torres/MacacoGelo_L2.png"));
  spritesMacacos.put("MACACO_GELO_L3", loadImage("../resources/Torres/MacacoGelo_L3.png"));
  
  spritesMacacos.put("MACACO_NINJA_L1", loadImage("../resources/Torres/MacacoNinja_L1.png"));
  spritesMacacos.put("MACACO_NINJA_L2", loadImage("../resources/Torres/MacacoNinja_L2.png"));
  spritesMacacos.put("MACACO_NINJA_L3", loadImage("../resources/Torres/MacacoNinja_L3.png"));
  
  // --- Animações ---
  
  spritesMacacos.put("ANIMACAO_MACACO_DARDO_L1", loadImage("../resources/Torres/animacao_macacoDardoL1.gif"));
  spritesMacacos.put("ANIMACAO_MACACO_DARDO_L2", loadImage("../resources/Torres/animacao_macacoDardoL2.gif"));
  spritesMacacos.put("ANIMACAO_MACACO_DARDO_L3", loadImage("../resources/Torres/animacao_macacoDardoL3.gif"));
  
  spritesMacacos.put("ANIMACAO_MACACO_BOMBA_L1", loadImage("../resources/Torres/animacao_macacoBombaL1.gif"));
  spritesMacacos.put("ANIMACAO_MACACO_BOMBA_L2", loadImage("../resources/Torres/animacao_macacoBombaL2.gif"));
  spritesMacacos.put("ANIMACAO_MACACO_BOMBA_L3", loadImage("../resources/Torres/animacao_macacoBombaL3.gif"));
  
  spritesMacacos.put("ANIMACAO_MACACO_GELO_L1", loadImage("../resources/Torres/animacao_macacoGeloL1.gif"));
  spritesMacacos.put("ANIMACAO_MACACO_GELO_L2", loadImage("../resources/Torres/animacao_macacoGeloL2.gif"));
  spritesMacacos.put("ANIMACAO_MACACO_GELO_L3", loadImage("../resources/Torres/animacao_macacoGeloL3.gif"));
  
  spritesMacacos.put("ANIMACAO_MACACO_NINJA_L1", loadImage("../resources/Torres/animacao_macacoNinjaL1.gif"));
  spritesMacacos.put("ANIMACAO_MACACO_NINJA_L2", loadImage("../resources/Torres/animacao_macacoNinjaL2.gif"));
  spritesMacacos.put("ANIMACAO_MACACO_NINJA_L3", loadImage("../resources/Torres/animacao_macacoNinjaL3.gif"));
  
  // --- Projeteis ---
  
  spritesProjeteis.put("DARDO", loadImage("resources/Projeteis/dardo.png"));
  spritesProjeteis.put("BOMBA", loadImage("../resources/Projeteis/bomba.png"));
  spritesProjeteis.put("FLOCO_DE_NEVE", loadImage("../resources/Projeteis/floco_neve.png"));
  spritesProjeteis.put("SHURIKEN", loadImage("../resources/Projeteis/shuriken.png"));
  
  // --- VFX ---
  
  spritesVFX.put("BALAO_POP", loadImage("../resources/VFX/Balao_pop.gif"));
  spritesVFX.put("EXPLOSAO_BOMBA", loadImage("../resources/VFX/Bomba_pop.gif"));  
  spritesVFX.put("EFEITO_CONGELADO", loadImage("../resources/VFX/efeito_congelado.png"));
  
  // --- UI ---
  
  spritesUI.put("ICONE_VIDA", loadImage("../resources/UI/icone_vida.png"));
  spritesUI.put("ICONE_HORDA", loadImage("../resources/UI/icone_horda.png"));
  spritesUI.put("ICONE_DINHEIRO", loadImage("../resources/UI/icone_dinheiro.png"));
  spritesUI.put("BOTAO_UPGRADE", loadImage("../resources/UI/botao_upgrade.png"));

  
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
      balancaJogador += baloes.get(i).valor;
      baloes.remove(i);
    }
  }
  for (int i = explosoes.size() - 1; i >= 0; i--) {
    if (!explosoes.get(i).estaAtiva()) {
      explosoes.remove(i);
    }
  }
}

void spawner() {
   if (rodada < 3){
     
   }
}
