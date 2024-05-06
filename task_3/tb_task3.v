/*编写 testbench 以完成仿真，时钟周期为 50MHz，在前 6 个时钟周期令 working 信号
为 0 ，使处理器不工作，并依次向指令存储器地址为 0-5 的存储单元中写入 6 条
IRMOV 指令， 分别修改寄存器%r0-%r5 的值，使其等于 ab ， ab+1 ，ab+2 ， ab+3 ，
ab+4 ， ab+5 再依次向指令存储器地址为 6-8 的存储单元中写入(ADD %r1， %r0)，
(SUB %r3， %r2)， (AND %r4， %r5)这 3 条指令。然后令 working 信号为 1 ，使处
理器工作，完成这 几条指令的执行，先修改 6 个寄存器的数据，再执行 ALU 操作，
最终输出每个时钟周期寄存器 rA 和 rB 所对应的数据(valA 和 valB)。*/

`timescale 1ns / 1ps
module processor_tb;
reg clock;
reg[8:0] addr;
reg wEn;
reg[31:0] wDat;
reg working;
wire[31:0] valA;
wire[31:0] valB;

processor processor1(
    .clock(clock),
    .addr(addr),
    .wEn(wEn),
    .wDat(wDat),
    .working(working),
    .valA(valA),
    .valB(valB)
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
    addr = 0; wDat = 32'h1000001c;  #20;
    // (IRMOV $29, %r1) -> 10_01_00_1d
    addr = 1; wDat = 32'h1001001d; #20;
    // (IRMOV $30, %r2) -> 10_02_00_1e
    addr = 2; wDat = 32'h1002001e; #20;
    // (IRMOV $31, %r3) -> 10_03_00_1f
    addr = 3; wDat = 32'h1003001f; #20;
    // (IRMOV $32, %r4) -> 10_04_00_20
    addr = 4; wDat = 32'h10040020; #20;
    // (IRMOV $33, %r5) -> 10_05_00_21
    addr = 5; wDat = 32'h10050021; #20;
    // (ADD %r1, %r0) -> 20_01_00_00
    addr = 6; wDat = 32'h20010000; #20;
    // (SUB %r3, %r2) -> 21_03_02_00
    addr = 7; wDat = 32'h21030200; #20;
    // (AND %r4, %r5) -> 32_04_05_00
    addr = 8; wDat = 32'h32040500; #20;

    // stop writing
    wEn = 0; 
    working = 1;  // 使处理器开始工作
end

endmodule