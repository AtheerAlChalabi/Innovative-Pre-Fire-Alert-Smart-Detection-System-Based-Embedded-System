#include <AverageThermocouple.h>
#include <MAX6675_Thermocouple.h>
#include <SmoothThermocouple.h>
#include <Thermocouple.h>
#include <SoftwareSerial.h>

////
#include <Wire.h>
#include <Adafruit_ADS1X15.h>
////variables of thermo

#include "max6675.h" // max6675.h file is part of the library that you should download from Robojax.com




int soPin1 = 9;// SO=Serial Out
int csPin1 = 8;// CS = chip select CS pin
int sckPin1 = 7;// SCK = Serial Clock pin
int soPin2 = 4;// SO=Serial Out
int csPin2 = 5;// CS = chip select CS pin
int sckPin2 = 6;// SCK = Serial Clock pin

MAX6675 robojax1(sckPin1, csPin1, soPin1);// create instance object of MAX6675
MAX6675 robojax2(sckPin2, csPin2, soPin2);// create instance object of MAX6675
///////



// Digital pin 8 will be called 'pin8'
int pin8 = 13;
// Analog pin 0 will be called 'sensor'
int sensorGASES = A1;
int sensorCO1 = A0;
// Set the initial sensorValue to 0
int val_sensorGASES = 0;
int val_sensorCO1 = 0;

/// 18/7/2023
Adafruit_ADS1115 ads;
const float FACTOR = 20; //20A/1V from teh CT
const float multiplier = 0.00005;

// The setup routine runs once when you press reset
void setup()
{
 // Serial.begin(9600);// initialize serial monitor with 9600 baud
 // Serial.println("Robojax MAX6675"); 

  // Initialize the digital pin 8 as an output
  pinMode(pin8, OUTPUT);
  // Initialize serial communication at 9600 bits per second
  Serial.begin(9600);
  ///18/7/2023
  ads.setGain(GAIN_FOUR);      // +/- 1.024V 1bit = 0.5mV
  ads.begin();

    Serial1.begin(115200);  // initialise Serial1
}

// The loop routine runs over and over again forever
void loop() {
     float currentRMS = getcurrent() - 16;
       val_sensorGASES = analogRead(sensorGASES);
  val_sensorCO1 = analogRead(sensorCO1);
String myData = "" + String(int(currentRMS)) + " " + String(val_sensorGASES)+
                  " " + String(val_sensorCO1) + " " + String(int(robojax1.readCelsius()))+
                  " " + String(int(robojax2.readCelsius()));
                  
                  delay(1000); 
    //   softSerial.println(myData);
       Serial.println(myData);
       Serial1.println(myData);

 }

////18/7/2023
float getcurrent()
{
  float voltage;
  float current;
  float sum = 0;
  long time_check = millis();
  int counter = 0;

  while (millis() - time_check < 1000)
  {
    voltage = ads.readADC_Differential_0_1() * multiplier;
    current = voltage * FACTOR;
    //current /= 1000.0;

    sum += sq(current);
    counter = counter + 1;
  }

  current = sqrt(sum / counter);
  return (current);
}
