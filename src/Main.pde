import java.util.PriorityQueue;
import java.util.Queue; // Importa a classe de Fila
import java.util.LinkedList; // Importa a implementação de Fila
import java.util.Collections; // Para poder embaralhar a ordem dos balões

// ======================================================================
// ABA PRINCIPAL: Genciador do Jogo 
// ======================================================================

// --- OBJETOS DO JOGO ---
ArrayList<Macaco> macacos = new ArrayList<Macaco>();
ArrayList<Balao> baloes = new ArrayList<Balao>();
ArrayList<Projetil> projeteis = new ArrayList<Projetil>();
ArrayList<Explosao> explosoes = new ArrayList<Explosao>();
Queue<String> filaDeSpawns = new LinkedList<String>();
// --- OBJETOS DO MAPA ---
Grid grid;
HashMap<String, PImage> tileset;
HashMap<String, PImage> spritesBaloes;
HashMap<String, PImage> spritesMacacos;
HashMap<String, PImage> spritesVFX;
HashMap<String, PImage> spritesProjeteis;
HashMap<String, PImage> spritesUI;
ArrayList<PVector> caminhoDosBaloes;
Node startNode;
Node endNode;

// --- CONFIGURAÇÕES GLOBAIS ---
int cols = 24;
int rows = 16;
int cellSize;
int rodada = 0;
int vida = 100;
int balancaJogador = 100;
boolean gameOver = false;
boolean pause = false;
long tempoProximoSpawn = 0; // Controla o tempo para o próximo balão aparecer.
final int INTERVALO_SPAWN_MS = 450; // Intervalo de 450ms entre cada balão
String impecilioSelecionadoParaCompra = null; 
final String[] TIPOS_DE_IMPECILIO = {"PEDRA", "OBSTACULO_PALMEIRA"};
// --- Constantes de Preços das Torres e Upgrades ---

// Macaco de Dardo
final int PRECO_BASE_MACACO_DARDO = 50;
final int PRECO_UPGRADE_MACACO_DARDO_NV2 = 120;
final int PRECO_UPGRADE_MACACO_DARDO_NV3 = 300;

// Macaco de Bomba
final int PRECO_BASE_MACACO_BOMBA = 250;
final int PRECO_UPGRADE_MACACO_BOMBA_NV2 = 400;
final int PRECO_UPGRADE_MACACO_BOMBA_NV3 = 1000;

// Macaco de Gelo
final int PRECO_BASE_MACACO_GELO = 300;
final int PRECO_UPGRADE_MACACO_GELO_NV2 = 450;
final int PRECO_UPGRADE_MACACO_GELO_NV3 = 1200;

// Macaco Ninja
final int PRECO_BASE_MACACO_NINJA = 400;
final int PRECO_UPGRADE_MACACO_NINJA_NV2 = 600;
final int PRECO_UPGRADE_MACACO_NINJA_NV3 = 1500;

//OBSTACULO
final int PRECO_IMPECILIO = 150;

// --- Variáveis de Estado do Jogo ---
final int NENHUM = 0;
final int MACACO_DARDO = 1;
final int MACACO_NINJA = 2;
final int MACACO_GELO = 3;
final int MACACO_BOMBA = 4;
final int IMPECILIO = 5;
final int UPGRADE = 6;
int torreSelecionadaParaCompra = NENHUM;

// --- Constantes Globais (UI) ---
final int X_BOTAO_UI = 20;
final int Y_INICIAL_UI = 70;
final int ESPACAMENTO_UI = 30;
final int LARGURA_BOTAO_UI = 32; // Ajustado para o tamanho real do sprite
final int ALTURA_BOTAO_UI = 32;  // Ajustado para o tamanho real do sprite


void setup() {
  size(1200, 800);
  noSmooth();
  imageMode(CENTER); // Importante para a UI funcionar corretamente!
  
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
  
  // 2. Cria o caminho personalizado do mapa
  criarMapaComBifurcacao();
  
  //atualiza o caminho a ser feito inicialmente
  atualizarCaminhoDosBaloes();
}

