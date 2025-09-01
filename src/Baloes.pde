// ======================================================================
// ABA 3: Classe dos Balões (Com Explicações)
// ======================================================================

/**
 * A classe Balao é a classe "mãe" ou o "molde" para todos os tipos de balões.
 * Ela contém todas as propriedades e comportamentos que são comuns a todos,
 * como movimento, vida, e estados (como congelado).
 */
class Balao {
  // --- PROPRIEDADES DE ESTADO ---
  PVector pos;          // Armazena as coordenadas X e Y juntas. É ótimo para cálculos de movimento.
  int vida;             // Pontos de vida do balão.
  int valor;            // Quantidade de moedas que o jogador ganha ao estourá-lo.
  float velocidadeBase; // A velocidade normal do balão.
  float velocidadeAtual;  // A velocidade que o balão está usando no momento (pode ser 0 se congelado).
  PImage icon;
  int caminhoIndex = 0; // "Memória" do balão. Indica para qual ponto do caminho ele está indo.
  int dano;
  // --- PROPRIEDADES DE HABILIDADES ESPECIAIS (FLAGS) ---
  boolean eCamuflado = false;      // Se for true, só pode ser visto por torres específicas (Ninja).
  boolean imuneAGelo = false;        // Se for true, não é afetado pelo Macaco de Gelo.
  boolean imuneAExplosoes = false; // Se for true, não leva dano do Macaco Bomba.
  
  // --- CONTROLE DE EFEITOS TEMPORÁRIOS ---
  boolean estaCongelado = false;      // Flag para saber se o balão está parado pelo gelo.
  long tempoFimCongelamento = 0; // Guarda o "momento no futuro" em que o congelamento deve acabar.

  /**
   * O Construtor é chamado quando um novo balão é criado (ex: new BalaoAzul()).
   * Ele não precisa de argumentos (x, y) porque a posição inicial é sempre o começo do caminho.
   */
  Balao() {
    // Garante que o jogo não quebre se o caminho ainda não foi criado.
    if (caminhoDosBaloes != null && !caminhoDosBaloes.isEmpty()) {
      // Pega o primeiro ponto do caminho (.get(0)) e cria uma cópia para este balão.
      this.pos = caminhoDosBaloes.get(0).copy();
      // Coloca o balão um pouco para fora da tela para que ele "entre" suavemente.
      this.pos.x -= cellSize; 
    } else {
      // Se, por algum motivo, o caminho não existir, cria o balão fora da tela para evitar erros.
      this.pos = new PVector(-cellSize, height/2);
    }
    // Define que o balão deve começar a seguir o primeiro ponto do caminho (índice 0).
    this.caminhoIndex = 0;
  }
  
  /**
   * O método atualizar() é a "inteligência" do balão, chamado a cada quadro (frame) do jogo.
   */
  void atualizar() {
    // Verifica se o balão está congelado e se já passou o tempo de acabar o congelamento.
    // millis() retorna o tempo (em milissegundos) desde que o programa começou a rodar.
    if (estaCongelado && millis() > tempoFimCongelamento) {
      estaCongelado = false; // Descongela o balão.
      this.velocidadeAtual = this.velocidadeBase; // Restaura a velocidade normal.
    }
    
    // LÓGICA DE MOVIMENTO: SÓ EXECUTA SE O BALÃO NÃO CHEGOU AO FIM DO CAMINHO.
    if (caminhoIndex < caminhoDosBaloes.size()) {
      // 1. Pega a coordenada do próximo ponto do caminho que ele precisa alcançar.
      PVector alvo = caminhoDosBaloes.get(caminhoIndex);
      
      // 2. Calcula o vetor de direção: (Ponto Final) - (Ponto Inicial).
      PVector direcao = PVector.sub(alvo, pos);
      
      // 3. Verifica se o balão já está "perto o suficiente" do alvo.
      // (usar magSq() é mais rápido que mag() porque evita uma raiz quadrada).
      if (direcao.magSq() < velocidadeAtual * velocidadeAtual) {
        // Se já chegou, avança para o próximo ponto do caminho.
        caminhoIndex++;
      } else {
        // 4. Se ainda não chegou, calcula o movimento para este quadro.
        direcao.normalize(); // Reduz o vetor para ter comprimento 1 (só nos importa a direção).
        direcao.mult(velocidadeAtual); // Aumenta o vetor para ter o comprimento da velocidade (distância a percorrer).
        pos.add(direcao); // Adiciona o vetor de movimento à posição atual do balão.
      }
    }
  }
  
    void desenhar() { 
    image(this.icon, this.pos.x, this.pos.y);
    
  }
  
  // Métodos de Ação e Verificação
  void receberDano(int dano) { this.vida -= dano; }
  boolean estaDestruido() { return this.vida <= 0; }
  boolean chegouAoFim() { return caminhoIndex >= caminhoDosBaloes.size(); }
  
  // Aplica o efeito de congelamento
  void aplicarCongelamento(long duracaoMs) {
    this.estaCongelado = true;
    this.velocidadeAtual = 0; // Para o balão.
    this.tempoFimCongelamento = millis() + duracaoMs; // Agenda o fim do congelamento.
  }
}


// ======================================================================
// SUBCLASSES - Define os atributos únicos de cada tipo de balão.
// A palavra "extends" significa que eles "herdam" tudo da classe Balao.
// ======================================================================

class BalaoAmarelo extends Balao {
  BalaoAmarelo() {
    super(); // É obrigatório chamar o construtor da classe "mãe" primeiro.
    // Define os atributos específicos deste balão.
    this.vida = 10;
    this.velocidadeBase = 1.0f;
    this.velocidadeAtual = this.velocidadeBase;
    this.valor = 5;
    this.icon = spritesBaloes.get("AMARELO");
    this.dano = 1;
  }
  
}

class BalaoAzul extends Balao {
  BalaoAzul() {
    super();
    this.vida = 15;
    this.velocidadeBase = 1.5f;
    this.velocidadeAtual = this.velocidadeBase;
    this.valor = 10;
    this.icon = spritesBaloes.get("AZUL");
    this.dano = 2;

  }
  

}

class BalaoVerde extends Balao {
  BalaoVerde() {
    super();
    this.vida = 20;
    this.velocidadeBase = 1.5f;
    this.velocidadeAtual = this.velocidadeBase;
    this.valor = 16;
    this.icon = spritesBaloes.get("VERDE");
    this.dano = 3;
  }
  

}

class BalaoCamuflado extends Balao {
  BalaoCamuflado() {
    super();
    this.vida = 10;
    this.velocidadeBase = 1.0f;
    this.velocidadeAtual = this.velocidadeBase;
    this.valor = 20;
    this.icon = spritesBaloes.get("CAMUFLADO");
    this.dano = 2;
    // HABILIDADES ESPECIAIS
    this.eCamuflado = true; // "Invisível" para a maioria das torres.
    this.imuneAGelo = true;   // Não pode ser congelado.
  }
  
  
}

class BalaoPreto extends Balao {
  BalaoPreto() {
    super();
    this.vida = 200; 
    this.velocidadeBase = 2.0f;
    this.velocidadeAtual = this.velocidadeBase;
    this.valor = 1000;
    this.icon = spritesBaloes.get("PRETO");
    this.dano = 100;

    // HABILIDADE ESPECIAL
    this.imuneAExplosoes = true; // Não leva dano de bombas.
    this.imuneAGelo = true;   // Não pode ser congelado.
  }
  
}
