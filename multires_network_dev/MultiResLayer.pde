/** Neural unit for multires network

*/
class MultiResLayer {
    String name;
    MultiResLayerSpec spec;
    boolean update_weights = true;

    float[][] input_up;
    float[][] output_up;
    float[][] input_down;
    float[][] output_down;
    float[][][][] activity;
    float[][] reconstruction;

    float[][][][] w; // weights
    float[][][][] dw; // weights
    float[][] weights_viz;


    


    MultiResLayer(MultiResLayerSpec spec, String name) {
        this.spec = spec;
        this.name = name;
        this.spec.init(this); // calculate all sizes and init arrays
    }

    void inputUp(float[][] inp){
        // upward, learning, transforming
        input_up = inp;
    }

    void inputDown(float[][] inp){
        // downward, generative
        input_down = inp;

    }

    float[][] outputUp(){
        return output_up;
    }

    float[][] outputDown() {
        return output_down;
    }

    int[] outputUpSize() {
        int[] sz = new int[2];
        sz[0] = output_up.length;
        sz[1] = output_up[0].length;
        return sz;
    }

    float[][] weightViz() {
        
        
        return this.weights_viz;
    }

    void cycle() {
        this.spec.cycle(this);

    }




    

    
}

class MultiResLayerSpec {
    int         rf_size_x = 3; 
    int         rf_size_y = 3;
    int         rf_inc_x = 1;
    int         rf_inc_y = 1;

    int         border_mult = 0;
    int         map_size_x_scr;
    int         map_size_y_scr;

    int         som_size_x = 3; // number of neural units per rf size area
    int         som_size_y = 3;
    
    int         input_size_x;
    int         input_size_y;

    int map_size_x; // calculated
    int map_size_y;

    int         buffer_size_x;
    int         buffer_size_y;

    int         learning_buffer_size;

    int         block_size_x = rf_size_x;       // size of sub-block of rf - used for layers > 1
    int         block_size_y = rf_size_y;

    int         span_size_x = 0;       // spacing between sub-blocks of rf 
    int         span_size_y = 0;
    
    
    int         output_type;       // 0 = combined, 1 = separate 
    
    float		alpha = 0.05;              // RF learning constant
    float		alpha_min = 0.01;
    float		alpha_max = 0.1;
    float		alpha_decay = 0.001;

    float       rnd_mean = 0.1;
    float       rnd_var = 0.01;
	
	boolean		use_arbor;
    boolean     use_top_down = true;

    float       act_gain = 1.0;


    MultiResLayerSpec() {

    }

    void init(MultiResLayer unit) {
        // unit.input_up = zeros();
        map_size_x = calcMapSize(
            this.input_size_x,
            this.rf_size_x,
            this.block_size_x,
            this.span_size_x,
            this.rf_inc_x
        );
        map_size_y = calcMapSize(
            this.input_size_y,
            this.rf_size_y,
            this.block_size_y,
            this.span_size_y,
            this.rf_inc_y
        );
        unit.output_up = zeros(map_size_y*som_size_y, map_size_x*som_size_y);
        unit.input_down = zeros(map_size_y*som_size_y, map_size_x*som_size_y);
        unit.output_down = zeros(input_size_y, input_size_x);
        unit.activity = zeros(som_size_x, som_size_y, map_size_x, map_size_y);
        // unit.reconstruction = zeros(input_size_y, input_size_x);
        unit.w = randomMatrix4(som_size_x, som_size_y, rf_size_x, rf_size_y, rnd_mean + rnd_var); // weights
        unit.dw = zeros(som_size_x, som_size_y, rf_size_x, rf_size_y); // weights
        unit.weights_viz = zeros(rf_size_y*som_size_y, rf_size_x*som_size_x); // weight visualiz
    }

    void cycle(MultiResLayer unit) {
        calcFwdActivation(unit);
        if(unit.update_weights) updateWeights(unit);
        calcBkwActivation(unit);
        generateOutput(unit);
        generateWeightOutput(unit);
    }

