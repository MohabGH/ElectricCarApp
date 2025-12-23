#include <BluetoothSerial.h>

// Bluetooth
BluetoothSerial SERIAL_BT;

//Ultrasonics
#define TRIG_F 26
#define ECHO_F 34

#define TRIG_L 27 
#define ECHO_L 39

#define TRIG_R 18 
#define ECHO_R 23

#define TRIG_B 19 
#define ECHO_B 22

//Motors' pins
#define EN_L 32
#define IN_L_1 33
#define IN_L_2 25

#define EN_R 17
#define IN_R_1 16
#define IN_R_2 4

//Parking
  //Parking Constants
  #define MIN_PARKING_LENGTH 40
  #define MIN_PARKING_DEPTH 20
  //States
  enum parking_states{START,CHECK_R,CHECK_L,PARK_R,PARK_L,FINISH};
  enum park_states{P_LEFT,P_BACKWARD,P_RIGHT,P_FORWARD};

  //Variables
  parking_states PARKING_STATE = START;
  park_states PARK_STATE;
  float START_TIME_P = 0;
  float END_TIME_P = 0;
  float START_TIME = 0;
  float END_TIME = 0;
  float DEPTH_R = 0;
  float DEPTH_L = 0;
  float FORWARD_DISTANCE;

//Autonomous
  //Constants
  #define TURNING_DURATION 200  //in ms
  //States
  enum autonomous_states{A_FORWARD,A_RIGHT,A_LEFT,A_STOP};
  //Variables
  autonomous_states AUTONOMOUS_STATE = A_FORWARD;
  float AVAILABLE_RIGHT_DISTANCE = 0;
  float AVAILABLE_LEFT_DISTANCE = 0;
  float START_TIME_AUTONOMOUS_TURNING = 0;
  float END_TIME_AUTONOMOUS_TURNING = 0;
//Car's speed Vaiables
int SPEED_L = 155;
int SPEED_R = 155;
//Constant Speed for Parking and Autonmous
#define PARKING_SPEED_L 100//Due to slight curve in forward motion
#define PARKING_SPEED_R 100
#define CAR_SPEED_CM_S 47//measured through movement of the car for 5SEC and measuring the distance //SHOULD BE CALIPRATED EVERY NOW AND THEN

//Battery's Pin
#define BATTERY 36

// Battery Values
#define R1 10030.0
#define R2 3300.0
#define MIN_VOLTAGE 9.0  // 9.0 = 3.0*3  0%
#define MAX_VOLTAGE 12.6  // 12.6 = 4.2*3  100%
#define CALIBRATION_FACTOR 1.0775
float BATTERY_START_TIME = 0;
float BATTERY_END_TIME = 0;
float SUM_FOR_AVERAGE_READING = 0;
int NUMBER_OF_READING_SUMMED = 0;

//Command Variables
enum latest_commands{LATEST_IDLE,LATEST_AUTONOMOUS,LATEST_RIGHT_PARKING,LATEST_LEFT_PARKING,LATEST_STOP};
String COMMAND;
latest_commands LATEST_COMMAND;


//Movement Functions
void move_forward(){
  digitalWrite(IN_L_1, LOW);
  digitalWrite(IN_L_2, HIGH);
  analogWrite(EN_L, SPEED_L);

  digitalWrite(IN_R_1, LOW);
  digitalWrite(IN_R_2, HIGH);
  analogWrite(EN_R, SPEED_R);
}
void move_backward(){      
  digitalWrite(IN_L_1, HIGH);
  digitalWrite(IN_L_2, LOW);
  analogWrite(EN_L, SPEED_L);

  digitalWrite(IN_R_1, HIGH);
  digitalWrite(IN_R_2, LOW);
  analogWrite(EN_R, SPEED_R);
}
void move_right(){
  digitalWrite(IN_L_1, LOW);
  digitalWrite(IN_L_2, HIGH);
  analogWrite(EN_L, SPEED_L);

  digitalWrite(IN_R_1, HIGH);
  digitalWrite(IN_R_2, LOW);
  analogWrite(EN_R, SPEED_R);
}
void move_left(){
  digitalWrite(IN_L_1, HIGH);
  digitalWrite(IN_L_2, LOW);
  analogWrite(EN_L, SPEED_L);

  digitalWrite(IN_R_1, LOW);
  digitalWrite(IN_R_2, HIGH);
  analogWrite(EN_R, SPEED_R);
}
void stop(){
  digitalWrite(IN_L_1, LOW);
  digitalWrite(IN_L_2, LOW);  
  digitalWrite(IN_R_1, LOW);
  digitalWrite(IN_R_2, LOW);
}