void draw() {
  grid.drawGrid();
  
    if (gameOver) {
    // --- TELA DE GAME OVER ---
    fill(0, 180); // Fundo escuro semi-transparente para focar na mensagem
    rect(0, 0, width, height);
    
    textAlign(CENTER, CENTER);
    fill(255, 0, 0); // Vermelho para "GAME OVER"
    textSize(64);
    text("GAME OVER", width / 2, height / 2 - 40);
    
    fill(255); // Branco para a instrução
    textSize(28);
    text("Aperte alguma tecla para reiniciar para reiniciar", width / 2, height / 2 + 40);
    
    return; // Importante: Para a execução do draw aqui para não rodar a lógica do jogo
  }
  
  desenharIcones();
    
  // ATUALIZAR OBJETOS BÁSICOS
  for (Macaco m : macacos) { m.atualizar(baloes); }
  
    // VERIFICA O FIM DA RODADA PARA PREPARAR A PRÓXIMA
  if (baloes.isEmpty() && filaDeSpawns.isEmpty() && explosoes.isEmpty() && !pause) {
    rodada++;
    spawner(); // Prepara a próxima rodada
    pause = true; // Pausa o jogo esperando o jogador
  } 
    
  if (pause) {
    fill(0); 
    textAlign(LEFT);
    textSize(32);
    text("Aperte ENTER para iniciar a próxima rodada", 10, 40);
  } else {
    // >>> JOGO RODANDO <<<
      
      // LÓGICA DE SPAWN DIRETO NO DRAW
      if (!filaDeSpawns.isEmpty() && millis() >= tempoProximoSpawn) {
        String tipoParaSpawnar = filaDeSpawns.poll();
        switch (tipoParaSpawnar) {
          case "AMARELO":   baloes.add(new BalaoAmarelo());   break;
          case "AZUL":      baloes.add(new BalaoAzul());      break;
          case "VERDE":     baloes.add(new BalaoVerde());     break;
          case "CAMUFLADO": baloes.add(new BalaoCamuflado()); break;
          case "PRETO":     baloes.add(new BalaoPreto());     break;
        }
        tempoProximoSpawn = millis() + INTERVALO_SPAWN_MS;
      }
  
      // ATUALIZAR OBJETOS DINÂMICOS
      for (Balao b : baloes) { b.atualizar(); }
      for (Projetil p : projeteis) { p.atualizar(); }
      
      // PROCESSAR DANOS E COLISÕES
      processarDanos();
    
      // LIMPAR OBJETOS DESTRUÍDOS
      limparObjetos();
      
      // DESENHAR OBJETOS DINÂMICOS
      for (Balao b : baloes) { b.desenhar(); }
      for (Projetil p : projeteis) { p.desenhar(); }
      for (Explosao e : explosoes) { e.desenhar(); }
    } 
    
    // DESENHAR OBJETOS (sempre visíveis)
    for (Macaco m : macacos) { m.desenhar(); }
    // VERIFICA SE O JOGO ACABOU NESTE FRAME
  if (vida <= 0) {
    gameOver = true;
  }
  
}
/**
 * Lida com todos os eventos de clique do mouse na tela.
 * A função é dividida em duas partes principais:
 * 1. Interação com a Interface do Usuário (UI): Verifica se o clique foi em algum dos botões
 * de compra (torres, impecilhos) ou de ação (upgrade).
 * 2. Interação com o Grid: Se uma ação de compra foi selecionada, esta parte lida com a lógica
 * de posicionar o item no mapa, validando as regras de cada um.
 */
