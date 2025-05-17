void setup() {
  Serial.begin(9600);
  pinMode(7, INPUT);
  pinMode(5, INPUT);
}

void loop() {
  // to send values to Processing assign the values you want to send
  // this is an example:
  int sensor0 = digitalRead(7);
  int sensor1 = digitalRead(5);
  int sensor2 = analogRead(A2);

  // send the values keeping this format
  Serial.print(sensor0);
  Serial.print(",");
  Serial.print(sensor1);
  Serial.print(",");
  Serial.print(sensor2);   
  Serial.println();

  // too fast communication might cause some latency in Processing
  // this delay resolves the issue
  delay(20);

  // end of example sending values
}
