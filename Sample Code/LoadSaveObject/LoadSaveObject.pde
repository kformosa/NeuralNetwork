int rows;
int cols;
int[][] data;

void draw() {
  loadObject();
  noLoop();
}

void loadObject() {
  JSONObject wholeObject;
  wholeObject = loadJSONObject("data/data.json");
  setFromObject(wholeObject.getJSONObject("Hidden"));  
  printArray(data[2]);
}

void saveObject() {
  JSONObject output = new JSONObject();
  output.setJSONObject("Hidden", getAsObject());
  saveJSONObject(output, "data/data.json");  
}

void setFromObject(JSONObject _obj) {
  JSONArray objData;
  
  rows = _obj.getInt("rows");
  cols = _obj.getInt("cols");
  
  data = new int[rows][cols];
  objData = _obj.getJSONArray("data");
  
  for (int i=0; i<rows; i++) {
    for (int j=0; j<cols; j++) {
      data[i][j] = objData.getInt(j+(i*cols));
    }
  }
}

JSONObject getAsObject() {  
  JSONObject object;
  JSONArray objData;
  
  int count = 0;
  
  rows = 2;
  cols = 2;
  data = new int[rows][cols];
  
  for (int i=0; i<rows; i++) {
    for (int j=0; j<cols; j++) {
      data[i][j] = count;
      count++;
    }
  }  
  
  object = new JSONObject();
  object.setInt("rows", rows);
  object.setInt("cols", cols);
  
  objData = new JSONArray();
  for (int i=0; i<rows; i++) {
    for (int j=0; j<cols; j++) {
      objData.append(data[i][j]);
    }
  }
  
  object.setJSONArray("data", objData);
  return object;
}