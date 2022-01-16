// Dev sketch of multires network
//

PImage img;

void setup() {
  size(400,400);
  img = loadImage("testimg.png");
}

void draw() {
  image(img, 0, 0);
}