    void calcFwdActivation(MultiResLayer unit){
        // int input_size_x = unit.input_up[0].length;
        // int input_size_y = unit.input_up.length;
        // int inp_scr_x = input_size_x + 2*border_mult * span_size_x;
        // int inp_scr_y = input_size_y + 2*border_mult * span_size_y;
        // int offset_x = (map_size_x_scr - map_size_x) / 2;
        // int offset_y = (map_size_y_scr - map_size_y) / 2;
        float[][] input = unit.input_up;

        float[][] buffer = spanned_im2row(input, map_size_x, map_size_y, 
            rf_size_x, rf_size_y, 
            rf_inc_x, rf_inc_y, 
            block_size_x, block_size_y, 
            span_size_x, span_size_y);
        // printMatrix("buffer", buffer);
        // printMatrix("w", unit.w[0][0]);
        for (int sj = 0; sj < som_size_y; sj++) 
            for (int si = 0; si < som_size_x; si++)
            {
                // im2row(buffer, input, map_size_x, map_size_y, input_size_x, input_size_y, rf_size_x, rf_size_y, rf_inc_x, rf_inc_y);
                //reset_matrix(activity_scratch, map_size_x_scr, map_size_y_scr);
                float[][] tmp = {ravel(unit.w[sj][si])};
                //unit.activity[sj][si] = arrayToMatrix(xx1(ravel(dotProd(buffer, tmp))), map_size_y, map_size_x);
                unit.activity[sj][si] = arrayToMatrix(ravel(dotProd(buffer, tmp)), map_size_y, map_size_x);
                
            }
    
    }

    void calcBkwActivation(MultiResLayer unit) {
        if(!use_top_down) return;
        // normalize_max(reconstruction, input_size_x, input_size_y); // TODO: Check that this is ok
        unit.output_down = regenerate(
            unit.input_down,
            unit.w,
            map_size_x, map_size_y);
        
    }

    float[][] regenerate(float[][] in, float[][][][] w, int map_x, int map_y) {
        float[][] topdown_buffer = spanned_im2row(in,
            map_x, map_y,
            this.som_size_x, this.som_size_y,
            this.som_size_x, this.som_size_y,
            this.som_size_x, this.som_size_y,
            0,0);
        println("topdownbuf: " + topdown_buffer.length + ", " + topdown_buffer[0].length);
        //float[][] tmp = zeros(buffer_size_x, buffer_size_y);
        // float[][] ww = arrayToMatrix(ravel(w), topdown_buffer.length, topdown_buffer[0].length);
        float[] ww = ravel(w);
        println("ww: " + ww.length);
        float[][] tmp = mult_per_elm(repeatCols(ww.length, topdown_buffer), tileRows(topdown_buffer.length, tileCols(topdown_buffer[0].length, ww))); //, buffer_size_x, buffer_size_y, 
        println("tmp: " + tmp.length + ", " + tmp[0].length);
        tmp = arrayToMatrix(ravel(tmp), tmp.length/rf_size_x*rf_size_y, rf_size_x*rf_size_y);
        //som_size_x*som_size_y);
        //printf("mult done\n" );
        // cumulative_take(out_reconstruction, tmp, indeces, ..) // spanned_row2im
        //reset_matrix(out_reconstruction, size_x, size_y);
        float[][] out_reconstruction = spanned_row2im(tmp, 
            in[0].length, in.length,
            map_x, map_y,
            rf_size_x, rf_size_y,
            rf_inc_x, rf_inc_y,
            block_size_x, block_size_y,
            span_size_x, span_size_y);

        //retval = normalize_max(retval);
        //printMatrix("topdown", out_reconstruction);
        //return normalize(topdown_buffer);
        return out_reconstruction;
    }

    void generateOutput(MultiResLayer unit) {
        if(output_type == 0) { // combined
        // iterate over streams
        
            // iterate over som lattice
            for(int j=0; j<som_size_y; j++)
                for(int i=0; i<som_size_x; i++)
                    // iterate over each "pixel" in map
                    for(int l=0; l<map_size_y; l++)
                        for(int k=0; k<map_size_x; k++)
                        {
                            int y = l*som_size_y+j;
                            int x = k*som_size_x+i;
                            // put ix = y*output_sz_y + x
                            // map the activity of all the maps to 2 dimensions
                            unit.output_up[y][x] = unit.activity[j][i][l][k];
                            // printf("j=%i, i=%i, l=%i, k=%i; x=%i, y=%i\n", j, i, l, k, x, y);
                        }

        }
        else if(output_type == 1) // separate
        
                for(int j=0; j<som_size_y; j++)
                    for(int i=0; i<som_size_x; i++)
                        for(int l=0; l<map_size_y; l++)
                            for(int k=0; k<map_size_x; k++)
                                unit.output_up[j*map_size_y+l][i*map_size_x+k] = unit.activity[j][i][l][k];
                                // 012 012 012
    }

