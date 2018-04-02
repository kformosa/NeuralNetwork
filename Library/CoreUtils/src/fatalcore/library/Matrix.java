package fatalcore.library;

import processing.core.*;

public class Matrix {

	public enum Activation {
		SIGMOID,
		TANH
	}

	int rows;
	int cols;
	float[][] data; // Array of rows, each row having a number of columns.

	// Default constructor.
	public Matrix(int _rows, int _cols) {
		rows = _rows;
		cols = _cols;
		data = new float[rows][cols]; // Array is initialized with 0s.
	}

	// Another constructor to initialize values from a 1D array.
	public Matrix(float[] _array) {
		rows = _array.length;
		cols = 1;
		data = new float[rows][cols];
		for (int i = 0; i < _array.length; i++) {
			data[i][0] = _array[i];
		}
	}

	// Returns a 1D array of the matrix cells/values.
	public float[] toArray() {
		float[] array = new float[rows * cols];

		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				array[i * cols + j] = data[i][j];
			}
		}
		return array;
	}

	// Randomizing the matrix cells between a -ve and a +ve limit.
	public void randomize(float _limit) {
		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				data[i][j] = (float) Math.random() * (_limit * 2) - _limit; 
			}
		}
	}

	// Scalar addition.
	public void add(float _scalar) {
		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				data[i][j] += _scalar;
			}
		}
	}

	// Matrix addition.
	public void add(Matrix _other) {
		// Check if both matrices are compatible.
		if (rows != _other.rows || cols != _other.cols) {
			return;
		}

		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				data[i][j] += _other.data[i][j];
			}
		}
	}

	// Subtract using another matrix.
	public Matrix subtract(Matrix _other) {
		// Check if both matrices are compatible.
		if (rows != _other.rows || cols != _other.cols) {
			return null;
		}

		Matrix result = new Matrix(rows, cols);

		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				result.data[i][j] = data[i][j] - _other.data[i][j];
			}
		}
		return result;
	}

	// Returns a Transposed matrix.
	public Matrix transpose() {
		Matrix result = new Matrix(cols, rows);

		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				result.data[j][i] = data[i][j];
			}
		}
		return result;
	}

	// Returns a new matrix with the DOT Product of this matrix with another one.
	public Matrix dotProduct(Matrix _other) {
		// Check if both matrices are compatible.
		if (cols != _other.rows) {
			return null;
		}

		Matrix result = new Matrix(rows, _other.cols);

		for (int i = 0; i < result.rows; i++) {
			for (int j = 0; j < result.cols; j++) {
				// Perform the DOT Product.
				float sum = 0;
				for (int k = 0; k < cols; k++) {
					sum += data[i][k] * _other.data[k][j];
				}
				result.data[i][j] = sum;
			}
		}
		return result;
	}

	// Scalar multiplication.
	public void multiply(float _scalar) {
		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				data[i][j] *= _scalar;
			}
		}
	}

	// Matrix multiplication - also known as Hadamard Product.
	public void multiply(Matrix _other) {
		// Check if both matrices are compatible.
		if (rows != _other.rows || cols != _other.cols) {
			return;
		}

		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				data[i][j] *= _other.data[i][j];
			}
		}
	}

	// Map function per cell - used for the activation function.
	public void activation(Activation _activationFunc, boolean _derivative) {
		float value;

		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				value = data[i][j];

				switch (_activationFunc) {
					case SIGMOID:
						data[i][j] = sigmoid(value, _derivative);
						break;
					case TANH:
						data[i][j] = tanh(value, _derivative);
				}
			}
		}
	}
	
	// Sigmoid activation function and its derivative.
	float sigmoid(float _value, boolean _derivative) {
		return _derivative ? _value * (1 - _value) : 1 / (1 + (float) Math.exp(-_value));
	}

	// Tanh activation function and its derivative.
	float tanh(float _value, boolean _derivative) {
		return _derivative ? 1 - (_value * _value) : (float) Math.tanh(_value);
	}

	// Used for debugging purposes only.
	public void info() {
		for (float[] _rows : data) {
			for (float _n : _rows) {
				System.out.print(PApplet.nfc(_n, 4) + "\t");
			}
			System.out.println();
		}
	}
}