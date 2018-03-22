NeuralNetwork nn;
Utils utils = new Utils();
int prevX, prevY;
PGraphics pg;
PImage tn;
PFont font;

int[] testImages;
int testImage;
int[] imageValues = new int[784]; // Size of a 28 x 28 image.
float[] inputs = new float[784];
float[] prediction;

float confidence = 0;
char guessedChar = ' ';

static final float THRESHOLD = 0.5;

void loadTestImages() {
  int value;
  byte[] b = loadBytes("data/images");
  int len = b.length - 16;
  
  testImages = new int[len];
  
  for (int i=16; i<len+16; i++) {
    value = (int) b[i] & 0xFF;
    testImages[i-16] = value;
  }  
}

void keyPressed() {
  switch (key) {
    case 'c':
      pg.beginDraw();
      pg.background(0);
      pg.endDraw();
      break;
      
    case 'i':
      test(true);
      break;
      
    case 't':
      test(false);
      break;
  }  
}

int findMax(float[] _list) {
  float record = 0;
  int index = 0;
  int aboveAverage = 0;
  
  for (int m=0; m<_list.length; m++) {
    if (_list[m] > record) {
      record = _list[m];
      index = m;
    }
    aboveAverage += (_list[m] > THRESHOLD) ? 1 : 0;
  }
  
  // More than 1 node over threshold (0.5) is not valid either.
  return (aboveAverage > 1) ? -1 : index; 
}

void test(boolean _useImages) {
  int bright;
  int guess;
  
  if (_useImages) {
    for (int i=0; i<784; i++) {
      bright = testImages[i+(testImage*784)];
      imageValues[i] = bright;    
      inputs[i] = map(bright, 0, 255, 0.01, 0.98);
    }
    testImage++;
  }
  else {
    tn = pg.get();
    tn.resize(28,28);  
    tn.loadPixels();
    
    for (int i=0; i<784; i++) {
      bright = int(brightness(tn.pixels[i]));
      imageValues[i] = bright;
      inputs[i] = map(bright, 0, 255, 0.01, 0.98);
    }
  }
  
  prediction = nn.predict(inputs);
  guess = findMax(prediction);
  guessedChar = str(guess).charAt(0);
  confidence = (guess >= 0) ? prediction[guess] : -1;
}

void mouseDragged() {
  pg.beginDraw();
  pg.stroke(255);
  pg.strokeWeight(16f);
  pg.line(pmouseX, pmouseY, mouseX, mouseY);
  pg.endDraw();
}

void setup() {
  size(800, 400);
 
  font = createFont("Courier Bold", 12, true);
  textFont(font);
 
  loadTestImages();
  nn = utils.newNeuralNetworkFromFile("94-99.json");
    
  pg = createGraphics(400, 400);
}

void draw() {
  background(0);
  
  // Draw divider line.
  stroke(255);
  strokeWeight(1);
  line(400,0, 400, 400);
      
  // Draw user digit.
  image(pg, 0, 0);
  
  noStroke();
  
  // Draw scaled down digit.
  for (int i=0; i<784; i++) {
    fill(imageValues[i]);
    rect(420+(i%28)*5,(i/28)*5,5,5);        
  }
  
  // Output prediction.
  fill(200);
  text("Guessed value: " + guessedChar, 430, 180);
  text("(" + nfc(confidence, 3) + ")", 530, 180);  
}