
/*流水化：使用四级流水线，例化各个模块，第一级在每个时钟周期取指并解
析，第二级在每个时钟周期译码得到操作数 rA 和 rB，第三级在每个时钟周期执行
算数逻辑运算得到 ALU 的运算结果 valE，第四级在每个时钟周期将 ALU 的运算
结果 valE 写回寄存器文件；将立即数 valC 写回寄存器文件。*/


module processor(
    input wire clock,
    input wire[8:0] addr,      //the input address
    input wire wEn,
    input wire[31:0] wDat,    //wDat is for writting data to ram         
    input wire working,    
    input wire[3:0] rID,
    output [31:0] rdata
);
    /*PC*/
    reg [15:0] pc = 0;         // Program counter

    /*指令*/
    
    // icode <= instr[31:28];
    // ifun <= instr[27:24];
    // rA <= instr[23:20];   
    // rB <= instr[19:16];
    // valC <= instr[15:0];
    
   /*lsu*/
    wire [31:0] instr;         // Instruction,fronm lsu&ram
    wire [8:0] addr_lsu;       // instr Address for lsu
    wire [31:0] wdata_lsu;     //data to be written to ram 
    reg SW = 1'b0, SW_delayed = 1'b0;                   // SW signal for lsu
    reg LW = 1'b0, LW_delayed = 1'b0;                   // LW signal for lsu
    reg[3:0] lsu_dstE,lsu_dstE_delayed;         // reg Address for lsu
    wire [3:0] lsu_dstM;       // reg Address from lsu
    wire [31:0] lsu_valM;       // reg data from lsu
    wire LW_DONE;              // data from lsu is ready
    assign addr_lsu = wEn ? addr : pc[7:0];  //MUX for addr_lsu
    
   /*regfile*/
    reg[3:0] dstE = 4'b0, dstM = 4'b0;      //dstE = ra(ADD,SUB...), dstM = rb(IRMOV)
    reg[31:0] valM = 32'h0;           //data to be written to regfile(no alu)
    reg[3:0] rA = 4'b0, rB = 4'b0;      //srcA and srcB-->rA,rB;
    wire[31:0] valA, valB;    //output of regfile
    reg[3:0] dstE_delayed;    //delayed dstE for matching time sequence
    assign wdata_lsu = SW? valA : wDat;      //MUX for wdata_lsu
    /*ALU*/
    reg[3:0] alufun;          //ALU function code
    reg[3:0] alufun_delayed; 
    reg[31:0] valC,valC_delayed;           //imm
    wire[31:0] srcA;          //valA or valC
    assign srcA = (LW | SW)? valC : valA;  //MUX for srcA
    wire[31:0] valE;           //result of ALU

    //instance for lsu
    lsu inst_lsu(
        .clock(clock),
        .reset(1'b0),
        .addr(addr_lsu),
        .wr(wEn),
        .wdata(wdata_lsu),
        .working(working),
        .instr(instr),
        .SW(SW),
        .LW(LW),
        .valE(valE),      //%rB + valC
        .dstE(lsu_dstE),      //rA
        .valM(lsu_valM),      //data to be written to regfile
        .dstM(lsu_dstM),       //rA
        .LW_DONE(LW_DONE) //data is ready
    );
    
    //instance for regfile
    regfile inst_regfile(  
        .dstE(LW?lsu_dstE:dstE),
        .valE(valE),
        .dstM(LW_DONE?lsu_dstM:dstM),        
        .valM(LW_DONE?lsu_valM:valM),
        .rA(rA),
        .rB(rB),
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

    //instance for ALU
    alu inst_alu(
        .aluA(srcA),
        .aluB(valB),
        .alufun(alufun),
        .valE(valE)
    );

    //decode
     always @(posedge clock) begin
        if (working && instr != 32'h0 && ~LW && ~SW) begin   //if LW/SW ,stall
            if (instr[31:28] == 4'b0001 && instr[27:24] == 4'b0000) begin   //IRMOV, rB -> valC
                dstM <= instr[19:16];      //rB
                valM <= instr[15:0];       //valC
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0010 && instr[27:24] == 4'b0000) begin   //ADD,%rA ->valA, %rB -> valB
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0000;  //ADD
                dstE_delayed <= instr[23:20];  //rA
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0010 && instr[27:24] == 4'b0001) begin   //SUB,%rA ->valA, %rB -> valB
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0001;  //SUB
                dstE_delayed <= instr[23:20];  //rA
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0011 && instr[27:24] == 4'b0010) begin   //AND,%rA ->valA, %rB -> valB
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0010;  //AND
                dstE_delayed <= instr[23:20];  //rA
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0011 && instr[27:24] == 4'b0011) begin   //XOR,%rA ->valA, %rB -> valB
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0011;  //XOR
                dstE_delayed <= instr[23:20];  //rA
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0100 && instr[27:24] == 4'b0000)begin   //LW
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                valC_delayed <= instr[15:0];  //valC
                alufun_delayed <= 4'b0000;  //ADD
                lsu_dstE_delayed <= instr[23:20];  //rA for lsu
                dstE_delayed <= 4'b1111;  //dstE悬空，以免干扰alu写入寄存器
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b1;
                dstM <= 4'b1111;   //把dsM悬空，以免干扰lsu写入寄存器
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0100 && instr[27:24] == 4'b0001)begin   //SW
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                valC_delayed <= instr[15:0];  //valC
                alufun_delayed <= 4'b0000;  //ADD
                //SW does't need to write back
                SW_delayed <= 1'b1;
                LW_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end
            
        end
        else if (working && (LW | SW)) begin  //LW/SW is working
            if (LW) begin
                LW_delayed <= 1'b0;
            end
            if (SW) begin
                SW_delayed <= 1'b0;
            end
        end
    end

    always @(posedge clock) begin
        alufun <= alufun_delayed;  // 将alufun延后1周期以配合ALU时序
        dstE <= dstE_delayed;      //将rA保存1个周期，用于写回
        SW <= SW_delayed;          //将SW保存1个周期，用于alu&lsu
        LW <= LW_delayed;          //将LW保存1个周期，用于alu&lsu
        valC <= valC_delayed;      //将valC保存1个周期，用于alu
        lsu_dstE <= lsu_dstE_delayed;  //将lsu_dstE保存1个周期，用于lsu写入寄存器
    end

endmodule