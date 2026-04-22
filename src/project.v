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

    // VGA timing
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

    // Frame counter
    reg [9:0] frame;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            frame <= 10'd0;
        else if (hpos == 10'd0 && vpos == 10'd0)
            frame <= frame + 10'd1;
    end

    wire [1:0] mode = frame[9:8];
    wire [9:0] t = frame;

    // --------------------------------------------------
    // SAFE CENTERING (NO $signed)
    // --------------------------------------------------
    wire [10:0] cx = {1'b0, hpos} - 11'd320;
    wire [10:0] cy = {1'b0, vpos} - 11'd240;

    // Absolute values (synthesis-safe)
  wire [10:0] cx_neg = 11'd0 - cx;
wire [10:0] cy_neg = 11'd0 - cy;

wire [9:0] ax = cx[10] ? cx_neg[9:0] : cx[9:0];
wire [9:0] ay = cy[10] ? cy_neg[9:0] : cy[9:0];

    // Downscale for area efficiency
    wire [6:0] ax_s = ax[9:2];
    wire [6:0] ay_s = ay[9:2];

    // Approximate radial distance
    wire [6:0] rmax = (ax_s > ay_s) ? ax_s : ay_s;
    wire [6:0] rmin = (ax_s > ay_s) ? ay_s : ax_s;

    wire [7:0] r = {1'b0, rmax} + {2'b00, rmin[6:1]};

    // --------------------------------------------------
    // MODE 0: RADIAL VORTEX
    // --------------------------------------------------
    wire [7:0] radial = (r << 2) + (t << 1);
    wire [7:0] ripple = r + (t >> 2);
    wire [7:0] vortex_final = radial ^ (ripple >> 2);

    // --------------------------------------------------
    // MODE 1: PLASMA (WIDTH SAFE)
    // --------------------------------------------------
    wire [7:0] plasma =
        (cx[9:2] + t[7:0]) +
        (cy[9:2] + t[8:1]);

    // --------------------------------------------------
    // MODE 2: INTERFERENCE
    // --------------------------------------------------
    wire [7:0] wave =
        (cx[9:3] ^ cy[9:3]) +
        (cx[9:4] + cy[9:4]);

    // --------------------------------------------------
    // MODE 3: CHAOS (SANITIZED)
    // --------------------------------------------------
    wire [7:0] chaos =
        (cx[9:2] ^ (cy[9:2] + t[7:0])) +
        ((cx[9:2] & cy[9:2]) >> 1);

    // --------------------------------------------------
    // MODE SELECT
    // --------------------------------------------------
    reg [7:0] pattern;

    always @(*) begin
        case (mode)
            2'b00: pattern = vortex_final;
            2'b01: pattern = plasma;
            2'b10: pattern = wave;
            default: pattern = chaos;
        endcase
    end

    // Final color
    wire [7:0] color = pattern + t[7:0];

    // RGB extraction
    wire [1:0] r_out = color[7:6];
    wire [1:0] g_out = color[5:4];
    wire [1:0] b_out = color[3:2];

    // VGA output mapping
    assign uo_out[0] = r_out[1] & display_on;
    assign uo_out[4] = r_out[0] & display_on;

    assign uo_out[1] = g_out[1] & display_on;
    assign uo_out[5] = g_out[0] & display_on;

    assign uo_out[2] = b_out[1] & display_on;
    assign uo_out[6] = b_out[0] & display_on;

    assign uo_out[3] = vsync;
    assign uo_out[7] = hsync;

    // Unused IO
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, uio_in, ui_in, 1'b0};

endmodule
