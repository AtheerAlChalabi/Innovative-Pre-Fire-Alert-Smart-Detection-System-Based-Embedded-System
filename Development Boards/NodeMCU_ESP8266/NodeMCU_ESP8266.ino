#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <SoftwareSerial.h>

// Define the software serial object with the desired pins
SoftwareSerial swSer(14, 12);
bool stutas = false;
String receivedData;
String DEVICE_TOKEN = "dnZgwiu5TbO-M0FSMiX3Cb:APA91bG7ctvmHddJJeVHivkjiuISohw3X0HcyEzH8K57GGx0aNN_hbuhvT-wgQr9n91Qq3Mq0D2hoRlYnGVsaD-qulgwOtw1rvW3Kh79y7rMsIRxZGW6pOrpG3qizslNoeWJSjccJ-la";

// Replace with your Wi-Fi credentials
const char* ssid = "Croco"; //WiFi user name to Sadeem
const char* password = "209000000"; // WiFi password to Sadeem

// Replace with your Firebase project settings
const char* host = "saddemiot-default-rtdb.firebaseio.com";
const char* auth = "TinVetRmYu76XscnnvBzFPiXUjLd1UC0Txh2idVj";
const String FCM_SERVER_KEY = "AAAArFgo8uw:APA91bHz0aiqOipZdq9Oa8gKEmJcASbwdOb1UUkBuAYn8OtrT4aMzfMH-VftzNV7VSnLryi78MW-8yE9hy4daLiVcKTiBJF6ia-hqF9VGoGhm4YFn_febmi0floUGzI8zRWwTltOj9Vf";

// Create an instance of the FirebaseData class
FirebaseData firebaseData;
String TOKEN_PATH = "/Token/deviceToken/";
String receivedString = "";

// Define the NTP server and the timezone
const char* ntpServer = "pool.ntp.org";
const long  gmtOffsetInSeconds = 3600; // Replace this with your timezone offset in seconds (e.g., GMT+1 = 3600)

// Create a Wi-Fi client instance
WiFiClient wifiClient;

// Create a NTPClient to get the time
WiFiUDP udp;
NTPClient timeClient(udp, ntpServer, gmtOffsetInSeconds);



// Function to send a notification to Firebase Cloud Messaging
void sendNotification(String title, String message, String TOKENValue) {
  FirebaseJson json;
  json.set("to", TOKENValue); // Replace "all" with your desired topic or specific device token
  //json.set("to","/topics/all");
  FirebaseJson notificationData;
  notificationData.set("title", title);
  notificationData.set("body", message);
  json.set("notification", notificationData);

  WiFiClientSecure client;
  client.setInsecure();
  if (client.connect("fcm.googleapis.com", 443)) {
    String url = "/fcm/send";
    String body = json.raw();

    client.print(String("POST ") + url + " HTTP/1.1\r\n");
    client.print(String("Host: fcm.googleapis.com\r\n"));
    client.print(String("Authorization: key=") + FCM_SERVER_KEY + "\r\n");
    client.print("Content-Type: application/json\r\n");
    client.print("Content-Length: " + String(body.length()) + "\r\n");
    client.print("Connection: close\r\n\r\n");
    client.print(body);

    // Wait for server response
    while (!client.available()) {
      delay(1000);
      Serial.print("*");
    };

    // Print the response from the FCM server (for debugging purposes)
    while (client.available()) {
      Serial.write(client.read());
    }

    client.stop();
  }
  else
    Serial.println("not connect");
}
unsigned long startTimeUpdate = 0;
unsigned long startTimeNot = 0;


void setup() {
  Serial.begin(9600);
  swSer.begin(115200);    //Initialize software serial with baudrate of 115200

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }

  Serial.println("\nConnected to Wi-Fi");

  Firebase.begin(host, auth);

  // Initialize NTP client
  timeClient.begin();
  timeClient.update(); // Get the current time from the NTP server
}

void sendNotificaiton (String msgTitle, String msgData) {
  // Get the string from Firebase
  // here for each to get the token path from 0 to count final value
  int i = 0;
 

  while(Firebase.getString(firebaseData, "Token/count/")>i){
    String PAT_TOk = TOKEN_PATH + i + "/";
  if (Firebase.getString(firebaseData, PAT_TOk)) {
    if (firebaseData.dataType() == "string") {
      String tokenValue = firebaseData.stringData();
      //   Serial.print("String value from Firebase: ");
     // Serial.println(tokenValue);
      sendNotification(msgTitle, msgData, tokenValue);
      /*
          } else {
            Serial.println("Error: Data is not a string");
          }
        }

        else {
          Serial.println("Error: Failed to get data from Firebase");
          Serial.println(firebaseData.errorReason());
      */
    }
    i++;

  }
  }
}
unsigned long getTimeNow() {
  timeClient.update(); // Update the NTP client to get the latest time

  //  Get and print the time
  unsigned long currentTime = timeClient.getEpochTime();
  return currentTime;
}

