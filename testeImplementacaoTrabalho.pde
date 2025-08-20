import java.util.HashMap;
import java.lang.Math;
HashMap<String, Integer> estadosCelulas;
/*
  
  Implementei o circulo para visualizar o raio de ataque da torre. Minha ideia foi que se 
          -Peace and Love
              Germannn
                                    (comment made at august 13, 18:25 GMT-3)
*/

//declaraçao de imagens 

PImage imgBlocoVermelho;
PImage imgGramaPedra;
PImage imgCaminho2;
PImage imgCaminho;
PImage imgGramaFlorBranca4;
PImage imgGramaFlorBranca2;
PImage imgGramaFlor;
PImage imgGrama;
PImage imgGrass;
int tamanhoCelula = 40;

void setup(){
  
  //Upload de imagens
  imgBlocoVermelho = loadImage("blocoVermelho.png");
  imgGramaPedra = loadImage("gramaPedra.png");
  imgCaminho2 = loadImage("caminho2.png");
  imgGramaFlorBranca2 = loadImage("gramaBranca2.png");
  imgCaminho = loadImage("caminho.png");
  imgGramaFlorBranca4 = loadImage("gramaBranca4.png");
  imgGrama = loadImage("Grama2.png");
  imgGrass = loadImage("Grass.png");
  imgGramaFlor = loadImage("gramaFlor.png");
  size(960, 640);
  estadosCelulas = new HashMap<String, Integer>();
  noLoop();

}

void draw(){

  background(#0CA71F);
  desenharGrade();
  //desenharCaminhoReto(0, 24, 10, 10);
  desenharCaminhoReto(3, 4, 0, 24);
  //desenharCaminhoDiagonal(7, 2, 12, true);
  //desenharCaminhoDiagonal(8, 2, 12, true);
  desenharCaminhoDiagonal(19, 4, 12, false);
  //desenharCaminhoDiagonal(7, 4, 20, true);
  desenharCaminhoDiagonal(8, 4, 20, true);
  desenharCirculo(23, 6, 5);
  desenharCirculo(2, 5, 7);
}

void desenharGrade(){

  
  
  
  int fimX = 23; // 0 até 23 (24 posições)
  int fimY = 15; //0 ate 15 (16 posições)
  
  for(int x = 0; x <= fimX; x++){
    for (int y = 0; y <= fimY; y++){
    
      float telaX = x * tamanhoCelula;
      float telaY = y * tamanhoCelula;
      
      String chave = x + "," + y;
      estadosCelulas.put(chave, 0);
      //fill(255);
      //rect(telaX, telaY, tamanhoCelula, tamanhoCelula);
      int escolhaGrama = (int)random(100);
      if(escolhaGrama % 5 == 0){
        image(imgGramaFlor, telaX, telaY, tamanhoCelula , tamanhoCelula );
      }else if(escolhaGrama % 87 == 0){
        image(imgGramaPedra, telaX, telaY, tamanhoCelula , tamanhoCelula );
      }else if(escolhaGrama % 56 ==0){
        image(imgGramaFlorBranca2, telaX, telaY, tamanhoCelula , tamanhoCelula );
      }else if(escolhaGrama % 57 == 0){
        image(imgGramaFlorBranca4, telaX, telaY, tamanhoCelula , tamanhoCelula );
      }else if(escolhaGrama % 3 == 0){
        image(imgGrama, telaX, telaY, tamanhoCelula , tamanhoCelula );
      }else{
        image(imgGrass, telaX, telaY, tamanhoCelula , tamanhoCelula );
      }
    }
  }
}

void desenharCaminhoReto(int xInicio, int xFim, int yInicio, int yFim){
  
  for(int x = xInicio; x <= xFim; x++){
    for(int y = yInicio; y <= yFim; y++){
      
      float telaX = x * tamanhoCelula;
      float telaY = y * tamanhoCelula;
    
    
      String chave = x + "," + y;
      estadosCelulas.put(chave, 1);
      
      int escolhaCaminho = (int) random(100);
      if(escolhaCaminho % 2 == 0 || escolhaCaminho % 3 == 0){
        image(imgCaminho, telaX, telaY, tamanhoCelula, tamanhoCelula);
      }else{
        image(imgCaminho2, telaX, telaY, tamanhoCelula, tamanhoCelula);
      } 
    }
  }
}

void desenharCaminhoDiagonal(int xInicio, int yInicio, int tamanho, boolean crescente) {
    for (int i = 0; i < tamanho; i++) {
        int x = xInicio + i;
        int y;
        
        if (crescente) {
            y = yInicio + i;
        } else {
            y = yInicio - i;
        }

        if (x >= 0 && x <= 24 && y >= 0 && y <= 24) {
            float telaX = x * tamanhoCelula;
            float telaY = y * tamanhoCelula;

            String chave = x + "," + y;
            estadosCelulas.put(chave, 1);

            int escolhaCaminho = (int) random(100);
            if (escolhaCaminho % 2 == 0 || escolhaCaminho % 3 == 0) {
                image(imgCaminho, telaX, telaY, tamanhoCelula, tamanhoCelula);
            } else {
                image(imgCaminho2, telaX, telaY, tamanhoCelula, tamanhoCelula);
            }
        }
    }
}

void desenharCirculo(int centroX, int centroY, int raio) {
  raio-=1;
  for (int y = -raio; y <= raio; y++) {
    for (int x = -raio; x <= raio; x++) {
      if (x * x + y * y <= raio * raio) {
        int celulaX = centroX + x;
        int celulaY = centroY + y;

        
        if (celulaX >= 0 && celulaX <= 23 && celulaY >= 0 && celulaY <= 15) {
          float telaX = celulaX * tamanhoCelula;
          float telaY = celulaY * tamanhoCelula;

          String chave = celulaX + "," + celulaY;
          int valorAnterior = estadosCelulas.get(chave);
          
          if(valorAnterior == 1){
            estadosCelulas.put(chave, 2);
          }else{
            estadosCelulas.put(chave, 3);
          }
          
          /*Explicaçao:
          
          O programa vai ver qual era o estado que estava presente no lugar. Caso for 1 (ou seja, com um caminho), ele vai setar o valor pata 2, 
          o que signifacara para implementaçoes futuras que
          o caminho eh acessivel porem esta sujeito a ataques das torres. Entretanto, se for outro valor, ele vai continuar inacessivel e passivel de ataques.
          Foi o jeito mais simples de resolver
          esse problema.
          */
          
          
          //Usado apenas para visualizaçao
          image(imgBlocoVermelho, telaX, telaY, tamanhoCelula, tamanhoCelula);
        }
      }
    }
  }
}
