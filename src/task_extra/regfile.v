/*功能描述：采用同步复位，当 reset 有效，将寄存器 r0-r5 的数据清零；每个
时钟周期，将数据 valE 写入寄存器 ID 为 dstE 的寄存器；每个时钟周期，将数据
valM 写入寄存器 ID 为 dstM 的寄存器;每个时钟周期，将寄存器 ID 为 srcA 的寄存
器数据输出到 valA；每个时钟周期，将寄存器 ID 为 srcB 的寄存器数据输出到
valB；*/
/*每个时钟周期输出寄存器 r0-r5 的数据。*/

module regfile(
    // input wire[3:0] dstE,
    // input wire[31:0] valE,
    input wire[3:0] dstM,
    input wire[31:0] valM,
    input wire[3:0] rA,    //src A
    input wire[3:0] rB,    //src B
    input wire[3:0] rID,  
    input wire reset,
    input wire clock,
    output reg [31:0] valA,
    output reg [31:0] valB,
    output reg [31:0] r0,
    output reg [31:0] r1,
    output reg [31:0] r2,
    output reg [31:0] r3,
    output reg [31:0] r4,
    output reg [31:0] r5,
    output reg [31:0] rdata
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
        // case(dstE)
        //     4'b0000: r0 <= valE;
        //     4'b0001: r1 <= valE;
        //     4'b0010: r2 <= valE;
        //     4'b0011: r3 <= valE;
        //     4'b0100: r4 <= valE;
        //     4'b0101: r5 <= valE;
        //     default: ;// do nothing
        // endcase;

        case(dstM)
            4'b0000: r0 <= valM;
            4'b0001: r1 <= valM;
            4'b0010: r2 <= valM;
            4'b0011: r3 <= valM;
            4'b0100: r4 <= valM;
            4'b0101: r5 <= valM;
            default: ;// do nothing
        endcase;    

        case(rA)
            4'b0000: valA <= r0;
            4'b0001: valA <= r1;
            4'b0010: valA <= r2;
            4'b0011: valA <= r3;
            4'b0100: valA <= r4;
            4'b0101: valA <= r5;
            default: ;// do nothing
        endcase;

        case(rB)
            4'b0000: valB <= r0;
            4'b0001: valB <= r1;
            4'b0010: valB <= r2;
            4'b0011: valB <= r3;
            4'b0100: valB <= r4;
            4'b0101: valB <= r5;
            default: ;// do nothing
        endcase; 

        case(rID)
            4'b0000: rdata <= r0;
            4'b0001: rdata <= r1;
            4'b0010: rdata <= r2;
            4'b0011: rdata <= r3;
            4'b0100: rdata <= r4;
            4'b0101: rdata <= r5;
            default: ;// do nothing
        endcase;
    end
end

endmodule