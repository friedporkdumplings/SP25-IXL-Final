void setup() {
  Serial.begin(9600);
}

void loop() {
  // to send values to Processing assign the values you want to send
  // this is an example:
  int sensor0 = analogRead(A0);
  int sensor1 = analogRead(A1);

  // send the values keeping this format
  Serial.print(sensor0);
  Serial.print(",");  // put comma between sensor values
  Serial.print(sensor1);
  Serial.println();  // add linefeed after sending the last sensor value

  // too fast communication might cause some latency in Processing
  // this delay resolves the issue
  delay(20);

  // end of example sending values
}
