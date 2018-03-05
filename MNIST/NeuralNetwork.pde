class NeuralNetwork {
  int inputNodes;
  int hiddenLayers;
  int[] hiddenNodes;
  int outputNodes;
    
  Matrix[] hiddenWeights, hiddenBias;
  Matrix outputWeights, outputBias;
  
  static final int FUNC_SIGMOID = 1;
  static final int FUNC_TANH = 2;  
  
  float learningRate = 0.1;
  
  boolean valid = false;  
  boolean debug = true;
  
  NeuralNetwork(int _inputNodes, int[] _hiddenNodes, int _outputNodes, boolean _init) {
    inputNodes = _inputNodes;
    hiddenLayers = _hiddenNodes.length;
    hiddenNodes = _hiddenNodes;
    outputNodes = _outputNodes;
    
    // Quick sanity check.
    if (inputNodes > 0 && hiddenLayers > 0 && outputNodes > 0) {
      valid = true;      
      if (_init)
        initialize();
    }
  }
    
  void initialize() {
    int previousLayerNodes;
    float limit;    
    
    // Create array objects.    
    hiddenWeights = new Matrix[hiddenLayers];
    hiddenBias = new Matrix[hiddenLayers];
    
    // Generate the weights and biases for the hidden layers.
    for (int i=0; i<hiddenLayers; i++) {
      previousLayerNodes = i == 0 ? inputNodes : hiddenNodes[i-1];      
      hiddenWeights[i] = new Matrix(hiddenNodes[i], previousLayerNodes);
      hiddenBias[i] = new Matrix(hiddenNodes[i], 1);
      
      
      // Good random number range should be ± square root of nodes coming in this node.      
      limit = previousLayerNodes > 0 ? 1 / sqrt(previousLayerNodes) : 1;
      hiddenWeights[i].randomize(-limit, limit);
      hiddenBias[i].randomize(-limit, limit);
      
      // Debug information.
      if (debug) println("Hidden [" + i + "] - Random limit: " + nfc(limit, 4));
    }
    
    // Generate the weights and biases for the output layer based on the last hidden layer.
    previousLayerNodes = hiddenNodes[hiddenLayers - 1];
    outputWeights = new Matrix(outputNodes, previousLayerNodes); 
    outputBias = new Matrix(outputNodes, 1);
    
    limit = previousLayerNodes > 0 ? 1 / sqrt(previousLayerNodes) : 1;
    outputWeights.randomize(-limit, limit);
    outputBias.randomize(-limit,limit);
    
    // Debug information.
    if (debug) println("Output - Random limit: " + nfc(limit, 4));
  }
  
  void train(float[] _inputArray, float[] _targetArray) {       
    Matrix intermediate, output;
    Matrix gradient, delta, layerInputT, weightsT, error;
    Matrix[] hiddenOutput;    
    
    // Convert input array to a Matrix.
    Matrix input = new Matrix(_inputArray);
    Matrix target = new Matrix(_targetArray);
    
    // Do feedforward routine to calculate the hidden layers output and final output.
    intermediate = input;
    hiddenOutput = new Matrix[hiddenLayers];
    
    // Compute all hidden layers.
    for (int i=0; i<hiddenLayers; i++) {
       hiddenOutput[i] = computeLayer(intermediate, hiddenWeights[i], hiddenBias[i]);
       intermediate = hiddenOutput[i];
    }

    // Work out final output layer.
    output = computeLayer(intermediate, outputWeights, outputBias);       

    // Calculate error; Error = Target - Output.
    error = target.subtract(output);
    
    // First tackle the output layer.
    // Get the gradient using the derivative function, errors and learning rate.
    gradient = output;
    gradient.activation(FUNC_SIGMOID, true);
    gradient.multiply(error);
    gradient.multiply(learningRate);

    layerInputT = hiddenOutput[hiddenLayers-1].transpose();
    delta = gradient.dotProduct(layerInputT);
    
    // Adjust output weights and biases.
    outputWeights.add(delta);
    outputBias.add(gradient);
        
    // Tackle all hidden layers.        
    for (int i=hiddenLayers-1; i>=0; i--) {
      // Get the hidden error.
      weightsT = (i == hiddenLayers-1) ?  outputWeights.transpose() : hiddenWeights[i+1].transpose();
      error = weightsT.dotProduct(error);
      
      gradient = hiddenOutput[i];      
      gradient.activation(FUNC_SIGMOID, true);
      gradient.multiply(error);
      gradient.multiply(learningRate);
      
      layerInputT = (i == 0) ? input.transpose() : hiddenOutput[i-1].transpose();
      delta = gradient.dotProduct(layerInputT);
      
      hiddenWeights[i].add(delta);
      hiddenBias[i].add(gradient);
    }
  }
  
  float[] predict(float[] _inputArray) {     
    Matrix intermediate = new Matrix(_inputArray);
    
    // Compute all hidden layers.
    for (int i=0; i<hiddenLayers; i++) {
       intermediate = computeLayer(intermediate, hiddenWeights[i], hiddenBias[i]);
    }

    // Work out final output layer and return it as an array.
    return computeLayer(intermediate, outputWeights, outputBias).toArray();      
  }
  
  Matrix computeLayer(Matrix _input, Matrix _weights, Matrix _bias) {
    Matrix layerOutput;
    
    layerOutput = _weights.dotProduct(_input);
    layerOutput.add(_bias);
    layerOutput.activation(FUNC_SIGMOID, false);
    
    return layerOutput;
  }
  
  void setLearningRate(float _learningRate) {
    learningRate = _learningRate;
  }
  
  void info() {
    for (int i=0; i<hiddenLayers; i++) {
      println();      
      println("Hidden weights [" + i + "]");
      hiddenWeights[i].info();
    }    
    for (int i=0; i<hiddenLayers; i++) {
      println();      
      println("Hidden bias [" + i + "]");
      hiddenBias[i].info();
    }
    println();
    println("Output weights");
    outputWeights.info();
    println();
    println("Output bias");
    outputBias.info();    
  }
}