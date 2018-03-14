class Utils {
 
  // Load neural network from a file.
  NeuralNetwork newNeuralNetworkFromFile() {
    NeuralNetwork nn;
    JSONObject obj = loadJSONObject("data/data.json");
    
    int inputNodes;
    int hiddenLayers;
    int[] hiddenNodes;
    int outputNodes;
    
    // Get the neural network parameters.
    inputNodes = obj.getInt("InputNodes");
    hiddenLayers = obj.getInt("HiddenLayers");
    hiddenNodes = obj.getJSONArray("HiddenNodes").getIntArray();
    outputNodes = obj.getInt("OutputNodes");
    
    nn = new NeuralNetwork(inputNodes, hiddenNodes, outputNodes, false);
    
    // Restore weights and biases.
    for (int i=0; i<hiddenLayers; i++) {
      nn.hiddenWeights[i] = newMatrixFromJSONObject(obj.getJSONObject("HiddenWeights-"+i));
      nn.hiddenBias[i] = newMatrixFromJSONObject(obj.getJSONObject("HiddenBias-"+i));
    }
    
    nn.outputWeights = newMatrixFromJSONObject(obj.getJSONObject("OutputWeights"));
    nn.outputBias = newMatrixFromJSONObject(obj.getJSONObject("OutputBias"));
    
    return nn;
  }
  
  // Save neural network object to a JSON format file.
  void saveNeuralNetworkObject(NeuralNetwork _nn) {
    JSONObject output = new JSONObject();
    
    // Save the neural network parameters.
    output.setInt("InputNodes", _nn.inputNodes);
    output.setInt("HiddenLayers", _nn.hiddenLayers);
    output.setJSONArray("HiddenNodes", serializeNeuralNetworkHiddenNodes(_nn));
    output.setInt("OutputNodes", _nn.outputNodes);
    
    // Go through all hidden layers, saving the respective weights and bias matrices.
    for (int i=0; i<_nn.hiddenLayers; i++) {
      output.setJSONObject("HiddenWeights-"+i, getMatrixAsJSONObject(_nn.hiddenWeights[i]));
      output.setJSONObject("HiddenBias-"+i, getMatrixAsJSONObject(_nn.hiddenBias[i]));
    }
    
    // Save the final ouput weights and bias.
    output.setJSONObject("OutputWeights", getMatrixAsJSONObject(_nn.outputWeights));
    output.setJSONObject("OutputBias", getMatrixAsJSONObject(_nn.outputBias));
    
    saveJSONObject(output, "data/data.json");
  }  
  
  JSONArray serializeNeuralNetworkHiddenNodes(NeuralNetwork _nn) {
    JSONArray hiddenNodesArray = new JSONArray();
    
    for (int k=0; k<_nn.hiddenNodes.length; k++) {
      hiddenNodesArray.append(_nn.hiddenNodes[k]);
    }
    
    return hiddenNodesArray;
  }  
  
  // Serialize a Matrix object into JSON format.
  JSONObject getMatrixAsJSONObject(Matrix _matrix) {
    JSONObject object = new JSONObject();
    JSONArray objectData = new JSONArray();
    
    object.setInt("rows", _matrix.rows);
    object.setInt("cols", _matrix.cols);
    
    for (int i=0; i<_matrix.rows; i++) {
      for (int j=0; j<_matrix.cols; j++) {
        objectData.append(_matrix.data[i][j]);
      }
    }
    
    object.setJSONArray("data", objectData);
    
    return object;
  }
  
  // De-serialize JSON format back to an object.
  Matrix newMatrixFromJSONObject(JSONObject _object) {    
    Matrix result = new Matrix(_object.getInt("rows"), _object.getInt("cols"));
    JSONArray objectData = _object.getJSONArray("data");
    
    for (int i=0; i<result.rows; i++) {
      for (int j=0; j<result.cols; j++) {
        result.data[i][j] = objectData.getFloat(j+(i*result.cols));
      }
    }
    
    return result;
  }  
}