//Change speed
void update_right_speed(int pwm){
  SPEED_R = pwm;
}

void update_left_speed(int pwm){
  SPEED_L = pwm;
}

//Get distance Function
float ultrasonic(int trig,int echo){
  long duration ;
  float distance;
  digitalWrite(trig,LOW);
  delayMicroseconds(2);
  digitalWrite(trig, HIGH);
  delayMicroseconds(10);
  digitalWrite(trig,LOW);
  //Calculations
  duration = pulseIn(echo,HIGH);
  distance = duration * 0.0343 / 2 ;
  delay(15); 
  return distance; 
}

// Getting commands from the app
String get_command(){
  String msg = "";

  while (SERIAL_BT.available()) {
    char c = SERIAL_BT.read();
    msg += c;
    delay(5);
  }

  return msg;
}

// Sending battery percentage to the phone.
void send_battery_percentage(){
  BATTERY_END_TIME = millis();
  int ADC_value = analogRead(BATTERY);
  float ADC_voltage = (ADC_value*3.3)/ 4095.0;              // Convert ADC reading to voltage
  float battery_voltage = ADC_voltage*((R2+R1)/R2);     // Compensate voltage divider
  battery_voltage *= CALIBRATION_FACTOR;
  SUM_FOR_AVERAGE_READING += battery_voltage;
  NUMBER_OF_READING_SUMMED++;
  
  if((BATTERY_END_TIME-BATTERY_START_TIME) >= 5000){
    float average_battery_voltage = SUM_FOR_AVERAGE_READING/NUMBER_OF_READING_SUMMED; //Calculating average voltage
    float battery_percentage = (average_battery_voltage-MIN_VOLTAGE)/(MAX_VOLTAGE-MIN_VOLTAGE)*100.0; //Calculating voltage percentage
    SERIAL_BT.print("BAT:" + String(battery_percentage));//Sending battery percentage to APP
    SUM_FOR_AVERAGE_READING = 0;//returning to intial value
    NUMBER_OF_READING_SUMMED = 0;//returning to intial value
    BATTERY_START_TIME = millis();//reput the start time
  }
}

//Parking Functions
void check_R(){
  // Checking at the right
  DEPTH_R = ultrasonic(TRIG_R,ECHO_R);
  if(DEPTH_R >= MIN_PARKING_DEPTH){
    END_TIME = millis();
    if(((END_TIME-START_TIME)*CAR_SPEED_CM_S/1000) >= MIN_PARKING_LENGTH){
      PARKING_STATE = PARK_R;
      PARK_STATE = P_LEFT;//Start state in parking at the right
      START_TIME_P = millis();//Start time for turning left in parking
    }
  }
  else{
    START_TIME = millis();//Reget the start time to start calculating till find the right depth
    move_forward();
  }
}

