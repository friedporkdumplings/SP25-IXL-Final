let flower; 
let isGrowing = false;
let growthSpeed = 0.5;  

function setup() {
  createCanvas(800, 600);
  colorMode(HSB, 360, 100, 100, 1);
  noStroke();
  
  // flower all properties
  flower = {
    x: width/2,
    y: height/2,
    size: 1, 
    targetSize: random(50, 130), 
    hue: random(0, 360),
    petalCount: floor(random(8, 18)),
    rotation: random(TWO_PI),
    petalLength: random(0.8, 2.5),
    petalWidth: random(0.7, 1.3)
  };
}

function draw() {
  background(104, 100, 40);
  
  // grow boolean
  if (isGrowing) {
    if (flower.size < flower.targetSize) {
      flower.size += growthSpeed;
    }
  }
  
  drawFlower(flower);
  
  fill(255);
  text("[Click to make flower grow]", 20, 40);
  textSize(15);
}

function drawFlower(flower) {
  push();
  translate(flower.x, flower.y);
  rotate(flower.rotation);
  
  // draw petals
  for (let i = 0; i < flower.petalCount; i++) {
    const angle = TWO_PI / flower.petalCount * i;
    
    push();
    rotate(angle);

    let hueVariation;
    let satVariation;
    let briVariation;

    // flower size and color
    if (flower.size < flower.targetSize) {
      hueVariation = random(-20, 20);
      satVariation = random(-10, 10);
      briVariation = random(-10, 10);
    } else {
      hueVariation = random(-1, 1);
      satVariation = random(-0.5,0.5);
      briVariation = random(-2, 2);
    }

    fill(
      (flower.hue + hueVariation) % 360,
      70 + satVariation,
      90 + briVariation,
      0.8
    );

    // beziervertex petals
    beginShape();
    vertex(0, 0);
    bezierVertex(
      flower.size * 0.3 * flower.petalWidth, 
      flower.size * 0.2,
      flower.size * 0.7 * flower.petalWidth, 
      flower.size * 0.3 * flower.petalLength,
      flower.size * flower.petalWidth, 0
    );
    bezierVertex(
      flower.size * 0.7 * flower.petalWidth, 
      -flower.size * 0.3 * flower.petalLength,
      flower.size * 0.3 * flower.petalWidth, 
      -flower.size * 0.2, 0, 0
    );
    endShape();
    
    pop();
  }
  
  // // center
  // fill(
  //   (flower.hue + 30) % 360,
  //   90,
  //   80
  // );
  // circle(0, 0, flower.size * 0.4);
  
  pop();
}

function mousePressed() {
  isGrowing = true;
}