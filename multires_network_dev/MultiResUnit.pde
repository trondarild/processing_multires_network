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

    float[][] w; // weights
    


    MultiResUnit(MultiResUnitSpec spec, String name) {
        this.spec = spec;
        this.name = name;
    }

    void setInputUp(float[][] inp){
        // upward, learning, transforming
    }

    void setInputDown(float[][] inp){
        // downward, generative
    }

    float[][] getOutputUp(){
        return zeros(1,1);
    }

    float[][] getOutputDown() {
        return zeros(1,1);
    }

    float[][] getWeightViz() {
        float[][] retval = zeros(spec.rf_size_y*spec.som_size_y, spec.rf_size_x*spec.som_size_x);
        return retval;
    }

    void cycle() {
        this.spec.cycle(this);
    }
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

    int         block_size_x;       // size of sub-block of rf
    int         block_size_y;

    int         span_size_x;       // spacing between sub-blocks of rf 
    int         span_size_y;
    
    int         output_size_x;      // size of the merged output map
    int         output_size_y;

    int         input_size_x;       // size of the input matrix
    int         input_size_y;

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

    int calcMapSize (
        int inpsz,
        int rfsz,
        int blksz,
        int spansz,
        int inc) {
    
        return (inpsz-(rfsz+(rfsz/blksz-1)*spansz)) /(inc) + 1;
    }
}
