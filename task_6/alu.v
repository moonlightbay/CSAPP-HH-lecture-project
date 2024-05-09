/*功能描述：根据功能代码 alufun 的值，对操作数 aluA 和 aluB 做相应运算，
并将结果通过 valE 输出。alufun 为 0 ，做加法，为 1 做减法(A-B)，为 2 做逻辑
与运算，为 3 做逻辑异或运算。*/

module alu(
input [31:0] aluA,
input [31:0] aluB,  //在LW与SW中也作为基地址
input [3:0] alufun,
output [31:0] valE
);

assign valE = (alufun == 4'b0000) ? aluA + aluB :  //ADD,LW,SW
              (alufun == 4'b0001) ? aluA - aluB :  //SUB
              (alufun == 4'b0010) ? aluA & aluB :  //AND
              (alufun == 4'b0011) ? aluA ^ aluB :  //XOR
              32'bz;

endmodule