`default_nettype none

module tt_um_vga_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire hsync, vsync, display_on;
    wire [9:0] hpos, vpos;

    hvsync_generator hvsync_gen (
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );

    reg [9:0] frame;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            frame <= 0;
        else if (hpos == 0 && vpos == 0)
            frame <= frame + 1;
    end

    wire [1:0] mode = frame[9:8];
    wire [9:0] t = frame;

    wire signed [10:0] cx = $signed({1'b0,hpos}) - 11'sd320;
    wire signed [10:0] cy = $signed({1'b0,vpos}) - 11'sd240;

    wire [9:0] ax = cx[10] ? (~cx[9:0] + 1) : cx[9:0];
    wire [9:0] ay = cy[10] ? (~cy[9:0] + 1) : cy[9:0];

    wire [6:0] ax_s = ax[9:2];
    wire [6:0] ay_s = ay[9:2];

    wire [6:0] rmax = (ax_s > ay_s) ? ax_s : ay_s;
    wire [6:0] rmin = (ax_s > ay_s) ? ay_s : ax_s;

    wire [7:0] r = {1'b0,rmax} + {2'b00,rmin[6:1]};

  
    wire [7:0] radial =
        (r << 2) + (t << 1);

    wire [7:0] ripple =
        (r + (t >> 2));   // LOW frequency modulation

    wire [7:0] vortex_final =
        radial ^ (ripple >> 2);  // controlled XOR (not chaotic)

    
    wire [7:0] plasma =
    (cx[9:2] + t[7:0]) +
    (cy[9:2] + t[8:1]);

    
    wire [7:0] wave =
    (cx[9:3] ^ cy[9:3]) +
    (cx[9:4] + cy[9:4]);


    wire [7:0] chaos =
    (cx[9:2] ^ (cy[9:2] + t[7:0])) +
    ((cx[9:2] & cy[9:2]) >> 1);

    reg [7:0] pattern;

    always @(*) begin
        case(mode)
            2'b00: pattern = vortex_final;
            2'b01: pattern = plasma;
            2'b10: pattern = wave;
            default: pattern = chaos;
        endcase
    end

    wire [7:0] color = pattern + t;

    wire [1:0] r_out = color[7:6];
    wire [1:0] g_out = color[5:4];
    wire [1:0] b_out = color[3:2];

    assign uo_out[0] = r_out[1] & display_on;
    assign uo_out[4] = r_out[0] & display_on;

    assign uo_out[1] = g_out[1] & display_on;
    assign uo_out[5] = g_out[0] & display_on;

    assign uo_out[2] = b_out[1] & display_on;
    assign uo_out[6] = b_out[0] & display_on;

    assign uo_out[3] = vsync;
    assign uo_out[7] = hsync;

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, uio_in, ui_in, 1'b0};

endmodule
