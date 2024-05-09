/*假定你的学号后两位为 ab;
编写 testbench 以完成仿真，时钟周期为 50MHz，在前 6 个时钟周期令 working 信号
为 0 ，使处理器不工作，并依次向指令存储器地址为 0-5 的存储单元中写入 6 条
IRMOV 指令， 分别修改寄存器%r0-%r5 的值，使其等于 ab ， ab+2 ，ab+4 ， ab+6 ，
ab+8 ， ab+10 再依次向指令存储器地址为 6-8 的存储单元中写入(ADD %r1， %r0)，
(SUB %r2， %r3)， (AND %r4， %r5)这 3 条指令。然后令 working 信号为 1 ，使处
理器工作，完成这几条指令的执行，最终输出每个时钟周期 ALU 得到的结果 valE 的
值*/
/*ab = 28*/

`timescale 1ns / 1ps
module processor_tb;
reg clock;
reg[8:0] addr;
reg wEn;
reg[31:0] wDat;
reg working;
wire[31:0] valE;

processor processor1(
    .clock(clock),
    .addr(addr),
    .wEn(wEn),
    .wDat(wDat),
    .working(working),
    .valE(valE)
);

// Clock generation,50 MHz
initial begin
    clock = 0;
    forever #10 clock = ~clock;  // T=20ns
end

// Testbench
initial begin
    addr = 0;
    working = 0;
    wDat = 0;
    wEn = 1;
    // (IRMOV $28, %r0) -> 10_00_00_1c
    addr = 0; wDat = 32'h10f0001c;  #20;
    // (IRMOV $30, %r1) -> 10_01_00_1e
    addr = 1; wDat = 32'h10f1001e; #20;
    // (IRMOV $32, %r2) -> 10_02_00_20
    addr = 2; wDat = 32'h10f20020; #20;
    // (IRMOV $34, %r3) -> 10_03_00_22
    addr = 3; wDat = 32'h10f30022; #20;
    // (IRMOV $36, %r4) -> 10_04_00_24
    addr = 4; wDat = 32'h10f40024; #20;
    // (IRMOV $38, %r5) -> 10_05_00_26
    addr = 5; wDat = 32'h10f50026; #20;
    // (ADD %r1, %r0) -> 20_10_00_00
    addr = 6; wDat = 32'h20100000; #20;
    // (SUB %r2, %r3) -> 21_32_00_00
    addr = 7; wDat = 32'h21320000; #20;
    // (AND %r4, %r5) -> 32_45_00_00
    addr = 8; wDat = 32'h32450000; #20;

    // stop writing
    wEn = 0;
    working = 1;


end

endmodule


