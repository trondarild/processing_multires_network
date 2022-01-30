// Dev sketch of multires network
//

import java.util.HashMap;
import java.util.Map;

import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; 

MidiBus myBus; 
int midiDevice  = 0;

import processing.video.*;
Movie myMovie;



//TestIm2Row test = new TestIm2Row(); 
//TestMatrixOps test = new TestMatrixOps();
//TestMRNotWU test = new TestMRNotWU();
//TestTwoLayers test = new TestTwoLayers();
//Test3Layers test = new Test3Layers();
Test4Layers test = new Test4Layers();

void setup(){
	size(2000, 1000);
	// unit.show_config();
  frameRate(30);
  MidiBus.list(); 
  myBus = new MidiBus(this, midiDevice, 1); 

  myMovie = new Movie(this, "test.mp4");
  myMovie.loop();
  
  //test.init(getColorGrid(loadImage("testimg.png"), 1));

}

void update(){
  if (myMovie.available()) {
    myMovie.read();
  }
  test.init(getColorGrid(myMovie, 1));
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

}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

/*
import processing.video.*;
Movie myMovie;

void setup() {
  size(200, 200);
  myMovie = new Movie(this, "totoro.mov");
  myMovie.loop();
}

void draw() {
  tint(255, 20);
  image(myMovie, mouseX, mouseY);
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}
*/
