const int tempPin = A1;
const int motorPin = 9;

float WANTED_TEMP = 23.0;
const float MAX_TEMP = 40;
float celsius = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(motorPin, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  int sensorValue = analogRead(tempPin);
  float voltage = sensorValue * 5.0 / 1024;
  float temperature = voltage * 100;
  Serial.println(temperature);

  float speed = map(temperature, WANTED_TEMP, MAX_TEMP, 0 , 255);
  analogWrite(motorPin, speed);

  delay(1000);
  // delay(1000);

  // analogWrite(motorPin, 128);
  // delay(5000);
  // analogWrite(motorPin, 255);
  // delay(5000);
}

