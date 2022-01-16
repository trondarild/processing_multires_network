class TestIm2Row {
    String modelname = "Test im2row";
    float[][] img;
    int inputvecsize = 3;
    float[] inputval = zeros(inputvecsize);
    float[][] im_row;
    float[][] row_im;
    

    

    int rf_x = 5; // size of receptive field
    int rf_y = 5;
    int blk_x = 5; // partition size for receptive fields, when using spans: blocks is fraction of rf_size
    int blk_y = 5;
    int spn_x = 0; // spacing between blocks; 0 in first layers
    int spn_y = 0;
    int rf_inc_x = 1; // increment for rf windowing
    int rf_inc_y = 1;

    int map_x;
    int map_y;

    int red = 1;
    int green = 2;

    TestIm2Row() {
        
    }

    void init(float[][] img){
        this.img = img;
        map_x = calcMapSize(
            img[0].length, 
            rf_x, blk_x, spn_x, rf_inc_x);
        map_y = calcMapSize(
            img.length, 
            rf_y, blk_y, spn_y, rf_inc_y);
        int im_row_x = rf_x*rf_y;
        int im_row_y = map_x*map_y;    
        im_row = spanned_im2row(
            this.img,
            //im_row_y, im_row_x,
            map_x, map_y,
            rf_x, rf_y,
            rf_inc_x, rf_inc_y,
            blk_x, blk_y,
            spn_x, spn_y);

        row_im = spanned_row2im(
            im_row,
            img[0].length, img.length,
            map_x, map_y,
            rf_x, rf_y,
            rf_inc_x, rf_inc_y,
            blk_x, blk_y,
            spn_x, spn_y
        );

    }

    void tick() {
        // first im2row
        
        


    }

    void draw() {
        pushMatrix();
        translate(10,20);
        text(modelname, 0, 0);
        popMatrix();

        // pushMatrix();
        // translate(10,40);
        // image(img, 0, 0);
        // popMatrix();

        pushMatrix();
        translate(10, 50);
        scale(0.1,0.1);
        drawColGrid(0,0, 5, img);
        popMatrix();

        pushMatrix();
        translate(200, 50);
        scale(0.1,0.00325);
        drawColGrid(0,0, 5, im_row);
        popMatrix();

        pushMatrix();
        translate(10, 250);
        scale(0.1,0.1);
        drawColGrid(0,0, 5, multiply(0.05, row_im));
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

    int calcMapSize (
        int inpsz,
        int rfsz,
        int blksz,
        int spansz,
        int inc) {
    
        return (inpsz-(rfsz+(rfsz/blksz-1)*spansz)) /(inc) + 1;
    }

}
