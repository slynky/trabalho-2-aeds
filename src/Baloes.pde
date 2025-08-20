// Classe base para o Balão Amarelo, corrigida e completa
class BalaoAmarelo {
  int vida;
  int id; // ID único para cada balão, a ser definido na criação
  float velocidade;
  int valor;
  String perks;
  PImage icon;

  private BalaoAmarelo() {
    this.vida = 10;
    this.velocidade = 1.0f; // Usando float para consistência
    this.valor = 2;
    this.perks = null;
    this.icon = loadImage("resources/BalaoAmarelo.png");
  }
}

// Classe para o Balão Azul
class BalaoAzul {
  int vida;
  int id;
  float velocidade;
  int valor;
  String perks;
  PImage icon;

  private BalaoAzul() {
    this.vida = 15;
    this.velocidade = 1.5f;
    this.valor = 5;
    this.perks = null;
    this.icon = loadImage("resources/BalaoAzul.png");
  }
}

// Classe para o Balão Verde
class BalaoVerde {
  int vida;
  int id;
  float velocidade;
  int valor;
  String perks;
  PImage icon;

  private BalaoVerde() {
    this.vida = 20;
    this.velocidade = 1.5f;
    this.valor = 8;
    this.perks = null;
    this.icon = loadImage("resources/BalaoVerde.png");
  }
}

// Classe para o Balão Branco
class BalaoBranco {
  int vida;
  int id;
  float velocidade;
  int valor;
  String perks;
  PImage icon;

  private BalaoBranco() {
    this.vida = 10;
    this.velocidade = 1.0f;
    this.valor = 10;
    this.perks = "invisivel";
    this.icon = loadImage("resources/BalaoBranco.png");
  }
}

// Classe para o Balão Preto (Boss)
class BalaoPreto {
  int vida;
  int id;
  float velocidade;
  int valor;
  String perks;
  PImage icon;

  private BalaoPreto() {
    this.vida = 100;
    this.velocidade = 2.0f;
    this.valor = 200;
    this.perks = "boss";
    this.icon = loadImage("resources/BalaoPreto.png");
  }
}