void loop() {
  // Send a test notification
  while (swSer.available() > 0) {  //wait for data at software serial
    receivedData = swSer.readStringUntil('\n'); // Read the entire line until the newline character

    // Print the received data (for testing purposes)
    Serial.print("Received Data: ");
    Serial.println(receivedData); 
    stutas = true;
  }

  if (stutas) {
    stutas = false;
    int spaceIndex = receivedData.indexOf(' ');
    String f1 = receivedData.substring(0, spaceIndex);
    String restOfString = receivedData.substring(spaceIndex + 1);

    spaceIndex = restOfString.indexOf(' ');
    String f2 = restOfString.substring(0, spaceIndex);
    restOfString = restOfString.substring(spaceIndex + 1);

    spaceIndex = restOfString.indexOf(' ');
    String f3 = restOfString.substring(0, spaceIndex);
    restOfString = restOfString.substring(spaceIndex + 1);

    spaceIndex = restOfString.indexOf(' ');
    String f4 = restOfString.substring(0, spaceIndex);
    restOfString = restOfString.substring(spaceIndex + 1);

    spaceIndex = restOfString.indexOf(' ');
    if (spaceIndex == -1) {
      spaceIndex = restOfString.indexOf('\n');
      if (spaceIndex == -1) {
        spaceIndex = restOfString.indexOf('\r');
      }
    }
    String f5 = restOfString.substring(0, spaceIndex);
    restOfString = restOfString.substring(spaceIndex + 1);




    // Serial.print("f5 = ");
    //  Serial.println(spaceIndex);

    // Serial.println(getDataType(f5));

    String path = "rInfo/";
    String path1 = "";
    String path2 = "";


    // Send the string to Firebase
    path1 = path + "Amp";
    sendToFirebase(path1, f1);

    path1 = path + "Smk";
    sendToFirebase(path1, f2);

    path1 = path + "Gaz";
    sendToFirebase(path1, f3);

    path1 = path + "iTmp";
    sendToFirebase(path1, f4);

    path1 = path + "oTmp";
    sendToFirebase(path1, f5);

    if(millis()- startTimeNot >= 10000){
    
    if (f4.toInt() >= 70)
      sendNotificaiton("High inside Temp",  f4);

    if (f5.toInt() >= 55)
      sendNotificaiton("High outside Temp",  f5);

    if (f2.toInt() >= 400)
      sendNotificaiton("High Smoke",  f2);


    if (f3.toInt() >= 300)
      sendNotificaiton("High Gass",  f3);

    if (f1.toInt() >= 90)
      sendNotificaiton("High Amp",  f1);
      
       startTimeNot = millis();
    }

    if (millis() - startTimeUpdate >= 6000) {
      path = "info/";
      path2 = path + getTimeNow();
      path2 += "/";
      path1 = path2 + "Amp";
      sendToFirebase(path1, f1);

      path1 = path2 + "Smk";
      sendToFirebase(path1, f2);

      path1 = path2 + "Gaz";
      sendToFirebase(path1, f3);

      path1 = path2 + "iTmp";
      sendToFirebase(path1, f4);

      path1 = path2 + "oTmp";
      sendToFirebase(path1, f5);

      startTimeUpdate = millis();
    }
    
    clearSoftwareSerialBuffer();
  }



}


void sendToFirebase(String path, String msg) {
  if (Firebase.setString(firebaseData,  path, msg)) {
    Serial.print(msg);
    Serial.print("send to");
    Serial.print(path);
    Serial.println(" successfully.");
  } else {
    Serial.print(msg);
    Serial.print(" not to");
    Serial.println(path);
    Serial.println(firebaseData.errorReason());
  }
}
void clearSoftwareSerialBuffer() {
  while (swSer.available() > 0) {
    swSer.read(); // Read and discard any available data in the buffer
  }
}


String getDataType(const __FlashStringHelper *data) {
  return F("FlashString");
}

String getDataType(const String &data) {
  return F("String");
}

String getDataType(const char *data) {
  return F("char array (C-string)");
}

String getDataType(const int &data) {
  return F("int");
}

String getDataType(const float &data) {
  return F("float");
}

String getDataType(const double &data) {
  return F("double");
}
