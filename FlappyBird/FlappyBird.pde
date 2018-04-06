final int gameWidth = 600;
final int gameHeight = 600;

boolean gameState = true;

PGraphics gfx;
Bird bird;

void drawBorder() {
  noFill();
  rect(1, 1, gameWidth, gameHeight-2);
}

void keyPressed() {
  switch (key) {
    case 'r':
      gameState = true;
      bird.reset();
      break;
      
    case ' ':
      if (gameState == true) {
        bird.up();
      }
      break;
  }
}

void setup() {
  size(800, 600);
  stroke(255);
  strokeWeight(2);
  
  gfx = createGraphics(600, 600);  
  bird = new Bird(gameHeight, gfx);
}

void draw() {
  if (gameState == true) {
    bird.update();
    
    if (! bird.alive) {
      gameState = false;
    }  
  }
  
  bird.show();  
  
  image(gfx,0,0);
  drawBorder();
}