import java.util.PriorityQueue;

// Gerenciador de todos os nossos sprites
HashMap<String, PImage> tileset;

Grid grid;
int cols = 50;
int rows = 50;
int cellSize;

// Nós de início e fim
Node startNode;
Node endNode;

void setup() {
  size(800, 800);
  
  // Calcula o tamanho de cada célula
  cellSize = width / cols;
  
  // Carrega todos os sprites necessários
  loadTileset();
  
  // Cria o primeiro mapa
  createNewMap();
}

void draw() {
  // O grid agora desenha a si mesmo com os sprites corretos
  if (grid != null) {
    grid.drawGrid();
  }
  
  // Desenha marcadores para o início e o fim (pode ser substituído por sprites)
  fill(0, 255, 0, 150); // Verde para o início
  rect(startNode.x * cellSize, startNode.y * cellSize, cellSize, cellSize);
  fill(255, 0, 0, 150); // Vermelho para o fim
  rect(endNode.x * cellSize, endNode.y * cellSize, cellSize, cellSize);
}

// Função para gerar um novo mapa e resolver o caminho
void createNewMap() {
  // 1. CRIA O MAPA COM TIPOS DE TILES
  grid = new Grid(cols, rows, 0.35); // 35% de chance de obstáculo
  
  // Define os pontos de partida e chegada
  startNode = grid.nodes[0][0];
  endNode = grid.nodes[cols - 1][rows - 1];
  
  // Garante que o início e o fim sejam caminhos livres (Grama)
  startNode.tileType = Node.GRAMA;
  endNode.tileType = Node.GRAMA;
  
  // Adiciona os vizinhos para cada nó (essencial para o grafo)
  grid.addNeighbors();
  
  // 2. RODA O ALGORITMO DE DIJKSTRA
  ArrayList<Node> path = dijkstra(startNode, endNode);
  
  // 3. ATUALIZA O MAPA COM O CAMINHO ENCONTRADO
  if (path != null) {
    for (Node n : path) {
      n.tileType = Node.CAMINHO; // Transforma os nós do caminho em tipo "Caminho"
    }
  }
}

// O algoritmo de Dijkstra permanece quase o mesmo
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
        finalPath.add(temp);
        temp = temp.predecessor;
      }
      return finalPath;
    }
    
    for (Node neighbor : current.neighbors) {
      float newDistance = current.distance + 1; // Custo de movimento simples
      
      if (newDistance < neighbor.distance) {
        neighbor.distance = newDistance;
        neighbor.predecessor = current;
        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
        }
      }
    }
  }
  
  println("Nenhum caminho encontrado!");
  return null;
}

// Carrega todas as imagens do nosso tileset
void loadTileset() {
  tileset = new HashMap<String, PImage>();
  
  // Tiles Base
  tileset.put("GRAMA", loadImage("grama.png"));
  tileset.put("CAMINHO", loadImage("caminho_terra.png"));
  tileset.put("OBSTACULO", loadImage("obstaculo_rocha.png"));
  
  // Tiles de Borda (essenciais para o auto-tiling)
  // Adicione aqui os nomes exatos dos seus arquivos de borda
  // Exemplo:
  // tileset.put("BORDA_TOPO", loadImage("borda_grama_caminho_topo.png"));
  // ... e assim por diante para todas as 8 combinações de borda/quina.
  // Por enquanto, vamos simular com cores para ver a lógica funcionando.
}

// Gera um novo mapa quando o mouse é pressionado
void mousePressed() {
  createNewMap();
}
