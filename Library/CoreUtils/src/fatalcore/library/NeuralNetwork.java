package fatalcore.library;

import processing.core.*;

public class NeuralNetwork {
	int inputNodes;
	int hiddenLayers;
	int[] hiddenNodes;
	int outputNodes;
	
	Matrix[] hiddenWeights, hiddenBias;
	Matrix outputWeights, outputBias;

	float learningRate = (float) 0.05;

	boolean valid = false;
	boolean debug = true;

	public NeuralNetwork(int _inputNodes, int[] _hiddenNodes, int _outputNodes, boolean _init) {
		inputNodes = _inputNodes;
		hiddenLayers = _hiddenNodes.length;
		hiddenNodes = _hiddenNodes;
		outputNodes = _outputNodes;

		// Create array objects.
		hiddenWeights = new Matrix[hiddenLayers];
		hiddenBias = new Matrix[hiddenLayers];

		// Quick sanity check.
		if (inputNodes > 0 && hiddenLayers > 0 && outputNodes > 0) {
			valid = true;
			if (_init)
				initialize();
		}
	}

	public void initialize() {
		int previousLayerNodes;
		float limit;

		// Generate the weights and biases for the hidden layers.
		for (int i = 0; i < hiddenLayers; i++) {
			previousLayerNodes = i == 0 ? inputNodes : hiddenNodes[i - 1];
			hiddenWeights[i] = new Matrix(hiddenNodes[i], previousLayerNodes);
			hiddenBias[i] = new Matrix(hiddenNodes[i], 1);

			// Good random number range should be ± square root of nodes coming in this node.
			limit = previousLayerNodes > 0 ? 1 / (float) Math.sqrt(previousLayerNodes) : 1;
			hiddenWeights[i].randomize(limit);
			hiddenBias[i].randomize(limit);

			// Debug information.
			if (debug)
				System.out.println("Hidden [" + i + "] - Random limit: " + PApplet.nfc(limit, 4));
		}

		// Generate the weights and biases for the output layer based on the last hidden layer.
		previousLayerNodes = hiddenNodes[hiddenLayers - 1];
		outputWeights = new Matrix(outputNodes, previousLayerNodes);
		outputBias = new Matrix(outputNodes, 1);

		limit = previousLayerNodes > 0 ? 1 / (float) Math.sqrt(previousLayerNodes) : 1;
		outputWeights.randomize(limit);
		outputBias.randomize(limit);

		// Debug information.
		if (debug)
			System.out.println("Output - Random limit: " + PApplet.nfc(limit, 4));
	}

	public void train(float[] _inputArray, float[] _targetArray) {
		Matrix intermediate, output;
		Matrix gradient, delta, layerInputT, weightsT, error;
		Matrix[] hiddenOutput;

		// Convert input array to a Matrix.
		Matrix input = new Matrix(_inputArray);
		Matrix target = new Matrix(_targetArray);

		// Do feedforward routine to calculate the hidden layers output and final
		// output.
		intermediate = input;
		hiddenOutput = new Matrix[hiddenLayers];

		// Compute all hidden layers.
		for (int i = 0; i < hiddenLayers; i++) {
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
		gradient.activation(Matrix.Activation.SIGMOID, true);
		gradient.multiply(error);
		gradient.multiply(learningRate);

		layerInputT = hiddenOutput[hiddenLayers - 1].transpose();
		delta = gradient.dotProduct(layerInputT);

		// Adjust output weights and biases.
		outputWeights.add(delta);
		outputBias.add(gradient);

		// Tackle all hidden layers.
		for (int i = hiddenLayers - 1; i >= 0; i--) {
			// Get the hidden error.
			weightsT = (i == hiddenLayers - 1) ? outputWeights.transpose() : hiddenWeights[i + 1].transpose();
			error = weightsT.dotProduct(error);

			gradient = hiddenOutput[i];
			gradient.activation(Matrix.Activation.SIGMOID, true);
			gradient.multiply(error);
			gradient.multiply(learningRate);

			layerInputT = (i == 0) ? input.transpose() : hiddenOutput[i - 1].transpose();
			delta = gradient.dotProduct(layerInputT);

			hiddenWeights[i].add(delta);
			hiddenBias[i].add(gradient);
		}
	}

	public float[] predict(float[] _inputArray) {
		Matrix intermediate = new Matrix(_inputArray);

		// Compute all hidden layers.
		for (int i = 0; i < hiddenLayers; i++) {
			intermediate = computeLayer(intermediate, hiddenWeights[i], hiddenBias[i]);
		}

		// Work out final output layer and return it as an array.
		return computeLayer(intermediate, outputWeights, outputBias).toArray();
	}

	private Matrix computeLayer(Matrix _input, Matrix _weights, Matrix _bias) {
		Matrix layerOutput;

		layerOutput = _weights.dotProduct(_input);
		layerOutput.add(_bias);
		layerOutput.activation(Matrix.Activation.SIGMOID, false);

		return layerOutput;
	}

	public void setLearningRate(float _learningRate) {
		learningRate = _learningRate;
	}

	// Used for debugging purposes only.
	public void info() {
		for (int i = 0; i < hiddenLayers; i++) {
			System.out.println();
			System.out.println("Hidden weights [" + i + "]");
			hiddenWeights[i].info();
		}
		for (int i = 0; i < hiddenLayers; i++) {
			System.out.println();
			System.out.println("Hidden bias [" + i + "]");
			hiddenBias[i].info();
		}
		System.out.println();
		System.out.println("Output weights");
		outputWeights.info();
		System.out.println();
		System.out.println("Output bias");
		outputBias.info();
	}
}