void mousePressed() {
  // --- PARTE 1: VERIFICAR CLIQUE NA INTERFACE (UI) ---
  
  // Botão 1: Macaco Dardo (índice 0)
  if (mouseX > X_BOTAO_UI - LARGURA_BOTAO_UI/2 && mouseX < X_BOTAO_UI + LARGURA_BOTAO_UI/2 && 
      mouseY > Y_INICIAL_UI + (ESPACAMENTO_UI * 0) - ALTURA_BOTAO_UI/2 && mouseY < Y_INICIAL_UI + (ESPACAMENTO_UI * 0) + ALTURA_BOTAO_UI/2) {
    if (podePagar(PRECO_BASE_MACACO_DARDO)) {
      torreSelecionadaParaCompra = MACACO_DARDO;
    }
    return;
  }

  // Botão 2: Macaco Ninja (índice 1)
  if (mouseX > X_BOTAO_UI - LARGURA_BOTAO_UI/2 && mouseX < X_BOTAO_UI + LARGURA_BOTAO_UI/2 && 
      mouseY > Y_INICIAL_UI + (ESPACAMENTO_UI * 1) - ALTURA_BOTAO_UI/2 && mouseY < Y_INICIAL_UI + (ESPACAMENTO_UI * 1) + ALTURA_BOTAO_UI/2) {
    if (podePagar(PRECO_BASE_MACACO_NINJA)) {
      torreSelecionadaParaCompra = MACACO_NINJA;
    }
    return;
  }

  // Botão 3: Macaco de Gelo (índice 2)
  if (mouseX > X_BOTAO_UI - LARGURA_BOTAO_UI/2 && mouseX < X_BOTAO_UI + LARGURA_BOTAO_UI/2 && 
      mouseY > Y_INICIAL_UI + (ESPACAMENTO_UI * 2) - ALTURA_BOTAO_UI/2 && mouseY < Y_INICIAL_UI + (ESPACAMENTO_UI * 2) + ALTURA_BOTAO_UI/2) {
    if (podePagar(PRECO_BASE_MACACO_GELO)) {
      torreSelecionadaParaCompra = MACACO_GELO;
    }
    return;
  }

  // Botão 4: Torre de Bomba (índice 3)
  if (mouseX > X_BOTAO_UI - LARGURA_BOTAO_UI/2 && mouseX < X_BOTAO_UI + LARGURA_BOTAO_UI/2 && 
      mouseY > Y_INICIAL_UI + (ESPACAMENTO_UI * 3) - ALTURA_BOTAO_UI/2 && mouseY < Y_INICIAL_UI + (ESPACAMENTO_UI * 3) + ALTURA_BOTAO_UI/2) {
    if (podePagar(PRECO_BASE_MACACO_BOMBA)) {
      torreSelecionadaParaCompra = MACACO_BOMBA;
    }
    return;
  }
  
  // Botão 5: Impecilho (índice 4)
  if (mouseX > X_BOTAO_UI - LARGURA_BOTAO_UI/2 && mouseX < X_BOTAO_UI + LARGURA_BOTAO_UI/2 && 
      mouseY > Y_INICIAL_UI + (ESPACAMENTO_UI * 4) - ALTURA_BOTAO_UI/2 && mouseY < Y_INICIAL_UI + (ESPACAMENTO_UI * 4) + ALTURA_BOTAO_UI/2) {
    if (podePagar(PRECO_IMPECILIO)) {
      torreSelecionadaParaCompra = IMPECILIO;
      int indiceAleatorio = int(random(TIPOS_DE_IMPECILIO.length));
      impecilioSelecionadoParaCompra = TIPOS_DE_IMPECILIO[indiceAleatorio];
    }
    return;
  }
  
  // Botão 6: Upgrade (índice 5)
  if (mouseX > X_BOTAO_UI - LARGURA_BOTAO_UI/2 && mouseX < X_BOTAO_UI + LARGURA_BOTAO_UI/2 && 
      mouseY > Y_INICIAL_UI + (ESPACAMENTO_UI * 5) - ALTURA_BOTAO_UI/2 && mouseY < Y_INICIAL_UI + (ESPACAMENTO_UI * 5) + ALTURA_BOTAO_UI/2) {
    torreSelecionadaParaCompra = UPGRADE;
    return;
  }
  
  // --- PARTE 2: LÓGICA PARA INTERAGIR COM O GRID ---

  int gridX = int(mouseX / cellSize);
  int gridY = int(mouseY / cellSize);

  // Verifica se o clique foi fora do grid
  if (gridX < 0 || gridX >= cols || gridY < 0 || gridY >= rows) {
    torreSelecionadaParaCompra = NENHUM;
    impecilioSelecionadoParaCompra = null;
    return;
  }
  
  // LÓGICA DE UPGRADE (INTACTA, COMO NO SEU CÓDIGO ORIGINAL)
  if (torreSelecionadaParaCompra == UPGRADE) {
    for (Macaco m : macacos) {
      int macacoGridX = int(m.x / cellSize);
      int macacoGridY = int(m.y / cellSize);

      if (macacoGridX == gridX && macacoGridY == gridY) {
        if (m instanceof MacacoDardo) {
          if (m.nivel == 1 && podePagar(PRECO_UPGRADE_MACACO_DARDO_NV2)) {
            m.evoluir();
            subtrairPreco(PRECO_UPGRADE_MACACO_DARDO_NV2);
          } else if (m.nivel == 2 && podePagar(PRECO_UPGRADE_MACACO_DARDO_NV3)) {
            m.evoluir();
            subtrairPreco(PRECO_UPGRADE_MACACO_DARDO_NV3);
          }
        } else if (m instanceof MacacoBomba) {
          if (m.nivel == 1 && podePagar(PRECO_UPGRADE_MACACO_BOMBA_NV2)) {
            m.evoluir();
            subtrairPreco(PRECO_UPGRADE_MACACO_BOMBA_NV2);
          } else if (m.nivel == 2 && podePagar(PRECO_UPGRADE_MACACO_BOMBA_NV3)) {
            m.evoluir();
            subtrairPreco(PRECO_UPGRADE_MACACO_BOMBA_NV3);
          }
        } else if (m instanceof MacacoGelo) {
          if (m.nivel == 1 && podePagar(PRECO_UPGRADE_MACACO_GELO_NV2)) {
            m.evoluir();
            subtrairPreco(PRECO_UPGRADE_MACACO_GELO_NV2);
          } else if (m.nivel == 2 && podePagar(PRECO_UPGRADE_MACACO_GELO_NV3)) {
            m.evoluir();
            subtrairPreco(PRECO_UPGRADE_MACACO_GELO_NV3);
          }
        } else if (m instanceof MacacoNinja) {
          if (m.nivel == 1 && podePagar(PRECO_UPGRADE_MACACO_NINJA_NV2)) {
            m.evoluir();
            subtrairPreco(PRECO_UPGRADE_MACACO_NINJA_NV2);
          } else if (m.nivel == 2 && podePagar(PRECO_UPGRADE_MACACO_NINJA_NV3)) {
            m.evoluir();
            subtrairPreco(PRECO_UPGRADE_MACACO_NINJA_NV3);
          }
        }
        break;
      }
    }
    torreSelecionadaParaCompra = NENHUM;
    return;
  }

  // LÓGICA PARA COLOCAR UMA NOVA TORRE OU IMPECILHO (CORRIGIDA)
  if (torreSelecionadaParaCompra != NENHUM) {
    Node noClicado = grid.nodes[gridX][gridY];

    if (torreSelecionadaParaCompra == IMPECILIO) {
        // --- LÓGICA PARA COLOCAR IMPECILHO ---
        // REGRA: Pode colocar em grama ou caminho, se não houver nada lá.
        if ((noClicado.tileType == Node.GRAMA || noClicado.tileType == Node.CAMINHO) && noClicado.obstaculoVariant == null) {
          noClicado.obstaculoVariant = impecilioSelecionadoParaCompra;
          subtrairPreco(PRECO_IMPECILIO);
        }
      
    } else {
        // --- LÓGICA PARA COLOCAR TORRE (MACACO) ---
        // REGRA: Só pode colocar em grama, e se não houver impecilho lá.
        if (noClicado.tileType == Node.GRAMA && noClicado.obstaculoVariant == null) {
            noClicado.tileType = Node.OBSTACULO;
            boolean caminhoExiste = atualizarCaminhoDosBaloes();
          
            if (caminhoExiste) {
                float pixelX = gridX * cellSize + cellSize / 2;
                float pixelY = gridY * cellSize + cellSize / 2;
                switch (torreSelecionadaParaCompra) {
                  case MACACO_DARDO: macacos.add(new MacacoDardo(pixelX, pixelY)); subtrairPreco(PRECO_BASE_MACACO_DARDO); break;
                  case MACACO_NINJA: macacos.add(new MacacoNinja(pixelX, pixelY)); subtrairPreco(PRECO_BASE_MACACO_NINJA); break;
                  case MACACO_GELO: macacos.add(new MacacoGelo(pixelX, pixelY)); subtrairPreco(PRECO_BASE_MACACO_GELO); break;
                  case MACACO_BOMBA: macacos.add(new MacacoBomba(pixelX, pixelY)); subtrairPreco(PRECO_BASE_MACACO_BOMBA); break;
                }
            } else {
                noClicado.tileType = Node.GRAMA; 
                atualizarCaminhoDosBaloes();
            }
        }
    }
    
    // Reseta a seleção após a tentativa
    torreSelecionadaParaCompra = NENHUM;
    impecilioSelecionadoParaCompra = null;
  }
}

