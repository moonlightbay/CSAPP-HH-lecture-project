
/*流水化：使用四级流水线，例化各个模块，第一级在每个时钟周期取指并解
析，第二级在每个时钟周期译码得到操作数 rA 和 rB，第三级在每个时钟周期执行
算数逻辑运算得到 ALU 的运算结果 valE，第四级在每个时钟周期将 ALU 的运算
结果 valE 写回寄存器文件；将立即数 valC 写回寄存器文件。*/


module processor(
    input wire clock,
    input wire[8:0] addr,      //外部提供的地址
    input wire wEn,
    input wire[31:0] wDat,    //wDat is for writting data to ram         
    input wire working,    
    input wire[3:0] rID,
    output [31:0] rdata
);
    /*PC*/
    reg [15:0] pc = 0;         // Program counter

    /*指令*/
    wire [31:0] instr;         // Instruction
    // icode <= instr[31:28];
    // ifun <= instr[27:24];
    // rA <= instr[23:20];   //操作数A
    // rB <= instr[19:16];   //操作数B
    // valC <= instr[15:0];
    
    /*RAM*/
    wire [8:0] ram_addr;       // RAM address
    wire ram_wEn;              // RAM write enable
    assign ram_wEn = wEn & ~working;  //当working有效时，不允许写入ram
    assign ram_addr = ram_wEn ? addr : pc;  //当ram_wEn有效时，地址为addr，否则为pc
    
    /*寄存器文件*/
    reg[3:0] dstE, dstM;      //目的寄存器 dstE = ra(ADD,SUB...), dstM = rb(IRMOV)
    reg[31:0] valM;     //写入寄存器的数据
    reg[3:0] srcA, srcB;      //源寄存器
    wire[31:0] valA, valB;      //寄存器文件输出的数据
    reg[3:0] dstE_delayed;    //用于将dstE延后两个周期，以匹配时序
    

    /*ALU*/
    reg[3:0] alufun;          //ALU功能码
    reg[3:0] alufun_delayed;  //用于将ALU功能码延后一个周期，以匹配时序
    wire[31:0] valE;           //ALU的运算结果

    //实例化RAM
    ram inst_ram(
        .clock(clock),            //clock信号
        .addr(ram_addr),     
        .wEn(ram_wEn),       //ram的写使能信号
        .wDat(wDat),             //写入ram的数据
        .rEn(working),           //读使能信号
        .rDat(instr)             //读取来自ram的数据
    );

    //实例化寄存器文件
    regfile regfile1(
        .dstE(dstE),
        .valE(valE),
        .dstM(dstM),
        .valM(valM),
        .rA(srcA),
        .rB(srcB),
        .rID(rID),
        .reset(1'b0),
        .clock(clock),
        .valA(valA),
        .valB(valB),
        .r0(),
        .r1(),
        .r2(),
        .r3(),
        .r4(),
        .r5(),
        .rdata(rdata)
    );

    //实例化ALU
    alu alu1(
        .aluA(valA),
        .aluB(valB),
        .alufun(alufun),
        .valE(valE)
    );


    //处理器
    always @(posedge clock) begin
        if (working && instr != 32'h0) begin   //取指+解析
            if (instr[31:28] == 4'b0001 && instr[27:24] == 4'b0000) begin   //IRMOV, rB -> valC
                dstM <= instr[19:16];      //rB
                valM <= instr[15:0];       //valC
            end
            else if (instr[31:28] == 4'b0010 && instr[27:24] == 4'b0000) begin   //ADD,%rA ->valA, %rB -> valB
                srcA <= instr[23:20];      //rA
                srcB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0000;  //ADD
                dstE_delayed <= instr[23:20];  //rA,用于写回
            end
            else if (instr[31:28] == 4'b0010 && instr[27:24] == 4'b0001) begin   //SUB,%rA ->valA, %rB -> valB
                srcA <= instr[23:20];      //rA
                srcB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0001;  //SUB
                dstE_delayed <= instr[23:20];  //rA,用于写回
            end
            else if (instr[31:28] == 4'b0011 && instr[27:24] == 4'b0010) begin   //AND,%rA ->valA, %rB -> valB
                srcA <= instr[23:20];      //rA
                srcB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0010;  //AND
                dstE_delayed <= instr[23:20];  //rA,用于写回
            end
            else if (instr[31:28] == 4'b0011 && instr[27:24] == 4'b0011) begin   //XOR,%rA ->valA, %rB -> valB
                srcA <= instr[23:20];      //rA
                srcB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0011;  //XOR
                dstE_delayed <= instr[23:20];  //rA,用于写回
            end

            pc <= pc + 1;   //更新PC
        end
    end

    always @(posedge clock) begin
        alufun <= alufun_delayed;  // 将alufun延后1周期以配合ALU时序
        dstE <= dstE_delayed;  //将rA保存1个周期
    end



/*目前时序（working有效）：
    1. ram输出instr给processor
    2. 取指令instr并解析rA,rB,alufun
    3. 译码得到操作数valA,valB
    (3.5). ALU运算（需要valA,valB,alufun得到valE）（组合逻辑）
    4. valE写回寄存器文件(需要valE,dstE=rA)
    5. 用rID读取寄存器文件，输出数据rdata
*/

endmodule
