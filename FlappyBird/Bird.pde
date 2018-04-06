class Bird {
  float x;
  float y;
  int size;
  int gameHeight;

  int[] alpha = { 20, 80, 160, 200 }; 
  int[] sizeHistory = { 9, 12, 16, 18 };
  
  float velocity = 0;
  float gravity = 1;
  float lift = -30;
  
  boolean alive;  
  
  PGraphics gfx;
  FloatList posHistory = new FloatList();
  
  public Bird(int _gameHeight, PGraphics _gfx) {
    size = 20;    
    gfx = _gfx;
    gameHeight = _gameHeight;
    
    reset();
  }
  
  public void reset() {
    x = 160;
    y = gameHeight / 2;
    velocity = 0;
    alive = true;
  }
  
  public void up() {
    velocity += lift;
    velocity = constrain(velocity, -18, 15);
  }
  
  public void show() {
    gfx.beginDraw();
    
    gfx.background(0);
    gfx.noStroke();
    
    // Only draw trails if bird still alive.
    if (alive) {
      for (int i=0; i<posHistory.size(); i++) {      
        gfx.fill(255, alpha[i]);      
        gfx.ellipse(x, posHistory.get(i), sizeHistory[i], sizeHistory[i]);     
      }
    }
    
    gfx.fill(255, 255);
    gfx.ellipse(x, y, size, size);
    
    gfx.endDraw();
  }

  public void checkHealth() {       
    if (y > gameHeight) {
      y = gameHeight;
      velocity = 0;
      alive = false;
    }
  }
  
  public void update() {
    velocity += gravity;
    velocity *= 0.96;
    y += velocity;
    
    checkHealth();
    
    if (alive) {
      // Save up to 4 previous positions.
      posHistory.append(y);
      
      if (posHistory.size() > 4) {
        posHistory.remove(0);
      }
    }
  }
}