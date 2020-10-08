#include "ap_fixed.h"

ap_int<17> add_hls(ap_int<16> & a, ap_int<16> & b){
    #pragma HLS pipeline
    #pragma HLS latency min=1 max=1
    return a + b;
}