void carregarTodosOsSprites() {
  tileset = new HashMap<String, PImage>();
  spritesBaloes = new HashMap<String, PImage>();
  spritesMacacos = new HashMap<String, PImage>();
  spritesProjeteis = new HashMap<String, PImage>();
  spritesVFX = new HashMap<String, PImage>();
  spritesUI = new HashMap<String, PImage>();
  
  // --- Ambiente ---
 // Gramas
  tileset.put("GRAMA_PRINCIPAL", loadImage("../resources/Ambiente/grama_principal.png"));
  tileset.put("GRAMA", loadImage("../resources/Ambiente/grama.png")); // ADICIONADO
  tileset.put("GRAMA_FLORIDA", loadImage("../resources/Ambiente/Grama_florida.png")); // ADICIONADO
  tileset.put("GRAMA_BRANCA", loadImage("../resources/Ambiente/gramaBranca.png"));
  tileset.put("GRAMA_BRANCA_2", loadImage("../resources/Ambiente/gramaBranca2.png"));
  tileset.put("GRAMA_FLOR", loadImage("../resources/Ambiente/gramaFlor.png"));
  tileset.put("GRAMA_PEDRA", loadImage("../resources/Ambiente/gramaPedra.png"));
  
  // Caminhos
  tileset.put("CAMINHO_HORIZONTAL", loadImage("../resources/Ambiente/caminho_horizontal.png"));
  tileset.put("CAMINHO_VERTICAL", loadImage("../resources/Ambiente/caminho_vertical.png"));
  tileset.put("CURVA_CIMA_ESQUERDA", loadImage("../resources/Ambiente/caminho_diagonal_esquerda_superior.png"));
  tileset.put("CURVA_CIMA_DIREITA", loadImage("../resources/Ambiente/caminho_diagonal_direita_superior.png"));
  tileset.put("CURVA_BAIXO_ESQUERDA", loadImage("../resources/Ambiente/caminho_diagonal_esquerda_inferior.png"));
  tileset.put("CURVA_BAIXO_DIREITA", loadImage("../resources/Ambiente/caminho_diagonal_direita_inferior.png"));
  
  // Especiais e Obstáculos
  tileset.put("ENTRADA_BALOES", loadImage("../resources/Ambiente/entrada_baloes.gif"));
  tileset.put("NUCLEO_DEFENSAVEL", loadImage("../resources/Ambiente/nucleo_defensavel.png"));
  tileset.put("OBSTACULO_PALMEIRA", loadImage("../resources/Ambiente/obstaculo_palmeira.png"));
  tileset.put("OBSTACULO_ROCHA", loadImage("../resources/Ambiente/obstaculo_rocha.png"));
  tileset.put("OBSTACULO_PEDRA", loadImage("../resources/Ambiente/obstaculo_pedra.png")); // ADICIONADO
  tileset.put("PEDRA", loadImage("../resources/Ambiente/Pedra.png"));

  // --- Inimigos ---
  spritesBaloes.put("AMARELO", loadImage("../resources/Inimigos/balao_amarelo.png"));
  spritesBaloes.put("AZUL", loadImage("../resources/Inimigos/balao_azul.png"));
  spritesBaloes.put("VERDE", loadImage("../resources/Inimigos/balao_verde.png"));
  spritesBaloes.put("CAMUFLADO", loadImage("../resources/Inimigos/balao_camuflado.png"));
  spritesBaloes.put("PRETO", loadImage("../resources/Inimigos/dirigivel.png"));

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
  spritesProjeteis.put("DARDO", loadImage("../resources/Projeteis/dardo.png"));
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
  spritesUI.put("BOTAO_BOMBA", loadImage("../resources/UI/botao_bomba.png"));
  spritesUI.put("BOTAO_DARDO", loadImage("../resources/UI/botao_dardo.png"));
  spritesUI.put("BOTAO_GELO", loadImage("../resources/UI/botao_gelo.png"));
  spritesUI.put("BOTAO_NINJA", loadImage("../resources/UI/botao_ninja.png"));
  spritesUI.put("BOTAO_OBSTACULO", loadImage("../resources/UI/botao_parede.png"));
}

