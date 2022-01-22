// Dev sketch of multires network
//

import java.util.HashMap;
import java.util.Map;

import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; 

MidiBus myBus; 
int midiDevice  = 0;



//TestIm2Row test = new TestIm2Row(); 
TestMatrixOps tst = new TestMatrixOps();

void setup(){
	size(500, 500);
	// unit.show_config();
  frameRate(60);
  MidiBus.list(); 
  myBus = new MidiBus(this, midiDevice, 1); 
  
  test.init(getColorGrid(loadImage("testimg.png"), 1));

}

void update(){
	test.tick();
}

void draw(){
	update();
	background(51);
	
	test.draw();
}

void keyPressed() {
  // if (key == ' ') {
  //   test.setInput(1.0);
  // }
  test.handleKeyDown(key); 
}

void keyReleased() {
  // if(key== ' ')
  //   test.setInput(0.0);
  test.handleKeyUp(key);
}

void midiMessage(MidiMessage message, long timestamp, String bus_name) { 
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);

  test.handleMidi(note, vel);
  /* if (vel > 0 ) {
   currentColor = vel*2;
  }
  
  float valx = map(vel, 0, 128, 0, width);
  float valy = map(vel, 0, 128, 0, height);
  float col = map(vel, 0, 129, 0, 255);
  
  if(note==1){
    x=(int)valx;
  }
  if(note==2){
    y=(int)valy;
  }
  if(note==84)
    ellipse_col = (int)col; */
}