    void generateWeightOutput(MultiResLayer unit) {
        // map 1:1 to a 2 dim array
        for(int j=0; j<som_size_y; j++)
            for(int i=0; i<som_size_x; i++)
                for(int l=0; l<rf_size_y; l++)
                    for(int k=0; k<rf_size_x; k++)
                    {
                        float tmp = unit.w[j][i][l][k];
                        unit.weights_viz[j*rf_size_y+l][i*rf_size_x+k] = tmp;
                    }
    }

    void updateWeights(MultiResLayer unit) {
        // do switch for algos
        updateWeights_4d(unit);
    }

    void updateWeights_mmlt_blnc(MultiResLayer unit) {
        /**
        // float **tmp_act_b = create_matrix(inp_rows, som_size_x);
        // float **tmp_act_b_t = create_matrix(som_size_x, inp_rows);
        // float **tmp_dw_t = create_matrix(som_size_x, kernelsize);

        
        // map activity and weights
        float[][] mapped_weights = mapFrom4d(unit.w, som_size_x, som_size_y, rf_size_x, rf_size_y);
        float[][] mapped_act = mapFrom4d(unit.activity, som_size_x, som_size_y, map_size_x, map_size_y);
        //print_matrix("mapped_weights", mapped_weights, kernelsize, numkernels, 6);
        //print_matrix("mapped_act", mapped_act, inp_rows, numkernels, 6);
        
        // float **mapped_inp = learning_buffer[str]; //learning_buffer; // result of im2row in forward activation
        //reset_matrix(inh_buffer[0], kernelsize, inp_rows*numkernels);
        int numkernels = som_size_y*som_size_x;
        int kernelsize = rf_size_x*rf_size_y;
        int inp_rows = map_size_y*map_size_x;
        float[][] mapped_dw = zeros(kernelsize, numkernels);
        //float[][] inh_prev = zeros(kernelsize, inp_rows);

        // try transpose both act and weights and transpose inh prev
        //multiply(inh_prev, &mapped_act[0], &mapped_weights[0], 
        //    kernelsize, inp_rows, som_size_x);
        float[][] tmp_act_b_t = transpose(mapped_act);
        //transpose(tmp_dw_t, &mapped_weights[0], som_size_x, kernelsize);

        inh_prev = dotProd(tmp_act_b_t, mapped_weights); //, 
            //kernelsize, inp_rows, som_size_x);
        //transpose(inh_prev, tmp_act_b_t, inp_rows, som_size_x);
        //printf("=====tick : %i=====\n", ctr);
        //print_matrix("inh_prev", inh_prev, kernelsize, inp_rows, 6);
        //for (int k = 0; k < numkernels; ++k)
        //    printf("mapped_act ptr initial %i: %p\n", k, (void*)mapped_act[k]);
        int startix=0;
        for (int kj = 0; kj < som_size_y; kj++)
        {
            //reset_matrix(tmp_outer, kernelsize, inp_rows); 
            float[][] tmp_ma = {mapped_act[startix]};
            float[][] tmp_act_b_t = transpose(tmp_ma); //mapped_act[startix]); 
            float[][] tmp_outer = dotProd(tmp_act_b_t, mapped_weights[startix]); 
                    //kernelsize, inp_rows, som_size_x);
            
            // ib += tmp_outer
            add(inh_prev, //inh_buffer[kj], 
                tmp_outer);
                //inh_prev,
                //kernelsize, inp_rows);
            
            //print_matrix("inh_buffer", inh_buffer[kj], kernelsize, inp_rows,6);
            //copy_matrix(inh_prev, inh_buffer[kj], kernelsize, inp_rows);
            // delta_buf = input-inh_prev
            //reset_matrix(delta_buf, kernelsize, inp_rows);
            float[][] delta_buf = subtract(mapped_inp, inh_prev);
            //print_matrix("delta_buf", delta_buf, kernelsize, inp_rows, 6);
            //reset_matrix(delta_buf_t, inp_rows, kernelsize);
            float[][] delta_buf_t = transpose(delta_buf);
            
            // tmp_act_b = mapped_act * alpha
            //reset_matrix(tmp_act_b, inp_rows, som_size_x);
            //multiply(tmp_act_b, &mapped_act[startix], alpha, inp_rows, som_size_x);
            
            //reset_matrix(tmp_act_b_t, som_size_x, inp_rows);
            //transpose(tmp_act_b_t, tmp_act_b, som_size_x, inp_rows);
            
            //tmp_act_b_t = transpose(tmp_ma);
            //printf("mapped_act ptr bef %i: %p w: %p\n", k, (void*)mapped_act[k], (void*)mapped_weights[k]);
            //print_array("dw bef", mapped_dw[k], kernelsize, 6);

            // tmp_dw_t =  delta_buf_t * tmp_act_b_t
            reset_matrix(tmp_dw_t, som_size_x, kernelsize);
            float[][] tmp_dw_t = multiply_per_elem(  delta_buf_t, tmp_act_b_t, som_size_x, kernelsize, inp_rows);
            //print_matrix("tmp_dw_t", tmp_dw_t, som_size_x, kernelsize, 6);
            transpose(&mapped_dw[startix], tmp_dw_t, kernelsize, som_size_x);
            //print_array("dw after", mapped_dw[k], kernelsize, 6);
            //print_matrix("mapped_dw", mapped_dw, kernelsize, numkernels, 6);

            //printf("mapped_act ptr aft %i: %p w: %p\n", k, (void*)mapped_act[k], (void*)mapped_weights[k]);
            startix += som_size_x;
        
            //print_array("dw", dw[k], kernelsize, 6);
        
        }
        
        //print_matrix("delta_buf", delta_buf, kernelsize, 5, 6);
        //print_matrix("tmp_act_b", tmp_act_b, inp_rows, som_size_x, 5);
        //print_matrix("dw", mapped_dw, kernelsize, 4,6);
        add(mapped_weights, mapped_weights, mapped_dw, kernelsize, numkernels);
        //add(mapped_weights, mapped_dw, kernelsize, numkernels);
        //if (ctr == 1400)
        //    print_matrix("map weights", mapped_weights, kernelsize, numkernels, 5);
        // map back
        MapTo4d(w, mapped_weights, som_size_x, som_size_y, rf_size_x, rf_size_y);
        // note: really necessary?:
        // MapTo4d(activity[str], mapped_act, som_size_x, som_size_y, map_size_x, map_size_y);
        //destroy_array(act_array);
        
        //destroy_matrix(tmp_act_b);
        //destroy_matrix(tmp_act_b_t);
        //destroy_matrix(tmp_dw_t);

        // ctr++;
        */
    }
    
