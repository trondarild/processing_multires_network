/** Neural unit for multires network

*/
class MultiResUnit {
    String name;
    MultiResUnitSpec spec;
    boolean update_weights = true;

    float[][] input_up;
    float[][] output_up;
    float[][] input_down;
    float[][] output_down;
    float[][] activity;

    float[][][][] w; // weights
    


    MultiResUnit(MultiResUnitSpec spec, String name) {
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
        //this.spec.cycle(this);
        calcFwdActivation();
        if(update_weights) updateWeights();
        calcBkwActivation();
        generateOutput();
        generateWeightOutput();
    }

    void calcFwdActivation(){}
    void calcBkwActivation(){}
    void generateOutput(){}
    void generateWeightOutput(){}

    void updateWeights() {}



    

    
}

class MultiResUnitSpec {
    int         rf_size_x = 3; 
    int         rf_size_y = 3;
    int         rf_inc_x = 1;
    int         rf_inc_y = 1;

    int         border_mult;
    int         map_size_x_scr;
    int         map_size_y_scr;

    int         som_size_x;
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
    
    
    int         output_type;    
    
    float		alpha = 0.05;              // RF learning constant
    float		alpha_min = 0.01;
    float		alpha_max = 0.1;
    float		alpha_decay = 0.001;
	
	boolean		use_arbor;


    MultiResUnitSpec() {

    }

    void cycle(MultiResUnit unit) {
        // TODO
    }

    void calcFwdActivation(MultiResUnit unit){
        int input_size_x = unit.input_up[0].length;
        int input_size_y = unit.input_up.length;
        int inp_scr_x = input_size_x + 2*border_mult * span_size_x;
        int inp_scr_y = input_size_y + 2*border_mult * span_size_y;
        int offset_x = (map_size_x_scr - map_size_x) / 2;
        int offset_y = (map_size_y_scr - map_size_y) / 2;
    
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
        return zeros(1,1);
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
