// ======================================================================
// ABA 4: Classes de Projéteis e Efeitos
// ======================================================================

class Projetil {
  float x, y;
  float velocidade = 8.0;
  int dano;
  Balao alvo;
  PImage icon;
  
  Projetil(float startX, float startY, int dano, Balao alvo) {
    this.x = startX;
    this.y = startY;
    this.dano = dano;
    this.alvo = alvo;
    //this.icon = spritesProjeteis.get("DARDO");
  }
  
  void atualizar() {
    if (alvo == null || alvo.estaDestruido()) return;

    float angulo = atan2(alvo.pos.y - this.y, alvo.pos.x - this.x);
    this.x += cos(angulo) * velocidade;
    this.y += sin(angulo) * velocidade;
  }
  
  void desenhar(){
    image(this.icon, this.x, this.y);
  }
  
  boolean atingiuAlvo() {
    if (alvo == null || alvo.estaDestruido()) return true; // Se o alvo sumiu, o projétil pode desaparecer
    return dist(this.x, this.y, alvo.pos.x, alvo.pos.y) < velocidade;
  }
}

class ProjetilShuriken extends Projetil {
  
   ProjetilShuriken(float startX, float startY, int dano, Balao alvo) {
    super(startX, startY, dano, alvo);
    this.velocidade = 6.0;
    //this.icon = spritesProjeteis.get("SHURIKEN");
   }
}

class ProjetilCongelante extends Projetil {
  
   ProjetilCongelante(float startX, float startY, int dano, Balao alvo) {
    super(startX, startY, dano, alvo);
    this.velocidade = 3.0;
    //this.icon = spritesProjeteis.get("FLOCO_DE_NEVE");
  }
  
}


class ProjetilBomba extends Projetil {
  float raioDaExplosaoEmPixels;
  
  ProjetilBomba(float startX, float startY, int dano, Balao alvo, float raio) {
    super(startX, startY, dano, alvo);
    this.raioDaExplosaoEmPixels = raio;
    this.velocidade = 4.0;
    //this.icon = spritesProjeteis.get("BOMBA");
  }
  
}

class Explosao {
  float x, y;
  float raioEmPixels;
  int dano;
  long tempoCriacao;
  long duracao = 300;
  boolean danoJaAplicado = false;
  
  Explosao(float x, float y, float raio, int dano) {
    this.x = x; this.y = y; this.raioEmPixels = raio; this.dano = dano;
    this.tempoCriacao = millis();
    
  }
  
  boolean estaAtiva() {
    return millis() - tempoCriacao < duracao;
  }
  
  void desenhar() {
    float progresso = (float)(millis() - tempoCriacao) / duracao;
    float raioAtual = lerp(0, raioEmPixels, progresso);
    float opacidade = lerp(200, 0, progresso);
    
    fill(255, 165, 0, opacidade);
    noStroke();
    ellipse(this.x, this.y, raioAtual * 2, raioAtual * 2);
  }
}