    void updateWeights_4d (MultiResLayer unit) {
        float[][] input_buffer = zeros(rf_size_x, rf_size_y);
        // inhibition buffer is the size of the receptive field
        float[][] inhibition_buffer = zeros(rf_size_x, rf_size_y);
        float[][] delta_buffer = zeros(rf_size_x, rf_size_y);
        int rf_size = rf_size_x*rf_size_y;
        

        
        for(int mj=0; mj<map_size_y; mj++){
            for(int mi=0; mi<map_size_x; mi++){
                //    if(random(0.0, 1.0) > 0.05) break;
                
                // Perform learning once for each position in the map using the same SOm
                // since we are using weight sharing
                
                // fetch input to temporary (linear) buffer to simplify calculations
                // TODO: could this be done automatically by using a different data structure for the input?
                
                // input buffer is the size of the receptive field
                int rl = rf_inc_y*mj; // start position is moved by increment
                int rk = rf_inc_x*mi;

                for(int y=0; y<rf_size_y; y++){
                    int dv_y = y/block_size_y;
                    int offset_y = dv_y*span_size_y;
                    for(int x=0; x<rf_size_x; x++){
                        int dv_x = x/block_size_x;
                        int offset_x = dv_x*span_size_x;
                        input_buffer[y][x] = unit.input_up[rl+y+offset_y][rk+x+offset_x]; // * arbor[y][x]; 
                    }
                }
                
                // with current "cell" iterate over each map in the SOM
                // and calculate weight change
                for(int sj=0; sj<som_size_y; sj++){
                    for(int si=0; si<som_size_x; si++){
                        reset(inhibition_buffer);

                        // for each pixel and map, calc inhibition 
                        for(int ssj=0; ssj<som_size_y; ssj++) {
                            for(int ssi=0; ssi<som_size_x; ssi++) {
                                // for shortcutting:
                                float a = unit.activity[ssj][ssi][mj][mi]; // 18% activity at a specific cell
                                float [][] ww = unit.w[ssj][ssi];    // 14% weights for a specific som index
                                // float [][] ib = inhibition_buffer;
                                // Calculate inhibition, but only do it if
                                // indeces are less or equal to current map:
                                // ie last map is inhibited by all the others,
                                // but first one is inhibited by none - this 
                                // is the principal component sorting?
                                // ib = activity of som units + weights  

                                // note: this is anti-hebbian learning - when several
                                // pixels in different maps 
                                // are active simultanously, inhibition increases.
                                // this means that the different weight maps are decorrelated -
                                // simultaneous activation becomes less likely
                                if(ssj <= sj || (sj == ssj && ssi <= si)) { // TODO: fix ranges in loop instead; two dimensional version of i<=j
                                    // r = r + alpha * a
                                    // multiply the activity at a given pixel in a given map with the 
                                    // weight of that map and add that to inhibition
                                    // ib = add(ib, a, ww, rf_size); // 28%
                                    inhibition_buffer = addMatrix(inhibition_buffer, multiply(a, ww));
                                }
                            }
                        }
                        
                        //for(int r=0; r<rf_size; r++)
                        //    dw[sj][si][0][r] = alpha * activity[sj][si][mj][mi] * (input_buffer[0][r] - inhibition_buffer[0][r]); // 44%
                        
                        // subtract inhibition from contents of
                        // input buffer to get change in weights
                        delta_buffer = subtract(input_buffer, inhibition_buffer); // 16%
                        // calculate weight change: delta* (alpha*activity)
                        unit.dw[sj][si] = multiply(alpha * unit.activity[sj][si][mj][mi], delta_buffer); // 6%               
                        // TAT 2015-11-08: moved from outside loop - 
                        // looks like it works, but may give diff results
                        // is now cumulated for each pixel instead of just last
                        //add(*w[sj][si], *dw[sj][si], rf_size);
                    } // for si
                } // for sj
                
                // update the actual weights by adding weight change
                // note: could this have been moved into previous loop?    

                // TAT 2015-11-08: moved into inner loop
                for(int sj=0; sj<som_size_y; sj++)
                    for(int si=0; si<som_size_x; si++)
                        unit.w[sj][si] = addMatrix(unit.w[sj][si], unit.dw[sj][si]);

    
            } // end map-x
        }// end map-y
    
        input_buffer=null;
        inhibition_buffer=null;
        delta_buffer=null;

        
    }

