class Test4Layers {
    String modelname = "Test Multires two layers";
    String description = "";
    int inputvecsize = 3;
    float[] inputval = zeros(inputvecsize);
    float[][] data;
    float[][] subm;
    float[][] regen;

    MultiResLayerSpec spec_l1 = new MultiResLayerSpec();
    MultiResLayerSpec spec_l2 = new MultiResLayerSpec();
    MultiResLayerSpec spec_l3 = new MultiResLayerSpec();
    MultiResLayerSpec spec_l4 = new MultiResLayerSpec();

    MultiResLayer layer_1;
    MultiResLayer layer_2;
    MultiResLayer layer_3;
    MultiResLayer layer_4;
    int data_x = 0;
    int data_y = 0;

    int ctr = 0;

    boolean train_1 = false;
    boolean train_2 = false;
    boolean train_3 = false;
    boolean train_4 = false;
    
    Test4Layers() {
        spec_l1.input_size_x = 64;
        spec_l1.input_size_y = 64;
        spec_l1.rf_size_x = 4;
        spec_l1.rf_size_y = 3;
        spec_l1.rnd_mean = 0.01;
        
        layer_1 = new MultiResLayer(spec_l1, "Layer 1");

        
        spec_l2.input_size_x = layer_1.outputUpSize()[1];
        spec_l2.input_size_y = layer_1.outputUpSize()[0];
        spec_l2.som_size_x = 3;
        spec_l2.som_size_y = 4;
        spec_l2.rf_size_x = 4 * spec_l1.som_size_x;
        spec_l2.rf_size_y = 4 * spec_l1.som_size_y;
        spec_l2.rf_inc_x = spec_l1.som_size_x;
        spec_l2.rf_inc_y = spec_l1.som_size_y;
        spec_l2.span_size_x = 2 * spec_l1.som_size_x;
        spec_l2.span_size_y = 2 * spec_l1.som_size_y;
        spec_l2.block_size_x = spec_l1.som_size_x;
        spec_l2.block_size_y = spec_l1.som_size_y;
        spec_l2.rnd_mean = 0.001;
        spec_l2.alpha = 0.0001;

        layer_2 = new MultiResLayer(spec_l2, "Layer 2");
        println("layer2 mapsize: " + spec_l2.map_size_y + ", " + spec_l2.map_size_x);
        println("layer2 logical size: " + spec_l2.map_size_y / spec_l2.som_size_y + ", " + spec_l2.map_size_x / spec_l2.som_size_x);
        
        spec_l3.input_size_x = layer_2.outputUpSize()[1];
        spec_l3.input_size_y = layer_2.outputUpSize()[0];
        spec_l3.som_size_x = 4;
        spec_l3.som_size_y = 5;
        spec_l3.rf_size_x = 4 * spec_l2.som_size_x;
        spec_l3.rf_size_y = 4 * spec_l2.som_size_y;
        spec_l3.rf_inc_x = spec_l2.som_size_x;
        spec_l3.rf_inc_y = spec_l2.som_size_y;
        spec_l3.span_size_x = 2 * spec_l2.som_size_x;
        spec_l3.span_size_y = 2 * spec_l2.som_size_y;
        spec_l3.block_size_x = spec_l2.som_size_x;
        spec_l3.block_size_y = spec_l2.som_size_y;
        spec_l3.rnd_mean = 0.001;
        spec_l3.alpha = 0.0001;

        layer_3 = new MultiResLayer(spec_l3, "Layer 3");
        println("layer3 mapsize: " + spec_l3.map_size_y + ", " + spec_l3.map_size_x);
        println("layer3 logical size: " + spec_l3.map_size_y / spec_l3.som_size_y + ", " + spec_l3.map_size_x / spec_l3.som_size_x);

        spec_l4.input_size_x = layer_3.outputUpSize()[1];
        spec_l4.input_size_y = layer_3.outputUpSize()[0];
        spec_l4.som_size_x = 8;
        spec_l4.som_size_y = 8;
        spec_l4.rf_size_x = 4 * spec_l3.som_size_x;
        spec_l4.rf_size_y = 4 * spec_l3.som_size_y;
        spec_l4.rf_inc_x = spec_l3.som_size_x;
        spec_l4.rf_inc_y = spec_l3.som_size_y;
        spec_l4.span_size_x = 2 * spec_l3.som_size_x;
        spec_l4.span_size_y = 2 * spec_l3.som_size_y;
        spec_l4.block_size_x = spec_l3.som_size_x;
        spec_l4.block_size_y = spec_l3.som_size_y;
        spec_l4.rnd_mean = 0.001;
        spec_l4.alpha = 0.0001;

        layer_4 = new MultiResLayer(spec_l4, "Layer 4");
        println("layer4 mapsize: " + spec_l4.map_size_y + ", " + spec_l4.map_size_x);
        println("layer4 logical size: " + spec_l4.map_size_y / spec_l4.som_size_y + ", " + spec_l4.map_size_x / spec_l4.som_size_x);

    }

