class TestMatrixOps {
    String name = "Test matrix ops";
    int inputvecsize = 3;
    float[] inputval = zeros(inputvecsize);
    TestMatrixOps() {

        int tilings = 2;
        float[][] tst = {{1,2,4}, {4,5,6}, {7,8,9}};

        float[] tst_rav = ravel(tst);
        printArray("tst_rav", tst_rav);

        float[][] tst_row_tile = tileRows(tilings, tst);
        printMatrix("tst_row_tile", tst_row_tile);

        float[] tst_row_tile_rav = ravel(tst_row_tile);
        printArray("tst_row_tile_rav", tst_row_tile_rav);




    }

    void setInput(float[] inp) {
        
    }

    void tick() {

    }

    void draw() {

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

}
