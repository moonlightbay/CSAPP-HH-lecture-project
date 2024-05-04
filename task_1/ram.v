//存储器文�? ram.v//
/*功能描述：对于写入数据，当写使能信号 wr 有效时，将数�? wdata 写入地址
�? addr 的存储单元中；对于读出数据，读使能信�? rd 有效时，将地�?�? addr �?
存储单元中的数据输出到数据�?�线 rdata 上�??*/
module ram(
input wire clock, // Clock
input wire[8:0] addr, // Read/write address
input wire wEn, // Write enable
input wire[31:0] wDat, // Write data
input wire rEn, // Read enable
output reg[31:0] rDat = 0 // Read data = line:arch:synchram:rDatB
);

reg[31:0] mem[512-1:0]; // Actual storage

always@(posedge clock)begin
    if(wEn)begin
        mem[addr] <= wDat;  //write data to memory
    end
    else if(rEn)begin
        rDat <= mem[addr];  //read data from memory
    end
end

endmodule