class TestMRNotWU {
    String modelname = "Test Multires no weight upd";
    String description = "";
    int inputvecsize = 3;
    float[] inputval = zeros(inputvecsize);
    float[][] data;
    float[][] subm;
    float[][] regen;

    MultiResLayerSpec spec = new MultiResLayerSpec();
    MultiResLayer layer;
    int data_x = 0;
    int data_y = 0;
    
    TestMRNotWU() {
        spec.input_size_x = 16;
        spec.input_size_y = 16;
        spec.rf_size_x = 3;
        spec.rf_size_y = 3;
        spec.rnd_mean = 0.01;
        
        layer = new MultiResLayer(spec, "Layer");
    }

    void init(float[][] inp) {
        data = inp;
    }

    void setInput(float[] inp) {
        
    }

    void tick() {
                data_y = int(random(data.length - spec.input_size_y));
        data_x = int(random(data[0].length - spec.input_size_x));
        subm = multiply(1.0/255, getSubmatrix(data_y, data_x, spec.input_size_x, spec.input_size_y, data));
        layer.inputUp(subm);
        layer.inputDown(layer.outputUp());
        layer.cycle();
        printMatrix("w", layer.weightViz());
    }

    void draw() {
        pushMatrix();
        
        pushMatrix();
        translate(10,20);
        text(modelname, 0, 0);
        translate(0,20);
        text(description, 0, 0);
        popMatrix();

        //printArray("input layer output", inp_viz[0]);
        
        translate(10,50);
        pushMatrix();
        drawGrid(subm, "input up");
        translate(0, 100);
        drawGrid(layer.outputUp(), "output up");
        translate(200, 0);
        drawGrid(layer.weightViz(), "weights");
        translate(0, 100);
        drawGrid(layer.outputDown(), "regeneration");
            
        popMatrix();

        popMatrix();
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

}
