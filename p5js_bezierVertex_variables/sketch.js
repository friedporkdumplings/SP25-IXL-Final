let petalWidth = 100;
let petalHeight = 30;
let size = 1.0;

function setup() {
  createCanvas(400, 400);
}

function draw() {
  background(220);

  // w variables 
  beginShape();
  vertex(0, 0);
  bezierVertex(
    0.3 * petalWidth * size,
    0.2 * petalHeight * size,
    0.7 * petalWidth * size,
    0.3 * petalHeight * size,
    petalWidth * size, 0
  );
  bezierVertex(
    0.7 * petalWidth * size,
    -0.3 * petalHeight * size,
    0.3 * petalWidth * size,
    -0.2 * petalHeight * size, 0, 0
  );
  endShape();
}
