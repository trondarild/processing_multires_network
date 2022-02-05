


class TestAudio {
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

    boolean train_1 = false;
    boolean train_2 = false;

    int savectr = 0;
    int saveinterval = 50;

    String fname = "audiotest.json";

    float cosindiff = 0;
    Buffer diffbuff = new Buffer(100);
    Buffer avgbuff = new Buffer(100);
    
    TestAudio() {

        
        spec_l1.input_size_x = 32;
        spec_l1.input_size_y = 32;
        spec_l1.rf_size_x = 3;
        spec_l1.rf_size_y = 3;
        spec_l1.rnd_mean = 0.01;
        spec_l1.alpha = 0.01;
        
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
        spec_l2.rnd_mean = 0.01;
        spec_l2.alpha = 0.001;

        layer_2 = new MultiResLayer(spec_l2, "Layer 2");

        // try loading file
        if(createInput(fname)!= null)
          this.load(fname);
        else {
          println(fname + " was not found.");
        }



    }

    void init(float[][] inp) {
        data = inp;
    }

    void setInput(float[] inp) {
        
    }

    void save(String name) {
        
        // println(l1w.toString());
        JSONArray stack = new JSONArray();
        stack.setJSONObject(0, layer_1.toJSON());
        stack.setJSONObject(1, layer_2.toJSON());
        saveJSONArray(stack, "data/" + name);
        

    }

    void load(String name) {

            // load it
        JSONArray loadvalues = loadJSONArray(name);
        
        // println(loadvalues.toString());
        MultiResLayer[] layers = {layer_1, layer_2};
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
        data_y = int(random(data.length - spec_l1.input_size_y));
        data_x = int(random(data[0].length - spec_l1.input_size_x));
        // subm = multiply(1.0/255, getSubmatrix(data_y, data_x, spec_l1.input_size_x, spec_l1.input_size_y, data));
        subm = data;
        layer_1.inputUp(multiply(10, subm));
        layer_1.inputDown(train_1?layer_1.outputUp() : layer_2.outputDown());
        layer_1.cycle();

        layer_2.inputUp(layer_1.outputUp());
        layer_2.inputDown(layer_2.outputUp());
        layer_2.cycle();
        //printMatrix("w", layer.weightViz());
        if(savectr++ % saveinterval == 0) this.save(this.fname);

        // calculate cosine diff
        cosindiff = cosine_diff(transpose(data)[0], transpose(layer_1.outputDown())[0]);
        diffbuff.append(cosindiff);
        avgbuff.append(mean(diffbuff.array()));
        
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
        
        drawImage(multiply(200, subm), "Input", 2.5);

        
        pushMatrix();
        translate(100, 0);
        scale(1.2);
        text("Avg Cosine diff:" + avgbuff.array()[0], 0, 0);
        popMatrix();

        pushMatrix();
        translate(150, 0);
        // drawTimePlot(diffbuff.array(), "Diff");
        drawTimeSeries(avgbuff.array(), 1.2, 1, 0);
        popMatrix();
        
        translate(0, 250);
        float[] scl1 = {0.5, 7, 2.5}; // output weights topdown
        drawLayer(layer_1, scl1);
        
        translate(450, 0);
        float[] scl2 = {0.3,4,0.75};
        drawLayer(layer_2, scl2);
        
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
        drawImage(multiply(20, layer.outputDown()), "Top down", scl[2]);    
        popMatrix();
    }

}
