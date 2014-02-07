`timescale 1ns / 1ps
module cordic_phase(
    input   wire                clk,
    input   wire    [ 19 :  0 ] arg,
    output  wire    [ 15 :  0 ] Re_out,
    output  wire    [ 15 :  0 ] Im_out
    );

localparam N = 14;
localparam DAT_WIDTH = 16;
localparam ARG_WIDTH = 20;
    
reg signed  [ DAT_WIDTH-1 :  0 ] CORDIC_GAIN = 16'd19897;
integer k;

reg   [ ARG_WIDTH-1 :  0 ] angle[0:N-1];
initial begin
    angle[ 0] = 20'd65536;
    angle[ 1] = 20'd38688;
    angle[ 2] = 20'd20441;
    angle[ 3] = 20'd10376;
    angle[ 4] = 20'd5208;
    angle[ 5] = 20'd2606;
    angle[ 6] = 20'd1303;
    angle[ 7] = 20'd651;
    angle[ 8] = 20'd325;
    angle[ 9] = 20'd162;
    angle[10] = 20'd81;
    angle[11] = 20'd40;
    angle[12] = 20'd20;
    angle[13] = 20'd10;
end

reg signed  [ DAT_WIDTH-1 :  0 ] Re[0:N-1];
reg signed  [ DAT_WIDTH-1 :  0 ] Im[0:N-1];
reg signed  [ ARG_WIDTH-1 :  0 ] r_input_arg[0:N-1];
reg signed  [ ARG_WIDTH-1 :  0 ] r_output_arg[0:N-1];
reg         [  2 :  0 ] r_quad[0:N-1];

reg signed  [ DAT_WIDTH-1 :  0 ] r_Re_out = 16'b0;
reg signed  [ DAT_WIDTH-1 :  0 ] r_Im_out = 16'b0;


always@(posedge clk)
begin
    Re[0] <= CORDIC_GAIN;
    Im[0] <= CORDIC_GAIN;
    r_input_arg[0] <= {3'b0, arg[(ARG_WIDTH-4):0]};
    r_output_arg[0] <= angle[0];
    r_quad[0] <= arg[(ARG_WIDTH-1)-:3];
    
    
    for(k = 0; k < N-1; k = k + 1)
    begin
        if(r_output_arg[k] > r_input_arg[k])
        begin
            Re[k+1] <= Re[k] + (Im[k] >>> k+1);
            Im[k+1] <= Im[k] - (Re[k] >>> k+1);
            r_output_arg[k+1] <= r_output_arg[k] - angle[k+1];
            r_input_arg[k+1] <= r_input_arg[k];
            r_quad[k+1] <= r_quad[k];
        end
        else
        begin
            Re[k+1] <= Re[k] - (Im[k] >>> k+1);
            Im[k+1] <= Im[k] + (Re[k] >>> k+1);
            r_output_arg[k+1] <= r_output_arg[k] + angle[k+1];
            r_input_arg[k+1] <= r_input_arg[k];
            r_quad[k+1] <= r_quad[k];
        end
    end
    
    r_Re_out <= r_quad[N-1] == 3'b000 ? Re[N-1]     :
                r_quad[N-1] == 3'b001 ? -Im[N-1]    :
                r_quad[N-1] == 3'b010 ? -Re[N-1]    :
                Im[N-1];
    r_Im_out <= r_quad[N-1] == 3'b000 ? Im[N-1]     :
                r_quad[N-1] == 3'b001 ? Re[N-1]     :
                r_quad[N-1] == 3'b010 ? -Im[N-1]    :
                -Re[N-1];
end

assign Re_out = r_Re_out;
assign Im_out = r_Im_out;

endmodule