void park_R(){
  switch(PARK_STATE){
    case P_LEFT:
    END_TIME_P = millis();
    if((END_TIME_P-START_TIME_P) < ((5.5/CAR_SPEED_CM_S)*1000)){// '5.5' is the distance to move in moving right
      move_left();
    }
    else{
      PARK_STATE = P_BACKWARD;
    }
    break;

    case P_BACKWARD:
    if(ultrasonic(TRIG_B,ECHO_B) > 15){// '15' is the safe space
      move_backward();
    }
    else{
      PARK_STATE = P_RIGHT;
      START_TIME_P = millis();
    }
    break;

    case P_RIGHT:
    END_TIME_P = millis();
    if((END_TIME_P-START_TIME_P) < ((5.0/CAR_SPEED_CM_S)*1000)){// '5.0' is the distance to move in moving right
      move_right();
    }
    else{
      PARK_STATE = P_FORWARD;
      FORWARD_DISTANCE = ultrasonic(TRIG_F,ECHO_F);
    }
    break;

    case P_FORWARD:
    if(ultrasonic(TRIG_F,ECHO_F) > (FORWARD_DISTANCE/2.0)){//so the car parks at the middle of the parking space
      move_forward();
    }
    else{
      PARKING_STATE = FINISH;
    }
    break;
  } 
}

void parking_R(){
  SPEED_R = PARKING_SPEED_R;
  SPEED_L = PARKING_SPEED_L;
  switch(PARKING_STATE){
    case START:
    START_TIME = millis();
    move_forward();
    PARKING_STATE = CHECK_R;
    break;

    case CHECK_R:
    check_R();
    break;

    case PARK_R:
    park_R();
    break;
    
    case FINISH:
    stop();
    break;
  }
}

void check_L(){
  DEPTH_L = ultrasonic(TRIG_L,ECHO_L);
  //Checking at the left
  if(DEPTH_L >= MIN_PARKING_DEPTH){
    END_TIME = millis();
    if(((END_TIME-START_TIME)*CAR_SPEED_CM_S/1000) >= MIN_PARKING_LENGTH){
      PARKING_STATE = PARK_L;
      PARK_STATE = P_RIGHT;//Start state in parking at the left
      START_TIME_P = millis();//Start time for turning right in parking
    }
  }
  else{
    START_TIME = millis();//Reget the start time to start calculating till find the right depth
    move_forward();
  }
}

void park_L(){
  switch(PARK_STATE){
    case P_RIGHT:
    END_TIME_P = millis();
    if((END_TIME_P-START_TIME_P) < ((5.5/CAR_SPEED_CM_S)*1000)){// '5.5' is the distance to move in moving right
      move_right();
    }
    else{
      PARK_STATE = P_BACKWARD;
    }
    break;

    case P_BACKWARD:
    if(ultrasonic(TRIG_B,ECHO_B) > 15){// '15' is the safe space
      move_backward();
    }
    else{
      PARK_STATE = P_LEFT;
      START_TIME_P = millis();
    }
    break;

    case P_LEFT:
    END_TIME_P = millis();
    if((END_TIME_P-START_TIME_P) < ((5.0/CAR_SPEED_CM_S)*1000)){// '5.0' is the distance to move in moving right
      move_left();
    }
    else{
      PARK_STATE = P_FORWARD;
      FORWARD_DISTANCE = ultrasonic(TRIG_F,ECHO_F);
    }
    break;

    case P_FORWARD:
    if(ultrasonic(TRIG_F,ECHO_F) > (FORWARD_DISTANCE/2.0)){//so the car parks at the middle of the parking space
      move_forward();
    }
    else{
      PARKING_STATE = FINISH;
    }
    break;
  } 
}

void parking_L(){
  SPEED_R = PARKING_SPEED_R;
  SPEED_L = PARKING_SPEED_L;
  switch(PARKING_STATE){
    case START:
    START_TIME = millis(); 
    move_forward();
    PARKING_STATE = CHECK_L;
    break;

    case CHECK_L:
    check_L();
    break;

    case PARK_L:
    park_L();
    break;
    
    case FINISH:
    stop();
    break;
  }
}

