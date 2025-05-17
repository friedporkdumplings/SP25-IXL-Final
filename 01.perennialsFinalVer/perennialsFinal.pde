// load this version for the final

import processing.serial.*;
import processing.sound.*;
SoundFile natureSound;
SoundFile rainSound;
SoundFile sparkleSound;
SoundFile cricketSound;

boolean isNatureSoundPlaying = false;
boolean isRainSoundPlaying = false;
boolean isCricketSoundPlaying = false;
boolean soundsLoaded = false;

Serial serialPort;

int NUM_OF_VALUES_FROM_ARDUINO = 3;  /* CHANGE THIS ACCORDING TO YOUR PROJECT */

/* This array stores values from Arduino */
int arduino_values[] = new int[NUM_OF_VALUES_FROM_ARDUINO];


// different states
boolean isDark = true;
boolean isSunlight = false;
boolean isWatered = false;
boolean isPollinated = false;

// flower array
Flower[] flowers;
int flowerCount = 300;
int currentFlowers = 0;
float minDistance = 60;

// timing variables
int wateringStartTime = 0;
int lastWateringTrigger = 0;
int pollinationStartTime = 0;
final int WATERING_DURATION = 6000; // 6 seconds watering effect
final int RAIN_DURATION = 2000; // 2 seconds for rain to disappear
final int FLOWER_LIFETIME = 8000; // 6 seconds for flowers to disappear
final int POLLEN_DURATION = 1000; // 1 second for pollen to disappear

// rain variables
Drop[] drops;
int dropCount = 200;
boolean rainActive = false;

// pollen particles
Pollen[] pollenParticles;
int pollenCount = 100;
int activePollen = 0;
boolean showPollen = false;
int lastPollenTime = 0;
int lastShakeTime = 0;


// ispollinated flower spawning shake effect
int previousPollenValue = 0;       // the last pollen reading
int lastPollinationTime = 0;       // the last trigger time
int POLLEN_COOLDOWN = 500;        // 500ms cooldown to prevent spazzing
int POLLEN_THRESHOLD = 60;

// for a smooth gradient lerp background transition
float bgLerpValue = 0;
final float BG_LERP_SPEED = 0.02;



void setup() {
  fullScreen();
  colorMode(HSB, 360, 100, 100, 1);
  noStroke();
  smooth();

  // initialize flowers
  flowers = new Flower[flowerCount];
  for (int i = 0; i < flowerCount; i++) {
    flowers[i] = null;
  }

  // initialize rain drops
  drops = new Drop[dropCount];
  for (int i = 0; i < dropCount; i++) {
    drops[i] = new Drop();
  }

  // initialize pollen particles
  pollenParticles = new Pollen[pollenCount];
  for (int i = 0; i < pollenCount; i++) {
    pollenParticles[i] = new Pollen();
  }

  // initialize sounds
  natureSound = new SoundFile(this, "natureSound.mp3");
  rainSound = new SoundFile(this, "rainSound.mp3");
  sparkleSound = new SoundFile(this, "sparkleSound.mp3");
  cricketSound = new SoundFile(this, "cricketSound.mp3");

  println("Waiting for Arduino data...");
  printArray(Serial.list());
  // put the name of the serial port your Arduino is connected
  // to in the line below - this should be the same as you're
  // using in the "Port" menu in the Arduino IDE
  serialPort = new Serial(this, "COM5", 9600);
}

