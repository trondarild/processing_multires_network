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
    


    MultiResLayer(MultiResLayerSpec spec, String name) {
        this.spec = spec;
        this.name = name;
    }

    void setInputUp(float[][] inp){
        // upward, learning, transforming
        input_up = inp;
    }

    void setInputDown(float[][] inp){
        // downward, generative
        input_down = inp;

    }

    float[][] getOutputUp(){
        return output_up;
    }

    float[][] getOutputDown() {
        return output_down;
    }

    float[][] getWeightViz() {
        float[][] retval = zeros(spec.rf_size_y*spec.som_size_y, spec.rf_size_x*spec.som_size_x);
        return retval;
    }

    void cycle() {
        this.spec.cycle(this);

    }

    void calcFwdActivation(){
        this.spec.calcFwdActivation(this);
    }

    void calcBkwActivation(){
        this.spec.calcBkwActivation(this);
    }
    void generateOutput(){}
    void generateWeightOutput(){}

    void updateWeights() {}



    

    
}

class MultiResLayerSpec {
    int         rf_size_x = 3; 
    int         rf_size_y = 3;
    int         rf_inc_x = 1;
    int         rf_inc_y = 1;

    int         border_mult;
    int         map_size_x_scr;
    int         map_size_y_scr;

    int         som_size_x; // number of neural units per rf size area
    int         som_size_y;
    
    int         map_size_x;
    int         map_size_y;

    int         buffer_size_x;
    int         buffer_size_y;

    int         learning_buffer_size;

    int         block_size_x;       // size of sub-block of rf - used for layers > 1
    int         block_size_y;

    int         span_size_x;       // spacing between sub-blocks of rf 
    int         span_size_y;
    
    
    int         output_type;       // 0 = combined, 1 = separate 
    
    float		alpha = 0.05;              // RF learning constant
    float		alpha_min = 0.01;
    float		alpha_max = 0.1;
    float		alpha_decay = 0.001;
	
	boolean		use_arbor;
    boolean     use_top_down = true;


    MultiResLayerSpec() {

    }

    void cycle(MultiResLayer unit) {
        calcFwdActivation(unit);
        if(update_weights) updateWeights(unit);
        calcBkwActivation(unit);
        generateOutput(unit);
        generateWeightOutput(unit);
    }

    void calcFwdActivation(MultiResLayer unit){
        int input_size_x = unit.input_up[0].length;
        int input_size_y = unit.input_up.length;
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
        for (int sj = 0; sj < som_size_y; sj++) 
            for (int si = 0; si < som_size_x; si++)
            {
                // im2row(buffer, input, map_size_x, map_size_y, input_size_x, input_size_y, rf_size_x, rf_size_y, rf_inc_x, rf_inc_y);
                //reset_matrix(activity_scratch, map_size_x_scr, map_size_y_scr);
                unit.activity[sj][si] = dotProd(buffer, w[sj][si]);
                
            }
    
    }

    void calcBkwActivation(MultiResLayer unit) {
        if(!use_top_down) return;
        // normalize_max(reconstruction, input_size_x, input_size_y); // TODO: Check that this is ok
        unit.reconstruction = regenerate(
            unit.input_down, 
            map_size_x, map_size_y);
        }
    }

    float[][] regenerate(float[][] in, int map_x, int map_y) {
        float[][] topdown_buffer = spanned_im2row(in,
            map_x, map_y,
            this.som_size_x, this.som_size_y,
            this.som_size_x, this.som_size_y,
            this.som_size_x, this.som_size_y,
            0,0);
        //float[][] tmp = multiply_per_elem()
        //float[][] retval = spanned_row2im(tmp,
        //    map_x, map_y,
        //    rf_size_x, rf_size_y,
        //    rf_inc_x, rf_inc_y,
        //    block_size_x, block_size_y,
        //    span_size_x, span_size_y);
        //)

        //retval = normalize_max(retval);
        return normalize(topdown_buffer);
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
                            unit.output[y][x] = unit.activity[j][i][l][k];
                            // printf("j=%i, i=%i, l=%i, k=%i; x=%i, y=%i\n", j, i, l, k, x, y);
                        }

        }
        else if(output_type == 1) // separate
        
                for(int j=0; j<som_size_y; j++)
                    for(int i=0; i<som_size_x; i++)
                        for(int l=0; l<map_size_y; l++)
                            for(int k=0; k<map_size_x; k++)
                                unit.output[j*map_size_y+l][i*map_size_x+k] = unit.activity[j][i][l][k];
                                // 012 012 012
    }

    void updateWeights_mmlt_blnc(MultiResLayer unit) {

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
        /*
            //print_array("dw", dw[k], kernelsize, 6);
        */
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
}
