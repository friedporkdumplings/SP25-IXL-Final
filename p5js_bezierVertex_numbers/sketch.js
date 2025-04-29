function setup() {
  createCanvas(400, 400);
}

function draw() {
  background(220);
  translate(width/2, height/2); 
  
  // draw petal
  fill(255);
  stroke(0);
  beginShape();
  vertex(0, 0);
  bezierVertex(30, 20, 70, 30, 100, 0);
  bezierVertex(70, -30, 30, -20, 0, 0);
  endShape();
  
  // center reference line
  stroke(255, 0, 0);
  strokeWeight(2);
  line(-120, 0, 120, 0);
  strokeWeight(1);
}