void draw() {
  // get values from Arduino
  getSerialData();

  println("Arduino Values - Light: " + arduino_values[0] +
    ", Water: " + arduino_values[1] +
    ", Pollen: " + arduino_values[2]);

  // states based on sensor signal data
  updateStates();

  // background transition if the conditions set below are met
  updateBackground();

  // scene switchers
  if (isDark) {
    // Background handled by updateBackground()
  } else if (isSunlight) {
    // show raindrops if watered and rain active
    if (rainActive) {
      updateRain();
      displayRain();
    }

    // show pollen particles if triggered when pollinator moved
    if (showPollen) {
      updatePollen();
      displayPollen();
    }

    // show flowers when pollinator triggers
    displayFlowers();
  }

  // show the status indicator
  //displayStatusIndicator();

  //  // deBUGGING inFOOOOO
  //  fill(255);
  //  textSize(30);
  //  // current Mode
  //  text("Current Mode: " + getCurrentMode(), 20, 30);
  //  // flower count
  //  text("Flowers: " + currentFlowers + "/" + flowerCount, 20, 60);
  //  textSize(20);

  //  // sun lifted status
  //  if (arduino_values[0] > 0) {
  //    text("Sun lifted: YES", 20, 100);
  //  } else {
  //    text("Sun lifted: NO", 20, 100);
  //  }

  //  // watering status
  //  if (arduino_values[1] > 0) {
  //    text("Watering: YES", 20, 130);
  //  } else {
  //    text("Watering: NO", 20, 130);
  //  }

  //  // pollinating status
  //  if (isPollinated) {
  //    text("Pollinating: YES", 20, 160);
  //  } else {
  //    text("Pollinating: NO", 20, 160);
  //  }
}

//void displayStatusIndicator() {
//  int indicatorSize = 50;
//  int x = width - indicatorSize - 20;
//  int y = height - indicatorSize - 20;

//  if (isDark) {
//    fill(255); // white in dark mode
//  } else if (isSunlight && !isWatered && !isPollinated) {
//    fill(60, 100, 100); // yellow in meadow mode
//  } else if (isSunlight && isWatered && !isPollinated) {
//    if (rainActive) {
//      fill(200, 80, 100); // blue when raining
//    } else {
//      fill(200, 50, 80); // lighter blue when watered but not raining
//    }
//  } else if (isSunlight && isWatered && isPollinated) {
//    if (rainActive) {
//      fill(330, 80, 100); // pink when pollinated and raining
//    } else {
//      fill(330, 50, 80); // lighter pink when pollinated and watered
//    }
//  } else if (isSunlight && !isWatered && millis() - lastWateringTrigger > WATERING_DURATION) {
//    fill(0, 0, 50); // grey when watering effect expire and run out
//  }

//  rect(x, y, indicatorSize, indicatorSize);
//}

void updateBackground() {
  if (isSunlight) {
    bgLerpValue = min(bgLerpValue + BG_LERP_SPEED, 1);
  } else {
    bgLerpValue = max(bgLerpValue - BG_LERP_SPEED, 0);
  }

  // smooth lerp transition between dark and meadow colors
  color darkColor = color(0);
  color meadowColor = color(104, 100, 40);
  color currentBg = lerpColor(darkColor, meadowColor, bgLerpValue);
  background(currentBg);
}