void processarDanos(){
  // Itera de trás para frente para poder remover itens sem problemas
  for (int i = projeteis.size() - 1; i >= 0; i--) {
    Projetil p = projeteis.get(i);
    
    // Se o projétil atingiu o alvo...
    if (p.atingiuAlvo()) {
      // Se o alvo ainda existe, causa o dano principal
      if (p.alvo != null && !p.alvo.estaDestruido()) {
        p.alvo.receberDano(p.dano);
      }
      
      // VERIFICA O TIPO DE PROJÉTIL PARA EFEITOS ESPECIAIS
      
      // Se for uma Bomba, cria uma Explosão
      if (p instanceof ProjetilBomba) {
        ProjetilBomba pb = (ProjetilBomba) p;
        explosoes.add(new Explosao(pb.x, pb.y, pb.raioDaExplosaoEmPixels, pb.dano));
      } 
      // ✨ SE FOR UM PROJÉTIL CONGELANTE, CONGELA A ÁREA ✨
      else if (p instanceof ProjetilCongelante) {
        ProjetilCongelante pc = (ProjetilCongelante) p;
        
        // Itera por TODOS os balões para ver quem está na área de efeito
        for (Balao b : baloes) {
          if (!b.imuneAGelo && dist(b.pos.x, b.pos.y, pc.x, pc.y) <= pc.raioCongelamentoPixels) {
            b.aplicarCongelamento((long)(pc.duracaoCongelamentoSegundos * 1000));
            
            // O dano do projétil de gelo é aplicado em área também
            if (pc.dano > 0) {
              b.receberDano(pc.dano);
            }
          }
        }
      }
      
      // Remove o projétil da lista
      projeteis.remove(i);
    }
  }
  
  // A lógica de dano das explosoes
  for (Explosao e : explosoes) {
    if (!e.danoJaAplicado) {
      e.danoJaAplicado = true;
    }
    
  }
}

