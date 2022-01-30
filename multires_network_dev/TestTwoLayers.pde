class TestTwoLayers {
    String modelname = "Test Multires two layers";
    String description = "";
    int inputvecsize = 3;
    float[] inputval = zeros(inputvecsize);
    float[][] data;
    float[][] subm;
    float[][] regen;

    MultiResLayerSpec spec_l1 = new MultiResLayerSpec();
    MultiResLayerSpec spec_l2 = new MultiResLayerSpec();

    MultiResLayer layer_1;
    MultiResLayer layer_2;
    int data_x = 0;
    int data_y = 0;

    int ctr = 0;
    
    TestTwoLayers() {
        spec_l1.input_size_x = 64;
        spec_l1.input_size_y = 64;
        spec_l1.rf_size_x = 3;
        spec_l1.rf_size_y = 3;
        spec_l1.rnd_mean = 0.01;
        
        layer_1 = new MultiResLayer(spec_l1, "Layer 1");

        spec_l2.input_size_x = layer_1.outputUpSize()[1];
        spec_l2.input_size_y = layer_1.outputUpSize()[0];
        spec_l2.som_size_x = 3;
        spec_l2.som_size_y = 4;
        spec_l2.rf_size_x = 2 * spec_l1.som_size_x;
        spec_l2.rf_size_y = 2 * spec_l1.som_size_y;
        spec_l2.rf_inc_x = spec_l1.som_size_x;
        spec_l2.rf_inc_y = spec_l1.som_size_y;
        spec_l2.span_size_x = 2 * spec_l1.som_size_x;
        spec_l2.span_size_y = 2 * spec_l1.som_size_y;
        spec_l2.block_size_x = spec_l1.som_size_x;
        spec_l2.block_size_y = spec_l1.som_size_y;
        spec_l2.rnd_mean = 0.001;
        spec_l2.alpha = 0.005;

        layer_2 = new MultiResLayer(spec_l2, "Layer 2");


    }

    void init(float[][] inp) {
        data = inp;
    }

    void setInput(float[] inp) {
        
    }

    void tick() {
        if(ctr++ >= 9){
            layer_1.update_weights = false;
            layer_2.update_weights = true;
        }
        else {
            layer_1.update_weights = true;
            layer_2.update_weights = false;
        }
        data_y = int(random(data.length - spec_l1.input_size_y));
        data_x = int(random(data[0].length - spec_l1.input_size_x));
        subm = multiply(1.0/255, getSubmatrix(data_y, data_x, spec_l1.input_size_x, spec_l1.input_size_y, data));
        layer_1.inputUp(subm);
        layer_1.inputDown(layer_2.outputDown());
        layer_1.cycle();

        layer_2.inputUp(layer_1.outputUp());
        layer_2.inputDown(layer_2.outputUp());
        layer_2.cycle();
        //printMatrix("w", layer.weightViz());
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
        
        drawImage(subm, "Input", 2.5);
        translate(0, 100);
        //drawGrid(layer.outputUp(), "output up");
        //image(matrixToImage(layer.outputUp()), 0,0);
        drawImage(layer_2.outputUp(), "Output l2", 0.5);
        translate(200, 0);
        //drawGrid(layer.weightViz(), "weights");
        //image(matrixToImage(layer.weightViz()), 0, 0);
        drawImage(layer_2.weightViz(), "Weights l2", 2);
        translate(0, 100);
        //drawGrid(layer.outputDown(), "regeneration");
        //image(matrixToImage(layer.outputDown()), 0,0);
        drawImage(layer_1.outputDown(), "Top down l1", 2.5);    
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

}