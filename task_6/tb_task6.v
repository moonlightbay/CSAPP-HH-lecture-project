/*编写 testbench 以完成仿真，时钟周期为 50MHz，在前 12 个时钟周期令 working 信
号为 0 ，使处理器不工作，并依次向指令存储器地址为 0-11 的存储单元中写入以下指
令:
IRMOV $1, %r0
IRMOV $10, %r1
IRMOV $20, %r2
IRMOV $30, %r3
IRMOV $40, %r4
IRMOV $50, %r5
SW %r0, %r0, $101
SW %r1, %r0, $102
SW %r2, %r0, $103
LW %r3, %r0, $101
LW %r4, %r2, $102
LW %r5, %r0, $103
然后令 working 信号为 1 ，使处理器工作，完成指令的执行。当处理器完成所有
指令的执行之后，令 working 信号为 0 。报告中圈出最终三条 load 指令的结果。*/

`timescale 1ns / 1ps
module processor_tb;
reg clock;
reg[8:0] addr;
reg wEn;
reg[31:0] wDat;
reg working;
reg[3:0] rID;
wire[31:0] rdata;

processor processor1(
    .clock(clock),
    .addr(addr),
    .wEn(wEn),
    .wDat(wDat),
    .working(working),
    .rID(rID),
    .rdata(rdata)
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
    // (IRMOV $1, %r0) -> 10_00_00_01
    addr = 0; wDat = 32'h10f00001;  #20;
    // (IRMOV $10, %r1) -> 10_01_00_0a
    addr = 1; wDat = 32'h10f1000a; #20;
    // (IRMOV $20, %r2) -> 10_02_00_14
    addr = 2; wDat = 32'h10f20014; #20;
    // (IRMOV $30, %r3) -> 10_03_00_1e
    addr = 3; wDat = 32'h10f3001e; #20;
    // (IRMOV $40, %r4) -> 10_04_00_28
    addr = 4; wDat = 32'h10f40028; #20;
    // (IRMOV $50, %r5) -> 10_05_00_32
    addr = 5; wDat = 32'h10f50032; #20;
    // (SW %r0, %r0, $101) -> 41_00_00_65
    addr = 6; wDat = 32'h41000065; #20;
    // (SW %r1, %r0, $102) -> 41_10_00_66
    addr = 7; wDat = 32'h41100066; #20;
    // (SW %r2, %r0, $103) -> 41_20_00_67
    addr = 8; wDat = 32'h41200067; #20;
    // (LW %r3, %r0, $101) -> 40_30_00_65
    addr = 9; wDat = 32'h40300065; #20;
    // (LW %r4, %r2, $102) -> 40_42_00_66
    addr = 10; wDat = 32'h40420066; #20;
    // (LW %r5, %r0, $103) -> 40_50_00_67
    addr = 11; wDat = 32'h40500067; #20;

    // stop writing
    wEn = 0;
    wDat = 32'b0;
    working = 1;
    #500;   ///取 10 条指令的时间
    working = 0;
    #20;
    rID = 3;#20;
    rID = 4;#20;
    rID = 5;#20;
end
/*理论结果：
1.r0 = 1, r1 = 10, r2 = 20, r3 = 30, r4 = 40, r5 = 50
2.ram[102] = 1;r0 = 1;
3.ram[103] = 10;r1 = 10;
4.ram[104] = 20;r2 = 20;
5.r3 = ram[102] = 1;
6.r4 = ram[122] = 0;
7.r5 = ram[104] = 20;
*/



endmodule