void limparObjetos() {
  for (int i = baloes.size() - 1; i >= 0; i--) {
    Balao b = baloes.get(i);
    if (b.estaDestruido()) {
      balancaJogador += b.valor;
      baloes.remove(i);
    } else if (b.chegouAoFim()) {
      vida -= b.dano;
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
  filaDeSpawns.clear();

  if (rodada >= 20) {
    filaDeSpawns.add("PRETO");
    return;
  }

  int quantidadeAmarelos = 8 + rodada * 3;
  for (int i = 0; i < quantidadeAmarelos; i++) {
    filaDeSpawns.add("AMARELO");
  }

  if (rodada >= 5) {
    int quantidadeAzuis = 4 + (rodada - 3) * 2;
    for (int i = 0; i < quantidadeAzuis; i++) {
      filaDeSpawns.add("AZUL");
    }
  }

  if (rodada >= 9) {
    int quantidadeVerdes = 3 + (rodada - 6);
    for (int i = 0; i < quantidadeVerdes; i++) {
      filaDeSpawns.add("VERDE");
    }
  }

  if (rodada >= 14) {
    int quantidadeCamuflados = 2 + (rodada - 9);
    for (int i = 0; i < quantidadeCamuflados; i++) {
      filaDeSpawns.add("CAMUFLADO");
    }
  }
  
  Collections.shuffle((LinkedList<String>) filaDeSpawns);
}

void keyPressed() {
  if (gameOver){
    resetarJogo();
    return;
  }
  
  if (keyCode == ENTER || keyCode == RETURN) {
    if (pause) {
      pause = false;
    }
  }
}

void desenharIcones() {
  // Define o modo de desenho para o canto superior esquerdo, ideal para UI
  imageMode(CORNER); 
  
  // --- Ícones de Status (Canto Superior Direito) ---
  fill(0); 
  textSize(24);
  textAlign(RIGHT, CENTER); // Alinha o texto pela DIREITA e pelo CENTRO vertical

  int xIconeStatus = 1160; // Posição X para todos os ícones de status
  int xTextoStatus = 1150; // Posição X para todos os textos de status (à esquerda do ícone)
  int yIcone = 40;         // Posição Y inicial
  int alturaIcone = 32;      // Altura do seu ícone (ajuste se necessário)
  int espacoEntreIcones = 50; // Espaçamento vertical

  // Ícone e texto da Vida
  image(spritesUI.get("ICONE_VIDA"), xIconeStatus, yIcone);
  // O truque é adicionar metade da altura do ícone ao Y do texto para centralizá-lo
  text(vida, xTextoStatus, yIcone + alturaIcone / 2);

  // Ícone e texto da Horda/Rodada
  yIcone += espacoEntreIcones; // Move para a posição do próximo ícone
  image(spritesUI.get("ICONE_HORDA"), xIconeStatus, yIcone);
  text(rodada, xTextoStatus, yIcone + alturaIcone / 2);

  // Ícone e texto do Dinheiro
  yIcone += espacoEntreIcones; // Move para a posição do próximo ícone
  image(spritesUI.get("ICONE_DINHEIRO"), xIconeStatus, yIcone);
  text(balancaJogador, xTextoStatus, yIcone + alturaIcone / 2);
  
  // --- Botões de Ação/Torres (Barra Lateral Esquerda) ---
  // (Esta parte já estava bem alinhada com as constantes)
   // Botão e Preço: Macaco Dardo
// Botão e Preço: Macaco Dardo
  image(spritesUI.get("BOTAO_DARDO"), X_BOTAO_UI, Y_INICIAL_UI + (ESPACAMENTO_UI * (MACACO_DARDO - 1)));
  text(PRECO_BASE_MACACO_DARDO, 
       X_BOTAO_UI + spritesUI.get("BOTAO_DARDO").width + 30, 
       (Y_INICIAL_UI + (ESPACAMENTO_UI * (MACACO_DARDO - 1))) + spritesUI.get("BOTAO_DARDO").height / 2);

  // Botão e Preço: Macaco Ninja
  image(spritesUI.get("BOTAO_NINJA"), X_BOTAO_UI, Y_INICIAL_UI + (ESPACAMENTO_UI * (MACACO_NINJA - 1)));
  text(PRECO_BASE_MACACO_NINJA, 
       X_BOTAO_UI + spritesUI.get("BOTAO_NINJA").width + 30, 
       (Y_INICIAL_UI + (ESPACAMENTO_UI * (MACACO_NINJA - 1))) + spritesUI.get("BOTAO_NINJA").height / 2);

  // Botão e Preço: Macaco de Gelo
  image(spritesUI.get("BOTAO_GELO"), X_BOTAO_UI, Y_INICIAL_UI + (ESPACAMENTO_UI * (MACACO_GELO - 1)));
  text(PRECO_BASE_MACACO_GELO, 
       X_BOTAO_UI + spritesUI.get("BOTAO_GELO").width + 30, 
       (Y_INICIAL_UI + (ESPACAMENTO_UI * (MACACO_GELO - 1))) + spritesUI.get("BOTAO_GELO").height / 2);

  // Botão e Preço: Macaco de Bomba
  image(spritesUI.get("BOTAO_BOMBA"), X_BOTAO_UI, Y_INICIAL_UI + (ESPACAMENTO_UI * (MACACO_BOMBA - 1)));
  text(PRECO_BASE_MACACO_BOMBA, 
       X_BOTAO_UI + spritesUI.get("BOTAO_BOMBA").width + 30, 
       (Y_INICIAL_UI + (ESPACAMENTO_UI * (MACACO_BOMBA - 1))) + spritesUI.get("BOTAO_BOMBA").height / 2);

  // Botão e Preço: Impecilho
  image(spritesUI.get("BOTAO_OBSTACULO"), X_BOTAO_UI, Y_INICIAL_UI + (ESPACAMENTO_UI * (IMPECILIO - 1)));
  text(PRECO_IMPECILIO, 
       X_BOTAO_UI + spritesUI.get("BOTAO_OBSTACULO").width + 30, 
       (Y_INICIAL_UI + (ESPACAMENTO_UI * (IMPECILIO - 1))) + spritesUI.get("BOTAO_OBSTACULO").height / 2);

  // Botão de Upgrade (sem preço fixo)
  image(spritesUI.get("BOTAO_UPGRADE"), X_BOTAO_UI, Y_INICIAL_UI + (ESPACAMENTO_UI * (UPGRADE - 1)));


  // Restaura o modo de imagem para o centro, caso o resto do seu código precise
  imageMode(CENTER);
}


// Função para subtrair o preço de torres e upgrades da balança do jogador
void subtrairPreco(int preco) {
  balancaJogador -= preco;
}

boolean podePagar(int preco){
  return balancaJogador >= preco;
}

/**
 * Reseta completamente o estado do jogo para seus valores iniciais.
 * Chamada após a tela de "Game Over" para iniciar uma nova partida.
 */
void resetarJogo() {
  // 1. Limpa todas as listas de objetos dinâmicos
  macacos.clear();
  baloes.clear();
  projeteis.clear();
  explosoes.clear();
  filaDeSpawns.clear();

  // 2. Reseta as estatísticas do jogador
  vida = 100;
  balancaJogador = 100;
  rodada = 0;

  // 3. Reseta o grid, removendo torres e obstáculos colocados pelo jogador
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      Node no = grid.nodes[i][j];
      // Se o nó foi transformado em obstáculo por uma torre, reverte para grama
      if (no.tileType == Node.OBSTACULO) {
        no.tileType = Node.GRAMA;
      }
      // Remove qualquer impecilho (pedra, palmeira) que foi comprado
      no.obstaculoVariant = null;
    }
  }
  
  // 4. Recalcula o caminho dos balões no mapa limpo
  atualizarCaminhoDosBaloes();
  
  // 5. Reseta as variáveis de controle do jogo
  pause = true; // Começa pausado, esperando o jogador iniciar a rodada 1
  tempoProximoSpawn = 0;
  torreSelecionadaParaCompra = NENHUM;
  impecilioSelecionadoParaCompra = null;
  
  // 6. Sai do estado de "Game Over"
  gameOver = false;
}
