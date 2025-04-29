// added millis to control flower growth interval and hue
ArrayList<Flower> flowers = new ArrayList<Flower>();
int flowerCount = 180;
boolean isGrowing = false;
float growthSpeed = 0.3; // base growth speed
float minDistance = 60; // pixel space between each bud

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 1);
  noStroke();
  
  // flower buds placement only
  for (int i = 0; i < flowerCount; i++) {
    Flower newFlower;
    boolean validPosition = false;
    int attempts = 0;
    
    // keep trying for valid or stop after 100 tries
    while (!validPosition && attempts < 100) {
      newFlower = new Flower();
      validPosition = distanceChecker(newFlower, flowers);
      attempts++;
      if (validPosition || flowers.size() == 0) {
        flowers.add(newFlower);
      }
    }
  }
}

// needed a little help converting from javascript
// array to java array: https://www.w3schools.com/java/java_arrays_loop.asp
// distance checking function
boolean distanceChecker(Flower newFlower, ArrayList<Flower> existingFlowers) {
  for (Flower flower : existingFlowers) {
    float d = dist(newFlower.x, newFlower.y, flower.x, flower.y);
    if (d < minDistance) {
      return false; // too close to grow
    }
  }
  return true; // its good to grow
}

void draw() {
  background(104, 100, 40);
  
  if (isGrowing == true) {
    float timing = millis();
    for (Flower flower : flowers) {
      if (!flower.growthStarted && timing > flower.growthDelay) {
        flower.growthStarted = true;
      }
      if (flower.growthStarted && flower.size < flower.targetSize) {
        flower.size += flower.individualSpeed;
      }
    }
  }
  
  for (Flower flower : flowers) {
    flower.display();
  }
  
  fill(0);
  text("Click to make flowers grow", 10, 20);
}

void mousePressed() {
  isGrowing = true;
}

// flower class w parameters
class Flower {
  float x, y;
  float size;
  float targetSize;
  float hue;
  int petalCount;
  float rotation;
  float petalLength;
  float petalWidth;
  float growthDelay;
  boolean growthStarted;
  float individualSpeed;
  
  Flower() {
    x = random(width);
    y = random(height);
    size = 1;
    targetSize = random(40, 78);
    hue = random(0, 360);
    petalCount = floor(random(8, 18));
    rotation = random(TWO_PI);
    petalLength = random(0.8, 2.5);
    petalWidth = random(0.7, 1.3);
    growthDelay = random(500, 3500);
    growthStarted = false;
    individualSpeed = random(0.1, 0.8);
  }
  
  void display() {
    pushMatrix();
    translate(x, y);
    rotate(rotation);
    
    float timing = millis() * 0.005;
    
    for (int i = 0; i < petalCount; i++) {
      float angle = TWO_PI / petalCount * i;
      pushMatrix();
      rotate(angle);
      
      float hueVariation, satVariation, briVariation;
      
      if (size < targetSize) {
        hueVariation = sin(timing + x * 0.01 + y * 0.01) * 15;
        satVariation = cos(timing + x * 0.01) * 5;
        briVariation = sin(timing + y * 0.01) * 5;
      } else {
        hueVariation = sin(timing + x * 0.01 + y * 0.01) * 2;
        satVariation = cos(timing + x * 0.01) * 1;
        briVariation = sin(timing + y * 0.01) * 2;
      }
      
      fill(
        (hue + hueVariation + 360) % 360,
        70 + satVariation,
        90 + briVariation,
        0.8
      );
      
      beginShape();
      vertex(0, 0);
      bezierVertex(
        size * 0.3 * petalWidth, size * 0.2,
        size * 0.7 * petalWidth, size * 0.3 * petalLength,
        size * petalWidth, 0
      );
      bezierVertex(
        size * 0.7 * petalWidth, -size * 0.3 * petalLength,
        size * 0.3 * petalWidth, -size * 0.2, 0, 0
      );
      endShape();
      
      popMatrix();
    }
    
    // flower center
    fill((hue + 30) % 360, 90, 80);
    ellipse(0, 0, size * 0.4, size * 0.4);
    
    popMatrix();
  }
}
