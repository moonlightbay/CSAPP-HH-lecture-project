/*功能描述：根据功能代�? alufun 的�?�，对操作数 aluA �? aluB 做相应运算，
并将结果通过 valE 输出。alufun �? 0 ，做加法，为 1 做减�?(A-B)，为 2 做�?�辑
与运算，�? 3 做�?�辑异或运算�?*/

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