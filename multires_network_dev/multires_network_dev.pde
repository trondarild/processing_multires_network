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

import processing.sound.*;
SoundFile file;

FFT fft;
// AudioIn in;
int bands = 32;
int maxtime = 32;
int maxband = 32;
float[] spectrum = new float[bands];
Buffer[] specbuf = new Buffer[maxband];
int ctr = 0;



//TestIm2Row test = new TestIm2Row(); 
//TestMatrixOps test = new TestMatrixOps();
//TestMRNotWU test = new TestMRNotWU();
//TestTwoLayers test = new TestTwoLayers();
//Test3Layers test = new Test3Layers();
//Test4Layers test = new Test4Layers();
//TestAudio test = new TestAudio();
TestSaveLoad test;

void setup(){
  test = new TestSaveLoad();
	size(2000, 1000);
	// unit.show_config();
  frameRate(30);
  MidiBus.list(); 
  myBus = new MidiBus(this, midiDevice, 1); 

  //myMovie = new Movie(this, "test.mp4");
  //myMovie.loop();
  
  //test.init(getColorGrid(loadImage("testimg.png"), 1));
  for(int i=0; i<maxband; i++) specbuf[i] = new Buffer(maxtime); 
  file = new SoundFile(this, "forest.mp3");
  file.loop();
  file.amp(0.9);
      
  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, bands);
  //in = new AudioIn(this, 0);
  
  // start the Audio Input
  //in.start();
  
  // patch the AudioIn
  fft.input(file);

}

void update(){
  //if (myMovie.available()) {
  //  myMovie.read();
  //}
  //test.init(getColorGrid(myMovie, 1));
  fft.analyze(spectrum);
  for(int i = 0; i < bands; i++){
    // The result of the FFT is normalized
    // draw the line for frequency band i scaling it up by 5 to get more amplitude.
    if(i < maxband)
      specbuf[i].append(spectrum[i]);
      // pushStyle();
      // stroke(200);
      // float maxlen = 20;
      // pushMatrix();
      // translate(100, 100);
      // scale(10,10);
      // line( i, 0, i, 0 - spectrum[i]*maxlen );
      // popMatrix();
      // popStyle();
  }
  float[][] viz = bufferArrayToMatrix(specbuf);
  test.init(viz);
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


float[][] bufferArrayToMatrix(Buffer[] buf) {
  float[][] retval = zeros(buf.length, buf[0].array().length);
  for(int i=0; i<buf.length; i++)
    retval[i] = buf[i].array();
  return retval;
}
