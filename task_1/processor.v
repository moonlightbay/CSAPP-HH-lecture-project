
/*处理器 Z 说明：
1. 处理器 Z 只包括取指、译码、执行、写回、更新 PC 五个流水级操作。
2. 处理器 Z 将指令字长和数据字长均固定为 4 个字节 (32bit)。因此对于取指操作，每个时钟周期只需要从 ram 中读取 4 个字节的指令即可。
3. 指令集说明：处理器 Z 只包括 5 条指令，分别为 IRMOV， ADD， SUB， AND， XOR。
4. 寄存器说明：处理器 Z 的片上寄存器只包括 6 个 32 位寄存器，分别命名为 %r0， %r1， ...， %r5。
5. 指令编码说明：处理器 Z 的指令长度固定为 4 个字节(32bit)
    - 第一个字节(31:24)表示指令类型，高 4 位表示指令代码，低 4 位表示指令功能 ifun；
    - 第二个字节(23:16)表示操作数所在寄存器的 ID，其中高 4 位表示 rA，低 4 位表示 rB；
    - 最后两个字节(15:0)表示立即数 valC，本设计中所有立即数均以 16 进制表示。*/

/*功能描述：当 working 有效时，处理器 Z 在每个时钟周期从存储器中取出一
条 32 位的指令，并解析指令，最终输出；当 working 无效时，并且在写使能信号
wEn 有效时， 通过 addr 和 wDat 向指令存储器中写入数据。*/
module processor(
input wire clock,
input wire[8:0] addr,      //外部提供的地址
input wire wEn,
input wire[31:0] wDat,    //wDat is for writting data to ram         
input wire working,    
output reg[3:0] icode = 0,        // Instruction code
output reg[3:0] ifun = 0,         // function code
output reg[3:0] rA = 0,           
output reg[3:0] rB = 0,
output reg[15:0] valC = 0
);

wire [31:0] instr;         // Instruction
wire [8:0] ram_addr;       // RAM address
wire ram_wEn;              // RAM write enable
reg [15:0] pc = 0;         // Program counter

assign ram_wEn = wEn & ~working;  //当working有效时，不允许写入ram
assign ram_addr = ram_wEn ? addr : pc;  //当ram_wEn有效时，地址为addr，否则为pc

//实例化RAM
ram inst_ram(
    .clock(clock),            //clock信号
    .addr(ram_addr),     
    .wEn(ram_wEn),       //ram的写使能信号
    .wDat(wDat),             //写入ram的数据
    .rEn(working),           //读使能信号
    .rDat(instr)             //读取来自ram的数据
);


always@(posedge clock)begin 
    if (working && instr != 32'h0) begin   //取指令
        icode <= instr[31:28];
        ifun <= instr[27:24];
        rA <= instr[23:20];
        rB <= instr[19:16];
        valC <= instr[15:0];
        pc <= pc + 1;   //更新PC
    end
end

endmodule