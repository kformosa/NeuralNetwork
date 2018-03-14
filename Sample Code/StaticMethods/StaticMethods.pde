void setup() {
  MyClass obj = new MyClass();
  println(obj.guessNumber()); 
  
  MyClass other = MyClass.getObj();
  println(other.getResult());
}

static class MyClass {
  int val = 5;
  int result = 10;
  
  int getResult() {
    return result;
  }
  
  float guessNumber() {
    // Workaround to get a random number between -0.5 and 0.5.
    // Cannot use random() in a static class :(
    return (float) Math.random() * 1 - 0.5;
  }
  
  static MyClass getObj() {
    MyClass _obj = new MyClass();
    _obj.result = 15;
    return _obj;
  }
}