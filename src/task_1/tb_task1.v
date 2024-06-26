/*仿真要求：
编写 testbench 以完成仿真，时钟周期为 50MHz。
在前 3 个时钟周期令 working 信号为 0 ，使处理器不工作并依次向指令存储器地址为 0-2 的存储单元中写入(IRMOV $8， %r5)， (SUB %r4， %r5) ，(ADD %r1， %r2)这 3 条指令。
然后令 working 信号为 1 ，使处理器工作，完成这 3 条指令的取指操作，最终输出每个时钟周期取指的结果。*/

`timescale 1ns / 1ps  // 1 ns time unit, 1 ps time precision

module processor_tb;
    reg clock;
    reg [8:0] addr;
    reg wEn;
    reg [31:0] wDat;
    reg working;
    wire [3:0] icode, ifun, rA, rB;
    wire [15:0] valC;

    processor processor1(
        .clock(clock),
        .addr(addr),
        .wEn(wEn),
        .wDat(wDat),
        .working(working),
        .icode(icode),
        .ifun(ifun),
        .rA(rA),
        .rB(rB),
        .valC(valC)
    );

    // Clock generation,50 MHz
    initial begin
        clock = 0;
        forever #10 clock = ~clock;  // T=20ns
    end

    // Testbench
    initial begin
        //signal initialization
        addr = 0;
        wEn = 0;
        wDat = 0;
        working = 0;


        #40; // Wait for a few cycles
        wEn = 1;
        // Write first instruction (IRMOV $8, %r5) -> 10_f5_00_08
        addr = 0; wDat = 32'h10f50008;  #20;
        // Write second instruction (SUB %r4, %r5) -> 21_45_00_00
        addr = 1; wDat = 32'h21450000; #20;
        // Write third instruction (ADD %r1, %r2) -> 20_12_00_00
        addr = 2; wDat = 32'h20120000; #20;

        // stop writing
        wEn = 0; #20;
        working = 1;  // 使处理器开始工作
        addr = 0;  // 重置地址用于取指
        #100;
        working = 0;  // 使处理器停止工作
    end

// 监视输出
    initial begin
        $monitor("Time: %t | icode: %h, ifun: %h, rA: %h, rB: %h, valC: %h", $time, icode, ifun, rA, rB, valC);
    end

endmodule