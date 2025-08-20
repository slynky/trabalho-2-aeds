//======================================================================
// Classes para Obstáculos e Terrenos (não mudam)
//======================================================================

class Parede {
  int custo;
  String efeito;
  String notas;
  PImage icon;
  
  Parede() {
    this.custo = 30;
    this.efeito = "Impede totalmente a passagem.";
    this.notas = "Custo de movimento infinito no pathfinding. Bloqueia a linha de visão.";
    this.icon = loadImage("resources/Parede.png");
  }
}

class Areia {
  int custo;
  String efeito;
  String notas;
  PImage icon;
  
  Areia() {
    this.custo = 15;
    this.efeito = "Reduz a velocidade dos balões em 50%.";
    this.notas = "Custo de movimento dobrado no pathfinding.";
    this.icon = loadImage("resources/Areia.png");
  }
}


//======================================================================
// Classes para os Macacos (com sistema de evolução)
//======================================================================

class MacacoDardo {
  int nivel;
  int custo;
  int custoProximaEvolucao;
  float alcanceEmTiles;
  float cadenciaTirosPorSegundo;
  int dano;
  PImage icon;
  
  // Posição da torre no mapa
  float x, y;

  // Construtor: Sempre cria um macaco Nível 1
  MacacoDardo(float x, float y) {
    this.x = x;
    this.y = y;
    
    // Atributos Padrão (Nível 1)
    this.nivel = 1;
    this.custo = 50;
    this.custoProximaEvolucao = 120;
    this.alcanceEmTiles = 3.0f;
    this.cadenciaTirosPorSegundo = 1.0f;
    this.dano = 1;
    this.icon = loadImage("resources/MacacoDardo_L1.png");
  }
  
  // Método para evoluir o macaco para o próximo nível
  void evoluir() {
    if (nivel == 1) {
      // --- EVOLUIR PARA O NÍVEL 2 ---
      this.nivel = 2;
      this.custoProximaEvolucao = 300;
      this.alcanceEmTiles = 4.0f;
      this.cadenciaTirosPorSegundo = 1.2f;
      // Dano continua 1
      this.icon = loadImage("resources/MacacoDardo_L2.png");
    } else if (nivel == 2) {
      // --- EVOLUIR PARA O NÍVEL 3 ---
      this.nivel = 3;
      this.custoProximaEvolucao = -1; // -1 indica que não há mais evoluções
      this.alcanceEmTiles = 5.0f;
      // Cadência continua 1.2
      this.dano = 2;
      this.icon = loadImage("resources/MacacoDardo_L3.png");
    }
  }

  boolean podeEvoluir() {
    return nivel < 3;
  }
  
  void desenhar() {
    // Lógica para desenhar o this.icon na posição x, y
  }
}


class MacacoBomba {
  int nivel;
  int custo;
  int custoProximaEvolucao;
  float alcanceEmTiles;
  float cadenciaTirosPorSegundo;
  int dano;
  float raioDaExplosaoEmTiles;
  float duracaoAtordoamentoSegundos;
  PImage icon;
  
  float x, y;

  MacacoBomba(float x, float y) {
    this.x = x;
    this.y = y;
    
    // Atributos Padrão (Nível 1)
    this.nivel = 1;
    this.custo = 250;
    this.custoProximaEvolucao = 400;
    this.alcanceEmTiles = 3.0f;
    this.cadenciaTirosPorSegundo = 0.5f;
    this.dano = 1;
    this.raioDaExplosaoEmTiles = 1.5f;
    this.duracaoAtordoamentoSegundos = 0; // Nível 1 não atordoa
    this.icon = loadImage("resources/MacacoBomba_L1.png");
  }

  void evoluir() {
    if (nivel == 1) {
      // --- EVOLUIR PARA O NÍVEL 2 ---
      this.nivel = 2;
      this.custoProximaEvolucao = 1000;
      this.alcanceEmTiles = 3.5f;
      this.cadenciaTirosPorSegundo = 0.6f;
      this.raioDaExplosaoEmTiles = 2.0f;
      this.icon = loadImage("resources/MacacoBomba_L2.png");
    } else if (nivel == 2) {
      // --- EVOLUIR PARA O NÍVEL 3 ---
      this.nivel = 3;
      this.custoProximaEvolucao = -1;
      this.alcanceEmTiles = 4.0f;
      this.cadenciaTirosPorSegundo = 0.7f;
      this.dano = 2;
      this.duracaoAtordoamentoSegundos = 0.5f; // Agora atordoa
      this.icon = loadImage("resources/MacacoBomba_L3.png");
    }
  }

