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

String test_type;
static final String AUDIO = "audio";
static final String VIDEO = "video";



//TestIm2Row test = new TestIm2Row(); 
//TestMatrixOps test = new TestMatrixOps();
//TestMRNotWU test = new TestMRNotWU();
//TestTwoLayers test = new TestTwoLayers();
//Test3Layers test = new Test3Layers();
//Test4Layers test;
Train4Layers test;
//TestAudio test; //= new TestAudio();
//TestSaveLoad test;

void setup(){
  //test = new TestSaveLoad();
  // test = new TestAudio(); // create here due to loading weights from file
  test = new Train4Layers();

	size(2000, 1000);
	// unit.show_config();
  frameRate(30);
  MidiBus.list(); 
  myBus = new MidiBus(this, midiDevice, 1); 
  
  test_type = VIDEO;

  switch(test_type){
    case AUDIO:
      setupAudio();
      break;
    case VIDEO:
    default:
      setupMovie();
  }
  
}

void setupAudio() {
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

void setupMovie() {
  myMovie = new Movie(this, "test.mp4");
  myMovie.loop();
}

float[][] updateAudio() {
  fft.analyze(spectrum);
  for(int i = 0; i < bands; i++){
    // The result of the FFT is normalized
    // draw the line for frequency band i scaling it up by 5 to get more amplitude.
    if(i < maxband)
      specbuf[i].append(spectrum[i]);
  }
  float[][] viz = bufferArrayToMatrix(specbuf);
  return viz;
}

float[][] updateMovie() {
  if (myMovie.available()) {
    myMovie.read();
  }
  return getColorGrid(myMovie, 1);
}

void update(){
  float[][] viz;
  switch(test_type){
    case AUDIO:
      viz = updateAudio();
      break;
    case VIDEO:
    default:
      viz = updateMovie();
  }
  
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
