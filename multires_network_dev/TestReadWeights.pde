class TestReadWeights {
    String name = "Test template";
    int inputvecsize = 3;
    float[] inputval = zeros(inputvecsize);
    float[][][][] ww;
    float[][] im;
    int rfx=3; 
    int rfy=3; 
    int incx=3; 
    int incy=3; 
    int somx=12; 
    int somy=3; 
    int block=3; 
    int span=0;
    TestReadWeights() {
        /**
        L1_
        rfx=3 _rfy=3 
        _incx=3 _incy=3 
        _somx=12 _somy=3 
        _block=3 
        _span=0
        */
        
        String fname = "L1_rfx=3_rfy=3_incx=3_incy=3_somx=12_somy=3_block=3_span=0.dat";
        //byte b[] = loadBytes(); 
        String s[] = loadStrings(fname);
        String spl[] = splitTokens(s[0], "\t");
        float[] w = zeros(spl.length);
        for (int i = 0; i < w.length; ++i) {
            w[i] = float(spl[i]);
        }
        println(spl.length);
        println(spl[0]);
        //println(w);
        ww = mapTo4d(multiply(1,w), somy, somx, rfy, rfx);
        //println(ww);
        im = generateWeightOutput(ww);

    }

    void setInput(float[] inp) {
        
    }

    void init(float[][] a){}

    void tick() {

    }

    void draw() {
        translate(50,50);
        scale(2);
        drawMatrix4(10, 10, ww);
        translate(200, 0);
        drawImage(im, "weights", 3);
    }
    float[][] generateWeightOutput(float[][][][] w) {
        // map 1:1 to a 2 dim array
        int som_size_y = w.length;
        int som_size_x = w[0].length;
        int rf_size_y = w[0][0].length;
        int rf_size_x = w[0][0][0].length;
        float[][] retval = zeros(rf_size_y*som_size_y, rf_size_x*som_size_x); // weight visualiz
        for(int j=0; j<som_size_y; j++)
            for(int i=0; i<som_size_x; i++)
                for(int l=0; l<rf_size_y; l++)
                    for(int k=0; k<rf_size_x; k++)
                    {
                        float tmp = w[j][i][l][k];
                        retval[j*rf_size_y+l][i*rf_size_x+k] = tmp;
                    }
        return retval;
    }

    // io, keyboard, midi
    void handleKeyDown(char k){
        float[] ctx = zeros(inputvecsize);
        if (k=='z')
            ctx[0] = 1.f;
        else if(k=='x')
            ctx[1] = 1.f;
        else if(k=='c')
            ctx[2] = 1.f;

        this.setInput(ctx);

    }

    void handleKeyUp(char k){
        this.setInput(zeros(inputvecsize));
    }

    void handleMidi(int note, int vel){
        println("Note "+ note + ", vel " + vel);
        float scale = 1.0/127.0;
        if(note==81)
            inputval[0] = scale * vel; 
    }
    
    void drawGrid(float[][] g, String title) {
        pushMatrix();
        translate(10, 20);
        text(title, 0, 0);
        translate(0, 20);
        drawColGrid(0, 0, 3, 2, "", multiply(200, g));
        popMatrix();
    }
    
    void drawImage(float[][] d, String title, float scale) {
        pushMatrix();
        translate(10, 20);
        text(title, 0, 0);
        translate(0, 20);
        pushMatrix();
        scale(scale,scale);
        image(matrixToImage(d), 0,0);
        popMatrix();
        popMatrix();
    }

    void drawLayer(MultiResLayer layer, float[] scales) {
        float[] scl = {0.5, 2, 2.5};
        if(scales != null)
            scl = scales;
        pushMatrix();
        fill(60);
        rect(0, 0, 400, 400, 10);
        translate(10, 20);
        fill(250);
        text(layer.name, 0, 0);
        translate(0, 20);
        drawImage(layer.outputUp(), "Output up", scl[0]);
        
        pushMatrix();
        translate(120, 20);
        text("Update W", 0, 0);
        translate(0, 30);
        pushStyle();
        fill(0, layer.update_weights?200:0, 0);
        rect(0,0,20,20,5);
        popStyle();
        popMatrix();

        translate(200, 0);
        drawImage(layer.weightViz(), "Weights", scl[1]);
        
        translate(-200, 150);
        drawImage(layer.outputDown(), "Top down", scl[2]);    
        popMatrix();
    }
}
