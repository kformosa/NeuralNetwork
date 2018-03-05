// MNIST neural network 
// Author: Kevin Formosa (01/03/2018)
// Credit: Based on work done Daniel Shiffman - Toy Neural Network P5 (http://youtube.com/thecodingtrain)

// Neural network can have multiple hidden layers, defined in an array.

int[] trainLabels;
int[] trainImages;
int[] testLabels;
int[] testImages;

float[] inputs;
float[] targets;

static final float THRESHOLD = 0.5;

static final int imageWidth = 28;
static final int imageHeight = 28;
static final int imageLength = imageWidth * imageHeight;
static final int outputNodes = 10;
static final int trainingPerFrame = 200;
static final int testingPerFrame = 10;

NeuralNetwork nn;

int trainImage = 0;
int trainIterations = 1;

int[] trainImageValues = new int[imageLength];
int[] testImageValues = new int[imageLength];

int testImage = 0;
int testIterations = 1;
int testCount = 0;
int testCorrect = 0;

char guessedChar = ' ';
float confidence = 0;
float percent = 0.0;

PFont font;
boolean doTraining = true;
boolean autoChecks = false;
boolean manualCheck = false;

int[] loadFile(String _filename, int _offset, boolean _invert) {
  int value;
  int[] list;
  byte[] b = loadBytes(_filename);
  int len = b.length - _offset;
  
  list = new int[len];  
  for (int i=_offset; i<len+_offset; i++) {
    value = (int) b[i] & 0xFF;
    list[i-_offset] = (_invert) ? floor(map(value, 0, 255, 255, 0)) : value;
  }  
  return list;
}

float normalize(int _value) {
  return map(_value, 0, 255, 0.01, 0.98);
}

void loadMNIST() {
  trainLabels = loadFile("/data/train-labels-idx1-ubyte", 8, false);
  trainImages = loadFile("/data/train-images-idx3-ubyte", 16, false);
  
  testLabels = loadFile("/data/t10k-labels-idx1-ubyte", 8, false);
  testImages = loadFile("/data/t10k-images-idx3-ubyte", 16, false);
}

void resetTestingStats() {
  testImage = 0;
  testCorrect = 0;
  testCount = 0;
}

void drawImage(int[] _imageValues, int _offset) {
  for (int i=0; i<imageLength; i++) {
    fill(_imageValues[i]);
    rect(_offset+(i%imageWidth)*5,(i/imageWidth)*5,5,5);    
  }
}

void trainNetwork() {
  int value;
  
  // Define the inputs and display the training image.
  for (int i=0; i<imageLength; i++) {
    value = trainImages[i+(trainImage*imageLength)];
    trainImageValues[i] = value;
    inputs[i] = normalize(value);
  }     
  
  // Define the targets.
  for (int i=0; i<outputNodes; i++) {
    targets[i] = (i == trainLabels[trainImage]) ? 0.98 : 0.01; 
  }
  
  // Pass on to the neural network to train.
  nn.train(inputs, targets);
  
  trainImage++;

  // Check if reached end of training set.
  if (trainImage == trainLabels.length) {
    trainIterations++;
    trainImage = 0;    
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

void networkStatus() {
  float[] prediction;
  int value, guess;
  
  for (int i=0; i<imageLength; i++) {
    value = testImages[i+(testImage*imageLength)];
    testImageValues[i] = value;    
    inputs[i] = normalize(value);
  }
 
  prediction = nn.predict(inputs);
  guess = findMax(prediction);
  guessedChar = str(guess).charAt(0);
  confidence = (guess >= 0) ? prediction[guess] : -1;
  
  if (guess == testLabels[testImage]) {
    testCorrect++;
  }
  
  testCount++;
  testImage++;
  
  if (testImage == testLabels.length) {
    testIterations++;
    resetTestingStats();
  }
  
  percent = ((float) testCorrect / (float) testCount) * 100.0;
  
  manualCheck = false;
}

void resetAll() {
  // Debug information.
  println();
  println("Re-init of neural network...");
  
  trainImage = 0;
  trainIterations = 1;
  
  testIterations = 1;
  testImage = 0;
  testCorrect = 0;
  testCount = 0;
  percent = 0;
  
  nn.initialize();         
  
  doTraining = true;
  autoChecks = false;
}

void keyPressed() {
  switch (key) {
    case 't': 
      doTraining = ! doTraining;
      break;
      
    case 'a':
      autoChecks = ! autoChecks;
      break;
      
    case 'i':
      // Re-initialize the neural network with different random values.
      resetAll();
      break;
      
    case 'm':
      manualCheck = true;
      break;
      
    case 'r':
      resetTestingStats();
      break;
  }
}

void setup() {  
  size(370,400);  
  noStroke();
  font = createFont("Courier Bold", 12, true);
  textFont(font);
  
  loadMNIST();
  
  inputs = new float[imageLength];
  targets = new float[outputNodes];
  int[] hiddenLayers = { 32 };
  nn = new NeuralNetwork(imageLength, hiddenLayers, outputNodes, true);
}

void draw() {
  background(100);
  
  // Train the neural network.
  if (doTraining) {
    for (int i=1; i<=trainingPerFrame; i++) {
      trainNetwork();
    }
  }
  
  // Test and report the network performance.
  if (autoChecks && ! manualCheck) {
    for (int x=0; x<=testingPerFrame; x++) {
      networkStatus();
    }
  }   
  
  if (manualCheck) {
    autoChecks = false;
    networkStatus();
  }
  
  // Draw the current train and test images.
  drawImage(trainImageValues, 25);
  drawImage(testImageValues, 200);
   
  // Start checks automatically after the 5th training iteration.
  if (trainIterations == 5 && trainImage == 0) {
    autoChecks = true;
  }
    
  // Output information.
  fill(200);
  text("Iterations: " + trainIterations, 25, 180);
  text("Training image: " + trainImage, 25, 200);
  
  text("Guessed value: " + guessedChar, 200, 180);
  text("(" + nfc(confidence, 3) + ")", 300, 180);
  
  text("Test iterations: " + testIterations, 200, 220);  
  text("Image: " + testImage, 200, 240);
  text("Correct: " + testCorrect, 200, 260);
  text("Total: " + testCount, 200, 280);
  
  text("Accuracy: " + percent + " %", 200, 320);
  
  text("Keys:", 25, 360);
  text("  <t>rain, <a>utoCheck, <m>anualCheck, <r>esetTestStats,", 25, 375);
  text("  <i>nitNetwork", 25, 390);
}