import org.firmata.*;
import cc.arduino.*;

//Thanks to Adrian Fernandez for the beta-version
//Modified and updated as per latest IDE by Aritro Mukherjee (April,2016)
//Check the detailed tutorial @ www.hackster.io/Aritro
// Sensor used while demonstration (MPU-6050,6DOF)

import processing.serial.*;
import cc.arduino.*;

int W=1400; //My Laptop's screen width 
int H=700;  //My Laptop's screen height 
float Pitch; 
float Bank; 
float Azimuth; 
float ArtificialHoizonMagnificationFactor=0.7; 
float CompassMagnificationFactor=0.85; 
float SpanAngle=120; 
int NumberOfScaleMajorDivisions; 
int NumberOfScaleMinorDivisions; 
PVector v1, v2; 


Serial port;
float Phi;    //Dimensional axis
float Theta;
float Psi;

void setup() 
{ 
  size(W, H); 
  rectMode(CENTER); 
  smooth(); 
  strokeCap(SQUARE);//Optional 
  
  println(Serial.list()); //Shows your connected serial ports
  port = new Serial(this, Serial.list()[0], 115200); 
  //Up there you should select port which arduino connected and same baud rate.
  port.bufferUntil('\n'); 
}
void draw() 
{ 
  background(0); 
  translate(W/4, H/2.1);  
  MakeAnglesDependentOnMPU6050(); 
  Horizon(); 
  rotate(-Bank); 
  PitchScale(); 
  Axis(); 
  rotate(Bank); 
  Borders(); 
  Plane(); 
  ShowAngles(); 
  Compass(); 
  ShowAzimuth(); 
}
void serialEvent(Serial port) //Reading the datas by Processing.
{
   String input = port.readStringUntil('\n');
  if(input != null){
   input = trim(input);
  String[] values = split(input, " ");
 if(values.length == 3){
  float phi = float(values[0]);
  float theta = float(values[1]); 
  float psi = float(values[2]); 
  print(phi);
  print(theta);
  println(psi);
  Phi = phi;
  Theta = theta;
  Psi = psi;
   }
  }
}
void MakeAnglesDependentOnMPU6050() 
{ 
  Bank =-Phi/5; 
  Pitch=Theta*10; 
  Azimuth=Psi;
}
void Horizon() 
{ 
  scale(ArtificialHoizonMagnificationFactor); 
  noStroke(); 
  fill(0, 180, 255); 
  rect(0, -100, 900, 1000); 
  fill(95, 55, 40); 
  rotate(-Bank); 
  rect(0, 400+Pitch, 900, 800); 
  rotate(Bank); 
  rotate(-PI-PI/6); 
  SpanAngle=120; 
  NumberOfScaleMajorDivisions=12; 
  NumberOfScaleMinorDivisions=24;  
  CircularScale(); 
  rotate(PI+PI/6); 
  rotate(-PI/6);  
  CircularScale(); 
  rotate(PI/6); 
}
void ShowAzimuth() 
{ 
  fill(50); 
  noStroke(); 
  rect(20, 470, 440, 50); 
  int Azimuth1=round(Azimuth); 
  textAlign(CORNER); 
  textSize(35); 
  fill(255); 
  text("Azimuth:  "+Azimuth1+" Deg", 80, 477, 500, 60); 
  textSize(40);
  fill(25,25,150);
  text("FLIGHT SIMULATOR", -350, 477, 500, 60); 
}
void Compass() 
{ 
  translate(2*W/3, 0); 
  scale(CompassMagnificationFactor); 
  noFill(); 
  stroke(100); 
  strokeWeight(80); 
  ellipse(0, 0, 750, 750); 
  strokeWeight(50); 
  stroke(50); 
  fill(0, 0, 40); 
  ellipse(0, 0, 610, 610); 
  for (int k=255;k>0;k=k-5) 
  { 
    noStroke(); 
    fill(0, 0, 255-k); 
    ellipse(0, 0, 2*k, 2*k); 
  } 
  strokeWeight(20); 
  NumberOfScaleMajorDivisions=18; 
  NumberOfScaleMinorDivisions=36;  
  SpanAngle=180; 
  CircularScale(); 
  rotate(PI); 
  SpanAngle=180; 
  CircularScale(); 
  rotate(-PI); 
  fill(255); 
  textSize(60); 
  textAlign(CENTER); 
  text("W", -375, 0, 100, 80); 
  text("E", 370, 0, 100, 80); 
  text("N", 0, -365, 100, 80); 
  text("S", 0, 375, 100, 80); 
  textSize(30); 
  text("COMPASS", 0, -130, 500, 80); 
  rotate(PI/4); 
  textSize(40); 
  text("NW", -370, 0, 100, 50); 
  text("SE", 365, 0, 100, 50); 
  text("NE", 0, -355, 100, 50); 
  text("SW", 0, 365, 100, 50); 
  rotate(-PI/4); 
  CompassPointer(); 
}
void CompassPointer() 
{ 
  rotate(PI+radians(Azimuth));  
  stroke(0); 
  strokeWeight(4); 
  fill(100, 255, 100); 
  triangle(-20, -210, 20, -210, 0, 270); 
  triangle(-15, 210, 15, 210, 0, 270); 
  ellipse(0, 0, 45, 45);   
  fill(0, 0, 50); 
  noStroke(); 
  ellipse(0, 0, 10, 10); 
  triangle(-20, -213, 20, -213, 0, -190); 
  triangle(-15, -215, 15, -215, 0, -200); 
  rotate(-PI-radians(Azimuth)); 
}
void Plane() 
{ 
  fill(0); 
  strokeWeight(1); 
  stroke(0, 255, 0); 
  triangle(-20, 0, 20, 0, 0, 25); 
  rect(110, 0, 140, 20); 
  rect(-110, 0, 140, 20); 
}
void CircularScale() 
{ 
  float GaugeWidth=800;  
  textSize(GaugeWidth/30); 
  float StrokeWidth=1; 
  float an; 
  float DivxPhasorCloser; 
  float DivxPhasorDistal; 
  float DivyPhasorCloser; 
  float DivyPhasorDistal; 
  strokeWeight(2*StrokeWidth); 
  stroke(255);
  float DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/9-StrokeWidth; 
  float DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.5-StrokeWidth;
  for (int Division=0;Division<NumberOfScaleMinorDivisions+1;Division++) 
  { 
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMinorDivisions;  
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an)); 
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an)); 
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an)); 
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an));   
    line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
  }
  DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/10-StrokeWidth; 
  DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.4-StrokeWidth;
  for (int Division=0;Division<NumberOfScaleMajorDivisions+1;Division++) 
  { 
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMajorDivisions;  
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an)); 
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an)); 
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an)); 
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an)); 
    if (Division==NumberOfScaleMajorDivisions/2|Division==0|Division==NumberOfScaleMajorDivisions) 
    { 
      strokeWeight(15); 
      stroke(0); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
      strokeWeight(8); 
      stroke(100, 255, 100); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
    } 
    else 
    { 
      strokeWeight(3); 
      stroke(255); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
    } 
  } 
}
void Axis() 
{ 
  stroke(255, 0, 0); 
  strokeWeight(3); 
  line(-115, 0, 115, 0); 
  line(0, 280, 0, -280); 
  fill(100, 255, 100); 
  stroke(0); 
  triangle(0, -285, -10, -255, 10, -255); 
  triangle(0, 285, -10, 255, 10, 255); 
}
void ShowAngles() 
{ 
  textSize(30); 
  fill(50); 
  noStroke(); 
  rect(-150, 400, 280, 40); 
  rect(150, 400, 280, 40); 
  fill(255); 
  Pitch=Pitch/5; 
  int Pitch1=round(Pitch);  
  text("Pitch:  "+Pitch1+" Deg", -20, 411, 500, 60); 
  text("Bank:  "+Bank*100+" Deg", 280, 411, 500, 60); 
}
void Borders() 
{ 
  noFill(); 
  stroke(0); 
  strokeWeight(400); 
  rect(0, 0, 1100, 1100); 
  strokeWeight(200); 
  ellipse(0, 0, 1000, 1000); 
  fill(0); 
  noStroke(); 
  rect(4*W/5, 0, W, 2*H); 
  rect(-4*W/5, 0, W, 2*H); 
}
void PitchScale() 
{  
  stroke(255); 
  fill(255); 
  strokeWeight(3); 
  textSize(24); 
  textAlign(CENTER); 
  for (int i=-4;i<5;i++) 
  {  
    if ((i==0)==false) 
    { 
      line(110, 50*i, -110, 50*i); 
    }  
    text(""+i*10, 140, 50*i, 100, 30); 
    text(""+i*10, -140, 50*i, 100, 30); 
  } 
  textAlign(CORNER); 
  strokeWeight(2); 
  for (int i=-9;i<10;i++) 
  {  
    if ((i==0)==false) 
    {    
      line(25, 25*i, -25, 25*i); 
    } 
  } 
}
