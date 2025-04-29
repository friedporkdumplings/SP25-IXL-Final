// added distance check parameter to limit
// overlapping flowers 
let flowers = [];
let flowerCount = 80;
let isGrowing = false;
let growthSpeed = (0.3,0.8);
let minDistance = 60; // pixel space between each bud

function setup() {
  createCanvas(800, 600);
  colorMode(HSB, 360, 100, 100, 1);
  noStroke();
  
  // flower buds placement only
  // after distance checked for minimal overlap
  for (let i = 0; i < flowerCount; i++) {
    let newFlower;
    let validPosition = false;
    let attempts = 0;
    
    // keep trying for valid or stop after 100 tries
    while (!validPosition && attempts < 100) {
      newFlower = {
        x: random(width),
        y: random(height),
        size: 1,
        targetSize: random(40, 78),
        hue: random(0, 360),
        petalCount: floor(random(8, 18)),
        rotation: random(TWO_PI),
        petalLength: random(0.8, 2.5),
        petalWidth: random(0.7, 1.3)
      };
      
      validPosition = distanceChecker(newFlower, flowers);
      attempts++;
    }
    
    if (validPosition || flowers.length === 0) {
      flowers.push(newFlower);
    }
  }
}

// distance checking function
function distanceChecker(newFlower, existingFlowers) {
  for (let flower of existingFlowers) {
    let d = dist(newFlower.x, newFlower.y, flower.x, flower.y);
    if (d < minDistance) {
      return false; // too close to grow
    }
  }
  return true; // its good to grow
}

function draw() {
  background(104, 100, 40);
  
  // grow flowers if growing == true
  if (isGrowing) {
    for (let flower of flowers) {
      if (flower.size < flower.targetSize) {
        flower.size += growthSpeed;
      }
    }
  }
  
  // draw all flowers
  for (let flower of flowers) {
    drawFlower(flower);
  }
  
  fill(0);
  text("Click to make flowers grow", 10, 20);
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

    if (flower.size < flower.targetSize) {
      hueVariation = random(-20, 20);
      satVariation = random(-10, 10);
      briVariation = random(-10, 10);
    } else {
      hueVariation = random(-1, 1);
      satVariation = random(-0.5,0.5);
      briVariation = random(-2, 2);
    }

    // different petal colors
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
      flower.size * flower.petalWidth, 
      0
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
  
  // flower center
  fill(
    (flower.hue + 30) % 360, 90, 80
  );
  circle(0, 0, flower.size * 0.4);
  
  pop();
}

function mousePressed() {
  isGrowing = true;
}