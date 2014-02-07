module cordic_gen
    #(parameter INPUT_CLK = 32'd10000000, parameter OUTPUT_SAMPLE_RATE = 20'd8000)
    (
    input       wire                clk,
    input       wire    [ 15 :  0 ] out_freq,
    input       wire    [ 15 :  0 ] discr_freq,
    output      wire    [ 15 :  0 ] sin,
    output      wire    [ 15 :  0 ] cos
    );

localparam TWO_PI = 20'd524287;

reg             [ 19 :  0 ] ARG = 20'b0;
reg             [ 31 :  0 ] temp_ARG = 32'b0;
reg             [ 19 :  0 ] REM = 20'b0;
reg             [ 31 :  0 ] temp_REM = 32'b0;

//------------//

wire    [ 31 :  0 ] w_QUO;
wire    [ 31 :  0 ] w_REM;
wire                w_ready;
reg                 r_start = 1'b0;
reg     [ 15 :  0 ] r_freq = 16'b0;
divider #32 u1
    (
    .clk(clk),
    .start(r_start),
    .divident({16'b0, out_freq}),
    .divider({16'b0, discr_freq}),
    .quotient(w_QUO),
    .reminder(w_REM),
    .ready(w_ready)
);

always@(posedge clk)
begin
    r_freq <= out_freq;
    r_start <= 1'b0;
    if(r_freq != out_freq)
        r_start <= 1'b1;
    if(w_ready)
    begin
        temp_ARG <= w_QUO;
        temp_REM <= w_REM;
    end
end

//-------------//
reg     signed  [ 31 :  0 ] r_sr = 32'b0;
wire    signed  [ 31 :  0 ] inc_sr = r_sr[31] ? OUTPUT_SAMPLE_RATE : 
                                                OUTPUT_SAMPLE_RATE-INPUT_CLK;
wire    signed  [ 31 :  0 ] tic_sr = r_sr + inc_sr;
wire                        w_en = ~r_sr[31];
reg                         r_en = 1'b0;
always@(posedge clk)
begin
    r_sr <= tic_sr;
    r_en <= w_en;
end
//-------------//


reg             [ 19 :  0 ] my_arg = 20'b0;
wire            [ 19 :  0 ] next_arg = my_arg + ARG;//ARG[19:0];

reg             [ 19 :  0 ] my_rem = 20'b0;
wire            [ 19 :  0 ] next_rem = my_rem + REM;

always@(posedge clk)
if(r_en)
begin
    ARG <= temp_ARG[19:0];
    REM <= temp_REM[19:0];
    my_arg <= next_arg[19] ? next_arg - TWO_PI : next_arg;
    
    my_rem <= next_rem;
    
    if(next_rem >= OUTPUT_SAMPLE_RATE)
    begin
        my_arg <= next_arg[19] ? 1'b1 + next_arg - TWO_PI : 1'b1 + next_arg;
        my_rem <= next_rem - OUTPUT_SAMPLE_RATE;
    end
    
    
end

wire    signed  [ 15 :  0 ] w_re_out;
wire    signed  [ 15 :  0 ] w_im_out;
cordic_phase u0
(
    .clk(clk),
    .arg(my_arg),
    .Re_out(w_re_out),
    .Im_out(w_im_out)
);

assign sin = w_im_out;
assign cos = w_re_out;

endmodule
