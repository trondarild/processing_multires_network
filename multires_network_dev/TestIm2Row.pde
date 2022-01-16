class TestIm2Row {
    String name = "Test template";
    PImage img;
    int inputvecsize = 3;
    float[] inputval = zeros(inputvecsize);
    

    TestIm2Row() {
        
    }

    void tick() {

    }

    void draw() {
        pushMatrix();
        translate(10,10);
        image(img, 0, 0);
        popMatrix();
    }

    // io, keyboard, midi
    // io, keyboard, midi
    void handleKeyDown(char k){
        float[] ctx = zeros(inputvecsize);
        if (k=='z')
            ctx[0] = 1.f;
        else if(k=='x')
            ctx[1] = 1.f;
        else if(k=='c')
            ctx[2] = 1.f;

        //this.setInput(ctx);

    }

    void handleKeyUp(char k){
        //this.setInput(zeros(inputvecsize));
    }

    void handleMidi(int note, int vel){
        println("Note "+ note + ", vel " + vel);
        float scale = 1.0/127.0;
        if(note==81)
            inputval[0] = scale * vel; 
    }

}
