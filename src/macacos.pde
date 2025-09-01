// ======================================================================
// ABA 2: Todas as classes de Macacos
// ======================================================================

abstract class Macaco {
  int nivel;
  float x, y;
  float alcanceEmTiles;
  float alcanceEmPixels;
  float cadenciaTirosPorSegundo;
  long cooldownTiroMilissegundos;
  long tempoUltimoTiro;
  int dano;
  Balao alvoAtual;
  boolean podeDetectarCamuflado = false;
  PImage icon;
  PImage animacaoAtaque;
  boolean estaAnimandoAtaque = false;
  long tempoInicioAnimacao;
  final int DURACAO_ANIMACAO_MS = 300;
  
  Macaco(float x, float y) {
    this.x = x;
    this.y = y;
    this.nivel = 1;
    this.alvoAtual = null;
    this.tempoUltimoTiro = 0;
  }
  
   void atualizar(ArrayList<Balao> baloes) {
    // Controla o fim da animação
    if (estaAnimandoAtaque && millis() - tempoInicioAnimacao > DURACAO_ANIMACAO_MS) {
      estaAnimandoAtaque = false;
    }

    if (alvoAtual == null || alvoAtual.estaDestruido() || dist(this.x, this.y, alvoAtual.pos.x, alvoAtual.pos.y) > this.alcanceEmPixels) {
      encontrarNovoAlvo(baloes);
    }
    
    if (alvoAtual != null) {
      // Condição para atirar
      if (millis() - tempoUltimoTiro >= cooldownTiroMilissegundos) {
        atirar();
        tempoUltimoTiro = millis();
        
        // ✨ INICIA A ANIMAÇÃO AQUI
        estaAnimandoAtaque = true;
        tempoInicioAnimacao = millis();
      }
    }
  }

  void encontrarNovoAlvo(ArrayList<Balao> baloes) {
    this.alvoAtual = null;
    Balao alvoPotencial = null;
    for (Balao b : baloes) {
      boolean podeMirar = !b.eCamuflado || this.podeDetectarCamuflado;
      if (podeMirar) {
        float d = dist(this.x, this.y, b.pos.x, b.pos.y);
        if (d <= this.alcanceEmPixels) {
          if (alvoPotencial == null) {
            alvoPotencial = b;
          }
        }
      }
    }
    this.alvoAtual = alvoPotencial;
  }  
  
  abstract void atirar();
  abstract void evoluir();

 void desenhar() {
    // Desenha o alcance para visualização
    noFill();
    stroke(255, 255, 255, 60);
    ellipse(this.x, this.y, alcanceEmPixels * 2, alcanceEmPixels * 2);
    
    PImage imagemParaDesenhar = estaAnimandoAtaque ? animacaoAtaque : icon;

    // Desenha a imagem, centralizada, com o tamanho de uma célula.

     image(imagemParaDesenhar, this.x, this.y, cellSize, cellSize);

  }
}

class MacacoDardo extends Macaco {
  MacacoDardo(float x, float y) {
    super(x, y);
    this.dano = 5;
    this.alcanceEmTiles = 3.0f;
    this.cadenciaTirosPorSegundo = 1.0f;
    this.icon = spritesMacacos.get("MACACO_DARDO_L1");
    this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_DARDO_L1");
    recalcularStats();
  }
  
  @Override
  void atirar() {
    if (alvoAtual != null) {
      projeteis.add(new Projetil(this.x, this.y, this.dano, this.alvoAtual));
    }
  }
  
  @Override
  void evoluir() {
    if (nivel == 1) {
      this.nivel = 2;
      this.alcanceEmTiles = 4.0f;
      this.cadenciaTirosPorSegundo = 1.2f;
      this.icon = spritesMacacos.get("MACACO_DARDO_L2");
      this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_DARDO_L2");
    } else if (nivel == 2) {
      this.nivel = 3;
      this.dano = 10; 
      this.alcanceEmTiles = 5.0f;
      this.icon = spritesMacacos.get("MACACO_DARDO_L3");      
      this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_DARDO_L3");      
    }
    recalcularStats();
  }

  void recalcularStats() {
    this.alcanceEmPixels = this.alcanceEmTiles * cellSize;
    this.cooldownTiroMilissegundos = (long) (1000 / this.cadenciaTirosPorSegundo);
  }

}

class MacacoBomba extends Macaco {
  float raioDaExplosaoEmTiles;
  float raioDaExplosaoEmPixels;

  MacacoBomba(float x, float y) {
    super(x, y);
    this.dano = 3;
    this.alcanceEmTiles = 3.0f;
    this.cadenciaTirosPorSegundo = 0.5f;
    this.raioDaExplosaoEmTiles = 1.5f;
    this.icon = spritesMacacos.get("MACACO_BOMBA_L1");
    this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_BOMBA_L1");     
    
    recalcularStats();
  }

  @Override
  void atirar() {
    if (alvoAtual != null) {
      projeteis.add(new ProjetilBomba(this.x, this.y, this.dano, this.alvoAtual, this.raioDaExplosaoEmPixels));
    }
  }
  