void updateStates() {
  if (arduino_values[0] > 0) {
    // sunlight mode
    isSunlight = true;
    isDark = false;

    // start nature sounds if not already playing
    if (!isNatureSoundPlaying) {
      natureSound.loop();
      isNatureSoundPlaying = true;
    }
    
    // stop cricket sounds if they're playing
    if (isCricketSoundPlaying) {
      cricketSound.stop();
      isCricketSoundPlaying = false;
    }
    
  } else {
    // dark mode
    isSunlight = false;
    isDark = true;
    isWatered = false;
    isPollinated = false;
    rainActive = false;

    // start cricket sounds if not already playing
    if (!isCricketSoundPlaying) {
      cricketSound.loop();
      isCricketSoundPlaying = true;
    }

    // stop other sounds when dark
    if (isNatureSoundPlaying) {
      natureSound.stop();
      isNatureSoundPlaying = false;
    }
    
    if (isRainSoundPlaying) {
      rainSound.stop();
      isRainSoundPlaying = false;
    }
    return; // no other states visible if dark
  }

  // watering state (with timeout) with rain sound control
  if (arduino_values[1] > 0) {
    isWatered = true;
    wateringStartTime = millis();
    lastWateringTrigger = millis();
    rainActive = true;

    // start rain sound if not already playing
    if (rainActive && !isRainSoundPlaying) {
      isRainSoundPlaying = true;
      rainSound.loop();
    }
  } else {
    // check if rain should stop (after 2 seconds)
    if (millis() - lastWateringTrigger > RAIN_DURATION) {
      rainActive = false;

      // stop rain sound when rain stops
      if (!rainActive && isRainSoundPlaying) {
        rainSound.stop();
        isRainSoundPlaying = false;
      }
    }

    // check if watering duration is over (5 seconds total)
    if (millis() - wateringStartTime > WATERING_DURATION) {
      isWatered = false;
    }
  }

  // pollination state
  int currentPollen = arduino_values[2];
  boolean significantChange = abs(currentPollen - previousPollenValue) > POLLEN_THRESHOLD;
  boolean cooldownOver = (millis() - lastPollinationTime) > POLLEN_COOLDOWN;

  // change in y value + spam controller + soil is watered
  if (significantChange && cooldownOver && isWatered) {
    sparkleSound.play(); // play new sparkle sound
    isPollinated = true;
    pollinationStartTime = millis();
    lastShakeTime = millis();
    showPollen = true;
    lastPollenTime = millis();
    lastPollinationTime = millis(); // reset the cooldown timer for pollinating "aka growing tha flowers"
    createPollenParticles();
    spawnFlowers(30);
  } else {
    isPollinated = false;
  }

  // update previous pollen value for the next frame based on sensor data
  previousPollenValue = currentPollen;

  // pollen particle effect display timeout
  if (showPollen && millis() - lastPollenTime > POLLEN_DURATION) {
    showPollen = false;
    activePollen = 0;
  }

  // remove any old flowers
  checkFlowerLifetimes();
}

void checkFlowerLifetimes() {
  for (int i = 0; i < currentFlowers; i++) {
    if (flowers[i] != null && millis() - flowers[i].spawnTime > FLOWER_LIFETIME) {
      // shift all flowers down to fill the gap in the
      // array so flwoer can keep being removed after their
      // expiration time
      for (int j = i; j < currentFlowers - 1; j++) {
        flowers[j] = flowers[j + 1];
      }
      flowers[currentFlowers - 1] = null;
      currentFlowers--;
      i--;
    }
  }
}

void spawnFlowers(int count) {
  if (!isWatered) return; // only spawn flowers when watered effect on

  for (int n = 0; n < count; n++) {
    if (currentFlowers >= flowerCount) return;

    boolean validPosition = false;
    int attempts = 0;

    while (!validPosition && attempts < 100) {
      Flower newFlower = new Flower();
      validPosition = true;

      // check distance against existing flowers
      for (int j = 0; j < currentFlowers; j++) {
        if (flowers[j] != null &&
          dist(newFlower.x, newFlower.y, flowers[j].x, flowers[j].y) < minDistance) {
          validPosition = false;
          break;
        }
      }

      if (validPosition) {
        flowers[currentFlowers] = newFlower;
        currentFlowers++;
      }
      attempts++;
    }
  }
}

void displayFlowers() {
  for (int i = 0; i < currentFlowers; i++) {
    if (flowers[i] != null) {
      flowers[i].display();
    }
  }
}

void updateRain() {
  for (int i = 0; i < dropCount; i++) {
    drops[i].fall();
  }
}

void displayRain() {
  for (int i = 0; i < dropCount; i++) {
    drops[i].display();
  }
}

void createPollenParticles() {
  activePollen = min(pollenCount, 100); // Activate up to 100 particles
  for (int i = 0; i < activePollen; i++) {
    pollenParticles[i].reset();
  }
}

void updatePollen() {
  for (int i = 0; i < activePollen; i++) {
    if (pollenParticles[i] != null) {
      pollenParticles[i].update();
    }
  }
}