  boolean podeEvoluir() {
    return nivel < 3;
  }

  void desenhar() {
    // Lógica para desenhar
  }
}


class MacacoGelo {
  int nivel;
  int custo;
  int custoProximaEvolucao;
  float alcanceEmTiles;
  float cooldownPulsoSegundos;
  int dano;
  float duracaoCongelamentoSegundos;
  String habilidade;
  PImage icon;
  
  float x, y;
  
  MacacoGelo(float x, float y) {
    this.x = x;
    this.y = y;
    
    // Atributos Padrão (Nível 1)
    this.nivel = 1;
    this.custo = 300;
    this.custoProximaEvolucao = 450;
    this.alcanceEmTiles = 2.0f;
    this.cooldownPulsoSegundos = 2.0f;
    this.dano = 0;
    this.duracaoCongelamentoSegundos = 1.0f;
    this.habilidade = "";
    this.icon = loadImage("resources/MacacoGelo_L1.png");
  }
  
  void evoluir() {
    if (nivel == 1) {
      // --- EVOLUIR PARA O NÍVEL 2 ---
      this.nivel = 2;
      this.custoProximaEvolucao = 1200;
      this.alcanceEmTiles = 3.0f;
      this.duracaoCongelamentoSegundos = 1.5f;
      this.icon = loadImage("resources/MacacoGelo_L2.png");
    } else if (nivel == 2) {
      // --- EVOLUIR PARA O NÍVEL 3 ---
      this.nivel = 3;
      this.custoProximaEvolucao = -1;
      this.dano = 1; // Agora causa dano
      this.duracaoCongelamentoSegundos = 2.0f;
      this.habilidade = "Permafrost: Causa 1 de dano a qualquer balão que congela.";
      this.icon = loadImage("resources/MacacoGelo_L3.png");
    }
  }

  boolean podeEvoluir() {
    return nivel < 3;
  }

  void desenhar() {
    // Lógica para desenhar
  }
}


class MacacoNinja {
  int nivel;
  int custo;
  int custoProximaEvolucao;
  float alcanceEmTiles;
  float cadenciaTirosPorSegundo;
  int dano;
  int projeteisPorTiro;
  boolean detectaCamuflado;
  String habilidade;
  PImage icon;
  
  float x, y;
  
  MacacoNinja(float x, float y) {
    this.x = x;
    this.y = y;

    // Atributos Padrão (Nível 1)
    this.nivel = 1;
    this.custo = 400;
    this.custoProximaEvolucao = 600;
    this.alcanceEmTiles = 4.0f;
    this.cadenciaTirosPorSegundo = 2.0f;
    this.dano = 1;
    this.projeteisPorTiro = 1;
    this.detectaCamuflado = true;
    this.habilidade = "";
    this.icon = loadImage("resources/MacacoNinja_L1.png");
  }
  
  void evoluir() {
    if (nivel == 1) {
      // --- EVOLUIR PARA O NÍVEL 2 ---
      this.nivel = 2;
      this.custoProximaEvolucao = 1500;
      this.projeteisPorTiro = 2; // Habilidade "Tiro Duplo"
      this.icon = loadImage("resources/MacacoNinja_L2.png");
    } else if (nivel == 2) {
      // --- EVOLUIR PARA O NÍVEL 3 ---
      this.nivel = 3;
      this.custoProximaEvolucao = -1;
      this.alcanceEmTiles = 5.0f;
      this.cadenciaTirosPorSegundo = 2.5f;
      this.projeteisPorTiro = 3;
      this.habilidade = "Bomba Flash: Pode atordoar balões camuflados.";
      this.icon = loadImage("resources/MacacoNinja_L3.png");
    }
  }
  
  boolean podeEvoluir() {
    return nivel < 3;
  }
  
  void desenhar() {
    // Lógica para desenhar
  }
}