    int calcMapSize (
        int inpsz,
        int rfsz,
        int blksz,
        int spansz,
        int inc) {
    
        return (inpsz-(rfsz+(rfsz/blksz-1)*spansz)) /(inc) + 1;
    }

    float[][] createMask(int r, int c) {
        int filterbanksize = r * c;
        float[][] retval = zeros(filterbanksize, filterbanksize);
        //String[][] str = new String[filterbanksize][filterbanksize];
        for(int j = 0; j < filterbanksize; j++) {
            int i0 = j % c;
            int j0 = j / r; // row val at this point
            for(int i = 0; i < filterbanksize; i++){
                int j1 = i / r; 
                int i1 = i % c; // col val at this point
                retval[j][i] = topologyRule(j0, i0, j1, i1);
                //str[j][i] = j0 + "" + i0 + ", " + j1 + "" + i1; 
            }
        }
        return retval;
    }   

    float topologyRule(int j0, int i0, int j1, int i1) {
        // mutual inhibition in same row, and cumulative inh between rows
        return (j0 <= j1 || (j0 == j1 && i0 <= i1)) ? 1 : 0;
    }
    
    float[] xx1(float[] vm) {
        float[] retval = zeros(vm.length);
        for (int i = 0; i < vm.length; ++i) {
            retval[i] = xx1(vm[i]);
        }
        return retval;
    }

    float xx1(float v_m){
        // """Compute the x/(x+1) activation function."""
        float X = this.act_gain * max(v_m, 0.0);
     
        return X / (X + 1);
    }

    float[] reset_array(float[] a) {Arrays.fill(a, 0); return a;}
    
}
