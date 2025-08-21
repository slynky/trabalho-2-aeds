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

  Macaco(float x, float y) {
    this.x = x;
    this.y = y;
    this.nivel = 1;
    this.alvoAtual = null;
    this.tempoUltimoTiro = 0;
  }
  
  void atualizar(ArrayList<Balao> baloes) {
    if (alvoAtual == null || alvoAtual.estaDestruido() || dist(this.x, this.y, alvoAtual.pos.x, alvoAtual.pos.y) > this.alcanceEmPixels) {
      encontrarNovoAlvo(baloes);
    }
    
    if (alvoAtual != null) {
      if (millis() - tempoUltimoTiro >= cooldownTiroMilissegundos) {
        atirar();
        tempoUltimoTiro = millis();
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
    
    // Se o ícone foi carregado, desenha-o.
    if (icon != null) {
      // Desenha a imagem, centralizada, com o tamanho de uma célula.
      image(icon, this.x, this.y, cellSize, cellSize);
    } else {
      // Desenho alternativo caso a imagem não carregue
      fill(139, 69, 19);
      stroke(0);
      ellipse(this.x, this.y, cellSize * 0.8, cellSize * 0.8);
    }
  }
}

class MacacoDardo extends Macaco {
  MacacoDardo(float x, float y) {
    super(x, y);
    this.dano = 5;
    this.alcanceEmTiles = 3.0f;
    this.cadenciaTirosPorSegundo = 1.0f;
    this.icon = spritesMacacos.get("MACACO_DARDO_L1");
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
    } else if (nivel == 2) {
      this.nivel = 3;
      this.dano = 10; 
      this.alcanceEmTiles = 5.0f;
      this.icon = spritesMacacos.get("MACACO_DARDO_L3");      
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
    } else if (nivel == 2) {
      this.nivel = 3;
      this.dano = 6;
      this.alcanceEmTiles = 4.0f;
      this.cadenciaTirosPorSegundo = 0.7f;
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
    recalcularStats();
  }

  @Override
  void atirar() {
    if (alvoAtual != null) {
      for (int i = 0; i < projeteisPorTiro; i++) {
        projeteis.add(new Projetil(this.x, this.y, this.dano, this.alvoAtual));
      }
    }
  }
  
  @Override
  void evoluir() {
    if (nivel == 1) {
      this.nivel = 2;
      this.projeteisPorTiro = 2;
    } else if (nivel == 2) { 
      this.nivel = 3; 
      this.projeteisPorTiro = 3;
      this.alcanceEmTiles = 5.0f;
      this.cadenciaTirosPorSegundo = 2.5f;
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

  MacacoGelo(float x, float y) {
    super(x, y);
    this.dano = 0;
    this.alcanceEmTiles = 2.0f;
    this.cadenciaTirosPorSegundo = 0.5f; // Pulso a cada 2s
    this.duracaoCongelamentoSegundos = 1.0f;
    recalcularStats();
  }
  
  @Override
  void atualizar(ArrayList<Balao> baloes) {
    if (millis() - tempoUltimoTiro >= cooldownTiroMilissegundos) {
      congelarArea(baloes);
      tempoUltimoTiro = millis();
    }
  }
  
  void congelarArea(ArrayList<Balao> baloes) {
    for (Balao b : baloes) {
      if (!b.imuneAGelo && dist(this.x, this.y, b.pos.x, b.pos.y) <= this.alcanceEmPixels) {
        b.aplicarCongelamento((long)(this.duracaoCongelamentoSegundos * 1000));
        if (this.dano > 0) {
          b.receberDano(this.dano);
        }
      }
    }
  }

  @Override
  void atirar() {}
  
  @Override
  void evoluir() {
    if (nivel == 1) {
      this.nivel = 2;
      this.alcanceEmTiles = 3.0f;
      this.duracaoCongelamentoSegundos = 1.5f;
    } else if (nivel == 2) {
      this.nivel = 3;
      this.dano = 5;
      this.duracaoCongelamentoSegundos = 2.0f;
    }
    recalcularStats();
  }
  
  void recalcularStats() {
    this.alcanceEmPixels = this.alcanceEmTiles * cellSize;
    this.cooldownTiroMilissegundos = (long) (1000 / this.cadenciaTirosPorSegundo);
  }
}
