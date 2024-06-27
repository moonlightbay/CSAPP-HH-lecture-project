/*功能描述：根据功能代码 alufun 的值，对操作数 aluA 和 aluB 做相应运算，
并将结果通过 valE 输出。alufun 为 0 ，做加法，为 1 做减法(A-B)，为 2 做逻辑
与运算，为 3 做逻辑异或运算。*/

module alu(
input [31:0] aluA,
input [31:0] aluB,
input [3:0] alufun,
output reg[31:0] valE
);

always@(*)begin
    case(alufun)
        4'b0000: valE = aluA + aluB;  //加法
        4'b0001: valE = aluA - aluB;  //减法
        4'b0010: valE = aluA & aluB;  //与运�?
        4'b0011: valE = aluA ^ aluB;  //异或运算
        default: valE = 32'h0;
    endcase
end

endmodule