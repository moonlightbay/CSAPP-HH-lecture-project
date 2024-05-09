/*编写 testbench 以完成仿真，时钟周期为 50MHz，在前 10 个时钟周期令 working 信
号为 0 ，使处理器不工作，并依次向指令存储器地址为 0-5 的存储单元中写入 6 条
IRMOV 指令，分别修改寄存器%r0-%r5 的值，使其等于 ab， ab+1 ，ab+2 ， ab+3 ，
ab+4 ， ab+5 ，再依次向指令存储器地址为 7 - 10 的存储单元中写入
(ADD %r0， %r1)， (SUB %r2， %r3)， (AND %r4， %r5)， (ADD %r1， %r0)这 4
条指令。然后令 working 信号为 1 ，使处理器工作，完成这 10 条指令的执行。当处理
器完成所有指令的执行之后，令 working 信号为 0 ， 最后 6 个时钟周期通过 rID 依次
读出 6 个寄存器的值*/
/*ab = 28*/

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
    // (IRMOV $28, %r0) -> 10_00_00_1c
    addr = 0; wDat = 32'h10f0001c;  #20;
    // (IRMOV $29, %r1) -> 10_01_00_1d
    addr = 1; wDat = 32'h10f1001d; #20;
    // (IRMOV $30, %r2) -> 10_02_00_1e
    addr = 2; wDat = 32'h10f2001e; #20;
    // (IRMOV $31, %r3) -> 10_03_00_1f
    addr = 3; wDat = 32'h10f3001f; #20;
    // (IRMOV $32, %r4) -> 10_04_00_20
    addr = 4; wDat = 32'h10f40020; #20;
    // (IRMOV $33, %r5) -> 10_05_00_21
    addr = 5; wDat = 32'h10f50021; #20;
    // (ADD %r0, %r1) -> 20_01_00_00
    addr = 6; wDat = 32'h20010000; #20;
    // (SUB %r2, %r3) -> 21_23_00_00
    addr = 7; wDat = 32'h21230000; #20;
    // (AND %r4, %r5) -> 32_45_00_00
    addr = 8; wDat = 32'h32450000; #20;
    // (ADD %r1, %r0) -> 20_10_00_00
    addr = 9; wDat = 32'h20100000; #20;

    // stop writing
    wEn = 0;
    working = 1;
    #260;   ///取 10 条指令的时间
    working = 0;
    #20;
    rID = 0;#20;
    rID = 1;#20;
    rID = 2;#20;
    rID = 3;#20;
    rID = 4;#20;
    rID = 5;#20;
end

endmodule

/*理论结果:
开始：r0 = 28, r1 = 29, r2 = 30, r3 = 31, r4 = 32, r5 = 33
运算后:r0 = r0+r1=28+29=57=0x39
      r1 = r1+r0=29+57=86=0x56
      r2 = r2-r3=30-31=-1=0xffffffff
      r3 = 31 = 0x1f
      r4 = r4&r5= 0x20&0x21 = 0x20
      r5 = 33 = 0x21
*/