void displayPollen() {
  for (int i = 0; i < activePollen; i++) {
    if (pollenParticles[i] != null) {
      pollenParticles[i].display();
    }
  }
}

void resetAll() {
  isDark = true;
  isSunlight = false;
  isWatered = false;
  isPollinated = false;

  // reset flowers
  currentFlowers = 0;
  for (int i = 0; i < flowerCount; i++) {
    flowers[i] = null;
  }

  // reset pollen
  activePollen = 0;
  showPollen = false;

  // reset rain
  rainActive = false;

  // reset background transition to deafult
  bgLerpValue = 0;

  // stop all sounds
  natureSound.stop();
  rainSound.stop();
  sparkleSound.stop();
  isNatureSoundPlaying = false;
  isRainSoundPlaying = false;
}

String getCurrentMode() {
  if (isDark) return "Dark";
  if (isSunlight && !isWatered && !isPollinated) return "Sunny Meadow";
  if (isSunlight && isWatered && !isPollinated) return "Raining";
  if (isSunlight && isWatered && isPollinated && showPollen) return "Pollen Dust";
  if (isSunlight && isWatered && isPollinated) return "Flowers Blooming";
  return "Transitioning";
}

// raindrops class
class Drop {
  float x, y;
  float speed;
  float length;

  Drop() {
    reset();
  }

  void reset() {
    x = random(width);
    y = random(-200, -50);
    speed = random(5, 10);
    length = random(10, 20);
    strokeWeight (5);
  }

  void fall() {
    y += speed;
    if (y > height) {
      reset();
    }
  }

  void display() {
    stroke(200, 80, 100, 0.8);
    line(x, y, x, y + length);
  }
}

// flower class
class Flower {
  float x, y;
  float size;
  float hue;
  int petalCount;
  float rotation;
  float petalLength;
  float petalWidth;
  int spawnTime;

  Flower() {
    x = random(width);
    y = random(height);
    size = random(40, 78);
    hue = random(0, 360);
    petalCount = floor(random(8, 11));
    rotation = random(TWO_PI);
    petalLength = random(0.8, 2.5);
    petalWidth = random(0.7, 1.3);
    spawnTime = millis();
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

      // hue variation
      float hueVariation = sin(timing + x * 0.01 + y * 0.01) * 2;
      // saturation variation
      float satVariation = cos(timing + x * 0.01) * 1;
      // brightness variation
      float briVariation = sin(timing + y * 0.01) * 2;

      noStroke();
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
    noStroke();
    fill((hue + 30) % 360, 90, 80);
    ellipse(0, 0, size * 0.4, size * 0.4);

    popMatrix();
  }
}

// pollen particle class
class Pollen {
  float x, y;
  float size;
  float speedX, speedY;
  float life;
  float lifeDecrease;

  Pollen() {
    reset();
  }

  void reset() {
    x = random(width);
    y = random(height/2); // start in upper half of canvas
    size = random(2, 6);
    speedX = random(-1, 1);
    speedY = random(1, 3); // fall downward
    life = random(0.8, 1.0);
    lifeDecrease = random(0.005, 0.015);
  }

  void update() {
    x += speedX;
    y += speedY;
    life -= lifeDecrease;
  }

  void display() {
    noStroke();
    fill(60, 100, 100, life); // yellow color
    ellipse(x, y, size, size);
  }
}

// the helper function below receives the values from Arduino
// in the "arduino_values" array from a connected Arduino
// running the "serial_AtoP_arduino" sketch
// (You won't need to change this code.)

void getSerialData() {
  while (serialPort.available() > 0) {
    String in = serialPort.readStringUntil( 10 );  // 10 = '\n'  Linefeed in ASCII
    if (in != null) {
      print("From Arduino: " + in);
      String[] serialInArray = split(trim(in), ",");
      if (serialInArray.length == NUM_OF_VALUES_FROM_ARDUINO) {
        for (int i=0; i<serialInArray.length; i++) {
          arduino_values[i] = int(serialInArray[i]);
        }
      }
    }
  }
}
