/*假定你的学号后两位为 ab;
编写 testbench 以完成仿真，时钟周期为 50MHz，在前 4 个时钟周期令 working 信号
为 0 ，使处理器不工作，并依次向指令存储器地址为 0-3 的存储单元中写入 4 条
IRMOV 指令，分别修改寄存器 %r0 - %r3 的值，使其等于 ab, ab+1, ab+2 ,ab+3。然
后令 working 信号为 1 ，使处理器工作，完成这 4 条指令的执行，以修改每个寄存器
的数据，最终输出每个时钟周期这 4 个寄存器的数据。*/
/*ab = 28*/

`timescale 1ns / 1ps 
module processor_tb;
    reg clock,wEn,working;
    reg [8:0] addr;
    reg [31:0] wDat;
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
        // Write first instruction (IRMOV $28, %r0) -> 10_f0_00_1c
        addr = 0; wDat = 32'h10f0001c;  #20;
        // Write second instruction (IRMOV $29, %r1) -> 10_f1_00_1d
        addr = 1; wDat = 32'h10f1001d; #20;
        // Write third instruction (IRMOV $30, %r2) -> 10_f2_00_1e
        addr = 2; wDat = 32'h10f2001e; #20;
        // Write fourth instruction (IRMOV $31, %r3) -> 10_f3_00_1f
        addr = 3; wDat = 32'h10f3001f; #20;

        // stop writing
        wEn = 0; 
        working = 1;  // 使处理器开始工作
        #200;
        working = 0;  // 使处理器停止工作
    end

    initial begin
        $monitor("r0=%d, r1=%d, r2=%d, r3=%d, r4=%d, r5=%d", r0, r1, r2, r3, r4, r5);
    end
endmodule



     