  @Override
  void evoluir() {
    if (nivel == 1) {
      this.nivel = 2;
      this.alcanceEmTiles = 3.5f;
      this.cadenciaTirosPorSegundo = 0.6f;
      this.raioDaExplosaoEmTiles = 2.0f;
      this.icon = spritesMacacos.get("MACACO_BOMBA_L2");
      this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_BOMBA_L2");
    } else if (nivel == 2) {
      this.nivel = 3;
      this.dano = 6;
      this.alcanceEmTiles = 4.0f;
      this.cadenciaTirosPorSegundo = 0.7f;
      this.icon = spritesMacacos.get("MACACO_BOMBA_L3");
      this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_BOMBA_L3");
    }
    recalcularStats();
  }
  
  void recalcularStats() {
    this.alcanceEmPixels = this.alcanceEmTiles * cellSize;
    this.cooldownTiroMilissegundos = (long) (1000 / this.cadenciaTirosPorSegundo);
    this.raioDaExplosaoEmPixels = this.raioDaExplosaoEmTiles * cellSize;
  }
}

class MacacoNinja extends Macaco {
  int projeteisPorTiro;

  MacacoNinja(float x, float y) {
    super(x, y);
    this.dano = 5;
    this.alcanceEmTiles = 4.0f;
    this.cadenciaTirosPorSegundo = 2.0f;
    this.projeteisPorTiro = 1;
    this.podeDetectarCamuflado = true;
    this.icon = spritesMacacos.get("MACACO_NINJA_L1");
    this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_NINJA_L1");
    recalcularStats();
  }

  @Override
  void atirar() {
    if (alvoAtual != null) {
      for (int i = 0; i < projeteisPorTiro; i++) {
        projeteis.add(new ProjetilShuriken(this.x, this.y, this.dano, this.alvoAtual));
      }
    }
  }
  
  @Override
  void evoluir() {
    if (nivel == 1) {
      this.nivel = 2;
      this.projeteisPorTiro = 2;
      this.icon = spritesMacacos.get("MACACO_NINJA_L2");
      this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_NINJA_L2");
    } else if (nivel == 2) { 
      this.nivel = 3; 
      this.projeteisPorTiro = 3;
      this.alcanceEmTiles = 5.0f;
      this.cadenciaTirosPorSegundo = 2.5f;
      this.icon = spritesMacacos.get("MACACO_NINJA_L3");
      this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_NINJA_L3");
    }
    recalcularStats();
  }
  
  void recalcularStats() {
    this.alcanceEmPixels = this.alcanceEmTiles * cellSize;
    this.cooldownTiroMilissegundos = (long) (1000 / this.cadenciaTirosPorSegundo);
  }
}

class MacacoGelo extends Macaco {
  float duracaoCongelamentoSegundos;
  float raioCongelamentoEmTiles;
  float raioCongelamentoEmPixels;

  MacacoGelo(float x, float y) {
    super(x, y);
    this.dano = 0; // Nível 1 não causa dano
    this.alcanceEmTiles = 3.0f; // Aumentei um pouco o alcance para ser mais útil
    this.cadenciaTirosPorSegundo = 0.8f;
    this.duracaoCongelamentoSegundos = 1.0f;
    this.raioCongelamentoEmTiles = 1.5f; // Raio da área que será congelada no impacto
    this.icon = spritesMacacos.get("MACACO_GELO_L1");
    this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_GELO_L1");
    recalcularStats();
  }
  
  // O método 'atualizar' customizado foi REMOVIDO.
  // Agora, ele usa o 'atualizar' da classe Macaco, que mira e chama atirar().

  /**
   * O método atirar agora é o responsável por criar o projétil de gelo.
   */
  @Override
  void atirar() {
    if (alvoAtual != null) {
      // Cria um novo projétil congelante e o adiciona à lista global
      projeteis.add(new ProjetilCongelante(this.x, this.y, this.dano, this.alvoAtual, this.duracaoCongelamentoSegundos, this.raioCongelamentoEmPixels));
    }
  }
  
  
  @Override
  void evoluir() {
    if (nivel == 1) {
      this.nivel = 2;
      this.alcanceEmTiles = 3.5f;
      this.duracaoCongelamentoSegundos = 1.5f;
      this.raioCongelamentoEmTiles = 2.0f; // Aumenta o raio da área congelada
      this.icon = spritesMacacos.get("MACACO_GELO_L2");
      this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_GELO_L2");
    } else if (nivel == 2) {
      this.nivel = 3;
      this.dano = 1; // Agora o impacto do projétil causa um pouco de dano
      this.alcanceEmTiles = 4.0f;
      this.duracaoCongelamentoSegundos = 2.0f;
      this.raioCongelamentoEmTiles = 2.5f;
      this.icon = spritesMacacos.get("MACACO_GELO_L3");    
      this.animacaoAtaque = spritesMacacos.get("ANIMACAO_MACACO_GELO_L3");
    }
    recalcularStats();
  }
  
  void recalcularStats() {
    this.alcanceEmPixels = this.alcanceEmTiles * cellSize;
    this.cooldownTiroMilissegundos = (long) (1000 / this.cadenciaTirosPorSegundo);
    // Também recalcula o raio da explosão em pixels
    this.raioCongelamentoEmPixels = this.raioCongelamentoEmTiles * cellSize;
  }
}
