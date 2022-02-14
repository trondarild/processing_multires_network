class Test4LayersLoad {
    String modelname = "Test Multires four layers";
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

    int savectr = 0;
    int saveinterval = 50;

    String fname = "layertrain4b.json";
    
    Test4LayersLoad() {
        String l1w_name = "L1_rfx=3_rfy=3_incx=3_incy=3_somx=12_somy=3_block=3_span=0.dat";
        float[][][][] wl1 = loadWeights(l1w_name, 3, 12, 3, 3);

        // w 62 h 38 -> 5, 3
        spec_l1.input_size_x = 26;
        spec_l1.input_size_y = 14;
        spec_l1.rf_size_x = 3;
        spec_l1.rf_size_y = 3;
        spec_l1.som_size_x = 12;
        spec_l1.som_size_y = 3;
        spec_l1.rf_inc_x = 1;
        spec_l1.rf_inc_y = 1;
        spec_l1.rnd_mean = 0.01;
        spec_l1.block_size_x = 3;
        spec_l1.block_size_y = 3;
        
        layer_1 = new MultiResLayer(spec_l1, "Layer 1");
        layer_1.weights(wl1);

        String l2w_name = "L2_rfx=36_rfy=9_incx=36_incy=9_somx=20_somy=10_blockx=36_blocky=9_spanx=24_spany=6.dat";
        float[][][][] wl2 = loadWeights(l2w_name, 10, 20, 9, 36);
        
        spec_l2.input_size_x = layer_1.outputUpSize()[1];
        spec_l2.input_size_y = layer_1.outputUpSize()[0];
        spec_l2.som_size_x = 20;
        spec_l2.som_size_y = 10;
        spec_l2.rf_size_x = 36; //2 * spec_l1.som_size_x;
        spec_l2.rf_size_y = 9;//2 * spec_l1.som_size_y;
        spec_l2.rf_inc_x = 36;//spec_l1.som_size_x;
        spec_l2.rf_inc_y = 9;//spec_l1.som_size_y;
        spec_l2.span_size_x = 24;//1 * spec_l1.som_size_x;
        spec_l2.span_size_y = 6;//1 * spec_l1.som_size_y;
        spec_l2.block_size_x = 36;//spec_l1.som_size_x;
        spec_l2.block_size_y = 9;//spec_l1.som_size_y;
        spec_l2.rnd_mean = 0.001;
        spec_l2.alpha = 0.0001;

        layer_2 = new MultiResLayer(spec_l2, "Layer 2");
        layer_2.weights(wl2);
        println("layer2 mapsize: " + spec_l2.map_size_y + ", " + spec_l2.map_size_x);
        println("layer2 logical size: " + spec_l2.map_size_y / spec_l2.som_size_y + ", " + spec_l2.map_size_x / spec_l2.som_size_x);
        
        String l3w_name = "L3_rfx=40_rfy=20_incx=40_incy=20_somx=24_somy=12_blockx=40_blocky=20_spanx=100_spany=50.dat";
        float[][][][] wl3 = loadWeights(l3w_name, 12, 24, 20, 40);

        spec_l3.input_size_x = layer_2.outputUpSize()[1];
        spec_l3.input_size_y = layer_2.outputUpSize()[0];
        spec_l3.som_size_x = 24; // 4;
        spec_l3.som_size_y = 12; // 5;
        spec_l3.rf_size_x = 40; // 2 * spec_l2.som_size_x;
        spec_l3.rf_size_y = 20; // 2 * spec_l2.som_size_y;
        spec_l3.rf_inc_x = 40; // spec_l2.som_size_x;
        spec_l3.rf_inc_y = 20; // spec_l2.som_size_y;
        spec_l3.span_size_x = 100; // 1 * spec_l2.som_size_x;
        spec_l3.span_size_y = 50; // 1 * spec_l2.som_size_y;
        spec_l3.block_size_x = 40; // spec_l2.som_size_x;
        spec_l3.block_size_y = 20; // spec_l2.som_size_y;
        spec_l3.rnd_mean = 0.001;
        spec_l3.alpha = 0.0001;

        layer_3 = new MultiResLayer(spec_l3, "Layer 3");
        layer_3.weights(wl3);
        println("layer3 mapsize: " + spec_l3.map_size_y + ", " + spec_l3.map_size_x);
        println("layer3 logical size: " + spec_l3.map_size_y / spec_l3.som_size_y + ", " + spec_l3.map_size_x / spec_l3.som_size_x);


        // String l4w_name = "L4_rfx=48_rfy=24_incx=48_incy=24_somx=32_somy=16_blockx=48_blocky=24_spanx=264_spany=132.dat";
        //String l4w_name = "L4_rfx=48_rfy=24_incx=48_incy=24_somx=32_somy=16_blockx=48_blocky=24_spanx=0_spany=0.dat";
        //float[][][][] wl4 = loadWeights(l4w_name, 16, 32, 12, 24);// 24, 48);
        spec_l4.input_size_x = layer_3.outputUpSize()[1];
        spec_l4.input_size_y = layer_3.outputUpSize()[0];
        spec_l4.som_size_x = 32;
        spec_l4.som_size_y = 16;
        spec_l4.rf_size_x = 48; // 2 * spec_l3.som_size_x;
        spec_l4.rf_size_y = 24; // 2 * spec_l3.som_size_y;
        spec_l4.rf_inc_x = 48; // spec_l3.som_size_x;
        spec_l4.rf_inc_y = 24; // spec_l3.som_size_y;
        spec_l4.span_size_x = 264; // 1 * spec_l3.som_size_x;
        spec_l4.span_size_y = 132; // 1 * spec_l3.som_size_y;
        spec_l4.block_size_x = 48;// spec_l3.som_size_x;
        spec_l4.block_size_y = 24;// spec_l3.som_size_y;
        spec_l4.rnd_mean = 0.001;
        spec_l4.alpha = 0.0001;

        layer_4 = new MultiResLayer(spec_l4, "Layer 4");
        //layer_4.weights(wl4);
        println("layer4 mapsize: " + spec_l4.map_size_y + ", " + spec_l4.map_size_x);
        println("layer4 logical size: " + spec_l4.map_size_y / spec_l4.som_size_y + ", " + spec_l4.map_size_x / spec_l4.som_size_x);

        // try loading file
        if(createInput(fname)!= null)
          this.load(fname);
        else {
          println(fname + " was not found.");
        }

    }

    void init(float[][] inp) {
        //printSize(inp, "inp");
        this.data = scaleMatrixToSize(inp, spec_l1.input_size_x, spec_l1.input_size_y);;
        data_y = (this.data.length / 2) - (spec_l1.input_size_y / 2);
        data_x = (this.data[0].length / 2) - (spec_l1.input_size_x / 2);
    }

    void setInput(float[] inp) {
        
    }

    void save(String name) {
        
        // println(l1w.toString());
        JSONArray stack = new JSONArray();
        stack.setJSONObject(0, layer_1.toJSON());
        stack.setJSONObject(1, layer_2.toJSON());
        stack.setJSONObject(2, layer_3.toJSON());
        stack.setJSONObject(3, layer_4.toJSON());
        saveJSONArray(stack, "data/" + name);
        

    }

    void load(String name) {

            // load it
        JSONArray loadvalues = loadJSONArray(name);
        
        // println(loadvalues.toString());
        MultiResLayer[] layers = {layer_1, layer_2, layer_3, layer_4};
        for (int i = 0; i < loadvalues.size(); i++) {
            JSONObject l = loadvalues.getJSONObject(i);
            layers[i].fromJSON(l);
        }
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
        //layer_1.inputDown(train_1 ? layer_1.outputUp() : layer_2.outputDown());
        layer_1.inputDown(layer_2.outputDown());
        layer_1.cycle();

        layer_2.inputUp(layer_1.outputUp());
        //layer_2.inputDown(train_2 ? layer_2.outputUp() : layer_3.outputDown());
        layer_2.inputDown(layer_3.outputDown());
        layer_2.cycle();

        layer_3.inputUp(layer_2.outputUp());
        //layer_3.inputDown(train_3 ? layer_3.outputUp() : layer_4.outputDown());
        layer_3.inputDown(layer_4.outputDown());
        layer_3.cycle();

        layer_4.inputUp(layer_3.outputUp());
        layer_4.inputDown(layer_4.outputUp());
        layer_4.cycle();
        //printMatrix("w", layer.weightViz());

        if(savectr++ % saveinterval == 0) this.save(this.fname);
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
        
        drawImage(subm, "Input", 7);
        
        translate(0, 250);
        float[] scl1 = {0.05, 0.2, 7}; // output weights topdown
        drawLayer(layer_1, scl1);
        
        translate(450, 0);
        float[] scl2 = {0.1,0.25,0.2};
        drawLayer(layer_2, scl2);

        translate(450, 0);
        float[] scl3 = {0.1,0.2,0.2};
        drawLayer(layer_3, scl3);
 
        translate(450, 0);
        float[] scl4 = {3,0.025,3};
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

    float[][][][] loadWeights(String fname, int somy, int somx, int rfy, int rfx) {
        String s[] = loadStrings(fname);
        String spl[] = splitTokens(s[0], "\t");
        println("weight length : " + spl.length);
        float[] w = ones(spl.length);
        for (int i = 0; i < w.length; ++i) {
            w[i] = float(spl[i]);
        }
        float[][][][] retval = mapTo4d(w, somy, somx, rfy, rfx);
        return retval;
    }

}
