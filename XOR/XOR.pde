ArrayList inputs;
float[] outputs = { 0.01, 0.98, 0.98, 0.01 };
NeuralNetwork nn;

float x1, x2;
float[] inputArray = new float[2];
float[] resultArray;

int count;
PFont font;

static final int trainingPerFrame = 1000;

void setup() {  
  size(500, 500);
  noStroke();
  font = createFont("Courier Bold", 12, true);
  
  // Create a list of 4 training inputs.
  inputs = new ArrayList();
  float[] input = new float[2];
  input[0] = 0.01;
  input[1] = 0.01;
  inputs.add( (float[]) input.clone() );
  input[0] = 0.01;
  input[1] = 0.98;
  inputs.add( (float[]) input.clone() );
  input[0] = 0.98;
  input[1] = 0.01;
  inputs.add( (float[]) input.clone() );
  input[0] = 0.98;
  input[1] = 0.98;
  inputs.add( (float[]) input.clone() );
  
  // Create the neural network.
  int[] hiddenNodes = { 4, 4 };
  nn = new NeuralNetwork(2, hiddenNodes, 1, true);  
}

void keyPressed() {
  if (key == 'p') {
    println();
    println("Final weights and biases:");
    nn.info();
  }
}

void draw() {
  for (int i=0; i<=trainingPerFrame; i++) {
    int pick = int(random(inputs.size()));
    float[] input = (float[]) inputs.get(pick);
    float[] target = new float[1];
    target[0] = outputs[pick];
    // Train the puppy.
    nn.train(input, target);
    count++;
  }
  
  int resolution = 10;
  int rows = floor(height / resolution);
  int cols = floor(width / resolution);
  
  for (int i=0; i<rows; i++) {
    for (int j=0; j<cols; j++) {
      x1 = (float) i / rows;
      x2 = (float) j / cols;
      inputArray[0] = x1;
      inputArray[1] = x2;      
      resultArray = nn.predict(inputArray);
      fill(resultArray[0] * 255);
      rect(j*resolution, i*resolution, resolution, resolution); 
    }
  }
  
  // Calculate and display the status of the neural network.
  networkStatus();
  
  // Stop training after million iterations.
  if (count >= 1000000) {
    noLoop();
  }
}

void networkStatus() {  
  float mse = 0.0;
  float rmse;
  
  // Compute error for the current network status.
  for (int i=0; i<inputs.size(); i++) {
    float[] inp = (float[]) inputs.get(i);
    resultArray = nn.predict(inp);
    mse += sq(resultArray[0] - outputs[i]);    
  }
  
  rmse = sqrt(mse/4.0);
  
  textFont(font);
  fill(200);
  text("Total iterations: " + count, 10, 40);
  text("Root mean squared error: " + nfc(rmse,4), 10, 60);
  
}