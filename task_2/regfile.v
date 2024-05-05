/*功能描述：采用同步复位，当 reset 有效，将寄存器 r0-r5 的数据清零；每个
时钟周期，将数据 valE 写入寄存器 ID 为 dstE 的寄存器；每个时钟周期，将数据
valM 写入寄存器 ID 为 dstM 的寄存器；每个时钟周期输出寄存器 r0-r5 的数据。*/

module regfile(
    input wire[3:0] dstE,
    input wire[31:0] valE,
    input wire[3:0] dstM,
    input wire[31:0] valM,
    input wire reset,
    input wire clock,
    output reg [31:0] r0,
    output reg [31:0] r1,
    output reg [31:0] r2,
    output reg [31:0] r3,
    output reg [31:0] r4,
    output reg [31:0] r5
);

always @(posedge clock) begin
    if (reset) begin
        r0 <= 0;
        r1 <= 0;
        r2 <= 0;
        r3 <= 0;
        r4 <= 0;
        r5 <= 0;
    end
    else begin
        case(dstE)
            4'b0000: r0 <= valE;
            4'b0001: r1 <= valE;
            4'b0010: r2 <= valE;
            4'b0011: r3 <= valE;
            4'b0100: r4 <= valE;
            4'b0101: r5 <= valE;
            default: // do nothing
        endcase;

        case(dstM)
            4'b0000: r0 <= valM;
            4'b0001: r1 <= valM;
            4'b0010: r2 <= valM;
            4'b0011: r3 <= valM;
            4'b0100: r4 <= valM;
            4'b0101: r5 <= valM;
            default: // do nothing
        endcase;      
    end
end

endmodule