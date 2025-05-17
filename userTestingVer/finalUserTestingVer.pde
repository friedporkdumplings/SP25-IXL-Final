// code appendix:
// https://processing.org/tutorials/arrays
// https://happycoding.io/tutorials/processing/creating-classes
// https://processing.org/reference/bezierVertex_.html
// https://p5js.org/reference/p5/bezierVertex/

// different states
boolean isDark = true;
boolean isDarkGreen = false;
boolean flowersGrowing = false;
boolean flowersBloomed = false;
boolean butterflies = false;

// flower array
Flower[] flowers;
int flowerCount = 165;
float minDistance = 60;

// butterfly array
Butterfly[] butterfliesArray;
int butterflyCount = 5;

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 1);
  noStroke();
  smooth();

  // initialize arrays
  // reference: https://processing.org/tutorials/arrays
  flowers = new Flower[flowerCount];
  butterfliesArray = new Butterfly[butterflyCount];

  initializeFlowers();
  initializeButterflies();
}

void initializeFlowers() {
  for (int i = 0; i < flowerCount; i++) {
    boolean validPosition = false;
    int attempts = 0;

    while (!validPosition && attempts < 100) {
      Flower newFlower = new Flower();
      validPosition = true;

      // check distance for new
      // against existing flowers
      for (int j = 0; j < i; j++) {
        if (flowers[j] != null &&
          dist(newFlower.x, newFlower.y, flowers[j].x, flowers[j].y) < minDistance) {
          validPosition = false;
          break;
        }
      }

      if (validPosition) {
        flowers[i] = newFlower;
      }
      attempts++;
    }
  }
}

void initializeButterflies() {
  for (int i = 0; i < butterflyCount; i++) {
    butterfliesArray[i] = new Butterfly();
  }
}

void draw() {
  // switch between diff states
  if (isDark) {
    background(0);
  } else if (isDarkGreen) {
    background(104, 100, 20);
  } else if (flowersGrowing || flowersBloomed) {
    background(104, 100, 40);
    if (flowersGrowing) {
      updateFlowers();
    }
    displayFlowers();

    if (butterflies) {
      updateButterflies();
      displayButterflies();
    }
  } else if (butterflies) {
    background(104, 100, 60);
    displayFlowers();
    updateButterflies();
    displayButterflies();
  }

  // for debugging hide later display current mode
  fill(255);
  textSize(30);
  text("Current Mode: " + getCurrentMode(), 20, 30);
  text("(Arduino Signal Simulator w/ Keys 1-4)", 20, 60);
}

void updateFlowers() {
  float timing = millis();
  boolean allBloomed = true;

  for (int i = 0; i < flowerCount; i++) {
    if (flowers[i] != null) {
      Flower f = flowers[i];
      if (!f.growthStarted && timing > f.growthDelay) {
        f.growthStarted = true;
      }
      if (f.growthStarted && f.size < f.targetSize) {
        f.size += f.individualSpeed;
      }
      if (f.size < f.targetSize) {
        allBloomed = false;
      }
    }
  }

  if (allBloomed) {
    flowersGrowing = false;
    flowersBloomed = true;
  }
}

void displayFlowers() {
  for (int i = 0; i < flowerCount; i++) {
    if (flowers[i] != null) {
      flowers[i].display();
    }
  }
}

void updateButterflies() {
  for (int i = 0; i < butterflyCount; i++) {
    if (butterfliesArray[i] != null) {
      butterfliesArray[i].update();
    }
  }
}

void displayButterflies() {
  for (int i = 0; i < butterflyCount; i++) {
    if (butterfliesArray[i] != null) {
      butterfliesArray[i].display();
    }
  }
}

String getCurrentMode() {
  if (isDark) return "Dark";
  if (isDarkGreen) return "Dark Green";
  if (flowersGrowing && butterflies) return "Flowers Growing + Butterflies";
  if (flowersGrowing) return "Flowers Growing";
  if (flowersBloomed && butterflies) return "Flowers Bloomed + Butterflies";
  if (flowersBloomed) return "Flowers Bloomed";
  if (butterflies) return "Butterflies";
  return "Unknown";
}

void keyPressed() {
  if (key == '1' && isDark) {
    isDark = false;
    isDarkGreen = true;
  } else if (key == '2' && isDarkGreen) {
    isDarkGreen = false;
    flowersGrowing = true;
  } else if (key == '3' && (flowersGrowing || flowersBloomed)) {
    butterflies = !butterflies;
  } else if (key == '4') {
    resetAll();
  }
}

void resetAll() {
  isDark = true;
  isDarkGreen = false;
  flowersGrowing = false;
  flowersBloomed = false;
  butterflies = false;

  // reset flowers
  for (int i = 0; i < flowerCount; i++) {
    if (flowers[i] != null) {
      flowers[i].size = 1;
      flowers[i].growthStarted = false;
    }
  }

  // reset butterflies
  for (int i = 0; i < butterflyCount; i++) {
    if (butterfliesArray[i] != null) {
      butterfliesArray[i].reset();
    }
  }
}

// main flower animation class w/all properties
// class reference code https://happycoding.io/tutorials/processing/creating-classes
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
    petalCount = floor(random(8, 11));
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

      // for gradient color effect using hsb color values:
      // hue variation (color changes)
      float hueVariation;
      if (size < targetSize) {
        hueVariation = sin(timing + x * 0.01 + y * 0.01) * 15;
      } else {
        hueVariation = sin(timing + x * 0.01 + y * 0.01) * 2;
      }
      // saturation variation (color intensity)
      float satVariation;
      if (size < targetSize) {
        satVariation = cos(timing + x * 0.01) * 5; 
      } else {
        satVariation = cos(timing + x * 0.01) * 1;
      }
      // brightness variation (light/dark changes)
      float briVariation;
      if (size < targetSize) {
        briVariation = sin(timing + y * 0.01) * 5;
      } else {
        briVariation = sin(timing + y * 0.01) * 2;
      }

      fill(
        (hue + hueVariation + 360) % 360,
        70 + satVariation,
        90 + briVariation,
        0.8
        );

      // https://processing.org/reference/bezierVertex_.html
      // https://p5js.org/reference/p5/bezierVertex/
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

    // flower center peice
    fill((hue + 30) % 360, 90, 80);
    ellipse(0, 0, size * 0.4, size * 0.4);

    popMatrix();
  }
}

class Butterfly {
  float x, y;
  float speedX, speedY;
  float size;
  color bodyColor;

  Butterfly() {
    reset();
  }

  void reset() {
    x = random(width);
    y = random(height);

    // random diagonal speed
    float speed = random(2, 4);
    float angle = random(TWO_PI); // random direction
    speedX = cos(angle) * speed;
    speedY = sin(angle) * speed;

    size = random(80, 120);
    bodyColor = color(255);
  }

  void update() {
    x += speedX;
    y += speedY;

    // wrap around edges
    if (x < 0) x = width;
    if (x > width) x = 0;
    if (y < 0) y = height;
    if (y > height) y = 0;
  }

  void display() {
    noStroke();
    // REPLACE WITH IMAGES LATER
    fill(bodyColor);
    ellipse(x, y, size, size);
  }
}