//Autonomous mode
void autonomous_forward(){
  AVAILABLE_RIGHT_DISTANCE = ultrasonic(TRIG_R,ECHO_R);//getting the available distance in right to change the direction directly if needed
  AVAILABLE_LEFT_DISTANCE = ultrasonic(TRIG_L,ECHO_L);//getting the available distance in left to change the direction directly if needed
  
  if(ultrasonic(TRIG_F,ECHO_F) > 25){
    move_forward();
  }
  else{
    START_TIME_AUTONOMOUS_TURNING = millis();
    if(AVAILABLE_RIGHT_DISTANCE > AVAILABLE_LEFT_DISTANCE){
      AUTONOMOUS_STATE = A_RIGHT;
    }
    else{
      AUTONOMOUS_STATE = A_LEFT;
    }
  }
}

void autonomous_right(){
  END_TIME_AUTONOMOUS_TURNING = millis();

  if((END_TIME_AUTONOMOUS_TURNING-START_TIME_AUTONOMOUS_TURNING) < TURNING_DURATION){
    move_right();
  }
  else{
    AUTONOMOUS_STATE = A_FORWARD;
  }
}

void autonomous_left(){
  END_TIME_AUTONOMOUS_TURNING = millis();

  if((END_TIME_AUTONOMOUS_TURNING-START_TIME_AUTONOMOUS_TURNING) < TURNING_DURATION){
    move_left();
  }
  else{
    AUTONOMOUS_STATE = A_FORWARD;
  }
}

void autonomous(){
  SPEED_R = PARKING_SPEED_R;//constant speed for autonomous
  SPEED_L = PARKING_SPEED_L;//constant speed for autonomous

  switch(AUTONOMOUS_STATE){
    case A_FORWARD:
    autonomous_forward();
    break;

    case A_RIGHT:
    autonomous_right();
    break;
    
    case A_LEFT:
    autonomous_left();
    break;

    case A_STOP:
    stop();
    break;
  }
}

void setup() {
  Serial.begin(115200);
  SERIAL_BT.begin("ESP32-Car");

  //Ultrasonics
  pinMode(TRIG_F,OUTPUT);
  pinMode(ECHO_F,INPUT);
  pinMode(TRIG_L,OUTPUT);
  pinMode(ECHO_L,INPUT);
  pinMode(TRIG_R,OUTPUT);
  pinMode(ECHO_R,INPUT);
  pinMode(TRIG_B,OUTPUT);
  pinMode(ECHO_B,INPUT);

  //DC Motors
  pinMode(EN_L,OUTPUT);
  pinMode(IN_L_1,OUTPUT);
  pinMode(IN_L_2,OUTPUT);
  pinMode(EN_R,OUTPUT);
  pinMode(IN_R_1,OUTPUT);
  pinMode(IN_R_2,OUTPUT);
  BATTERY_START_TIME = millis();
}

void loop() {
  COMMAND = get_command();

  if(COMMAND == "F") move_forward();
  else if(COMMAND == "B") move_backward();
  else if(COMMAND == "L") move_left();
  else if(COMMAND == "R") move_right();
  else if(COMMAND.startsWith("LS:")) update_left_speed(COMMAND.substring(3).toInt());
  else if(COMMAND.startsWith("RS:")) update_right_speed(COMMAND.substring(3).toInt());
  else if(COMMAND == "A") {LATEST_COMMAND = LATEST_AUTONOMOUS;AUTONOMOUS_STATE = A_FORWARD;}
  else if(COMMAND == "RP") {LATEST_COMMAND = LATEST_RIGHT_PARKING;PARKING_STATE = START;}
  else if(COMMAND == "LP") {LATEST_COMMAND = LATEST_LEFT_PARKING;PARKING_STATE = START;}
  else if(COMMAND == "S") {stop();LATEST_COMMAND = LATEST_STOP;}

  switch(LATEST_COMMAND){
    case LATEST_IDLE:
    break;

    case LATEST_AUTONOMOUS:
    autonomous();
    break;

    case LATEST_RIGHT_PARKING:
    parking_R();
    break;

    case LATEST_LEFT_PARKING:
    parking_L();
    break;

    case LATEST_STOP:
    stop();
    LATEST_COMMAND = LATEST_IDLE;
  }

  send_battery_percentage();
}
