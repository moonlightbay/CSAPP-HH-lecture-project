/*编写 testbench 以完成仿真，时钟周期为 50MHz
IRMOV $1, %r0
IRMOV $10, %r1
IRMOV $20, %r2
IRMOV $30, %r3
IRMOV $40, %r4
IRMOV $50, %r5
ADD %r1, %r5
SW %r0, %r0, $101
SW %r1, %r0, $102
SW %r2, %r0, $103
LW %r3, %r0, $101
LW %r4, %r2, $102
LW %r5, %r0, $103
SUB %r1, %r5
*/

`timescale 1ns / 1ps
module processor_tb;
reg clock;
reg[8:0] addr;
reg wEn;
reg[31:0] wDat;
reg working;
wire [31:0] r0,r1,r2,r3,r4,r5;



processor processor1(
    .clock(clock),
    .addr(addr),
    .wEn(wEn),
    .wDat(wDat),
    .working(working),
    .r0(r0),
    .r1(r1),
    .r2(r2),
    .r3(r3),
    .r4(r4),
    .r5(r5)
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
    // (IRMOV $1, %r0) -> 10_f0_00_01
    addr = 0; wDat = 32'h10f00001;  #20;
    // (IRMOV $10, %r1) -> 10_f1_00_0a
    addr = 1; wDat = 32'h10f1000a; #20;
    // (IRMOV $20, %r2) -> 10_f2_00_14
    addr = 2; wDat = 32'h10f20014; #20;
    // (IRMOV $30, %r3) -> 10_f3_00_1e
    addr = 3; wDat = 32'h10f3001e; #20;
    // (IRMOV $40, %r4) -> 10_f4_00_28
    addr = 4; wDat = 32'h10f40028; #20;
    // (IRMOV $50, %r5) -> 10_f5_00_32
    addr = 5; wDat = 32'h10f50032; #20;
    // (ADD %r1, %r5) -> 20_15_00_00
    addr = 6; wDat = 32'h20150000; #20;
    // (SW %r0, %r0, $101) -> 41_00_00_65
    addr = 7; wDat = 32'h41000065; #20;
    // (SW %r1, %r0, $102) -> 41_10_00_66
    addr = 8; wDat = 32'h41100066; #20;
    // (SW %r2, %r0, $103) -> 41_20_00_67
    addr = 9; wDat = 32'h41200067; #20;
    // (LW %r3, %r0, $101) -> 40_30_00_65
    addr = 10; wDat = 32'h40300065; #20;
    // (LW %r4, %r0, $102) -> 40_40_00_66
    addr = 11; wDat = 32'h40400066; #20;
    // (LW %r5, %r0, $103) -> 40_50_00_67
    addr = 12; wDat = 32'h40500067; #20;
    // (SUB %r1, %r5) -> 21_15_00_00
    addr = 13; wDat = 32'h21150000; #20;


    // stop writing
    wEn = 0;
    wDat = 32'b0;
    working = 1;
    #560;   ///取 13条指令的时间
    working = 0;
    #20;

end
/*理论结果：
1.r0 = 1, r1 = 10, r2 = 20, r3 = 30, r4 = 40, r5 = 50
2.r1 = r1 + r5 = 60
3.ram[102] = r0 = 1
4.ram[103] = r1 = 60
5.ram[104] = r2 = 20
6.r3 = ram[102] = 1
7.r4 = ram[103] = 60
8.r5 = ram[104] = 20
9.r1 = r1 - r5 = 40
*/



endmodule