    void init(float[][] inp) {
        data = inp;
        data_y = data.length / 2 - spec_l1.input_size_y / 2;
        data_x = data[0].length / 2 - spec_l1.input_size_y / 2;
    }

    void setInput(float[] inp) {
        
    }

    void tick() {
        // if(ctr++ >= 20){
        //     layer_1.update_weights = false;
        //     layer_2.update_weights = true;
        // }
        // else {
        //     layer_1.update_weights = true;
        //     layer_2.update_weights = false;
        // }
        layer_1.update_weights = train_1;
        layer_2.update_weights = train_2;
        layer_3.update_weights = train_3;
        layer_4.update_weights = train_4;


        // data_y = int(random(data.length - spec_l1.input_size_y));
        // data_x = int(random(data[0].length - spec_l1.input_size_x));
        // data_y = data.length / 2 - spec_l1.input_size_y / 2;
        // data_x = data[0].length / 2 - spec_l1.input_size_y / 2;
        subm = multiply(1.0/255, getSubmatrix(data_y, data_x, spec_l1.input_size_x, spec_l1.input_size_y, data));
        
        layer_1.inputUp(subm);
        layer_1.inputDown(train_1 ? layer_1.outputUp() : layer_2.outputDown());
        layer_1.cycle();

        layer_2.inputUp(layer_1.outputUp());
        layer_2.inputDown(train_2 ? layer_2.outputUp() : layer_3.outputDown());
        layer_2.cycle();

        layer_3.inputUp(layer_2.outputUp());
        layer_3.inputDown(train_3 ? layer_3.outputUp() : layer_4.outputDown());
        layer_3.cycle();

        layer_4.inputUp(layer_3.outputUp());
        layer_4.inputDown(layer_4.outputUp());
        layer_4.cycle();
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
        
        translate(0, 250);
        float[] scl1 = {0.5, 7, 2.5}; // output weights topdown
        drawLayer(layer_1, scl1);
        
        translate(450, 0);
        float[] scl2 = {0.5,4,0.75};
        drawLayer(layer_2, scl2);

        translate(450, 0);
        float[] scl3 = {0.5,3,0.75};
        drawLayer(layer_3, scl3);

        translate(450, 0);
        float[] scl4 = {0.35,0.75,0.55};
        drawLayer(layer_4, scl4);
        
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
        if(note==65)
            train_1 = vel > 120;
        if(note==66)
            train_2 = vel > 120;
        if(note==67)
            train_3 = vel > 120;
        if(note==68)
            train_4 = vel > 120;
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
        //float[][] trainon = {{layer.update_weights?1:0}};
        translate(120, 20);
        text("Update W", 0, 0);
        translate(0, 30);
        pushStyle();
        fill(0, layer.update_weights?200:0, 0);
        rect(0,0,20,20,5);
        popStyle();
        popMatrix();

        translate(200, 0);
        //drawGrid(layer.weightViz(), "weights");
        //image(matrixToImage(layer.weightViz()), 0, 0);
        drawImage(layer.weightViz(), "Weights", scl[1]);
        translate(-200, 150);
        //drawGrid(layer.outputDown(), "regeneration");
        //image(matrixToImage(layer.outputDown()), 0,0);
        drawImage(layer.outputDown(), "Top down", scl[2]);    
        popMatrix();
    }

}
