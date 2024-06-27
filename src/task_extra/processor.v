
module processor(
    input wire clock,
    input wire[8:0] addr,      //the input address
    input wire wEn,
    input wire[31:0] wDat,    //wDat is for writting data to ram         
    input wire working,    
    output [31:0] r0,
    output [31:0] r1,
    output [31:0] r2,
    output [31:0] r3,
    output [31:0] r4,
    output [31:0] r5
);
    /*PC*/
    reg [15:0] pc = 0;         // Program counter
    reg IRMOV_delayed,IRMOV;   //IRMOV signal
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
    wire LW_DONE;              // data from lsu is ready
    assign addr_lsu = wEn ? addr : pc[7:0];  //MUX for addr_lsu
    wire [3:0]lsu_dstM;
    wire [31:0] lsu_valM;    //output of lsu

   /*regfile*/
    reg[3:0] dstE = 4'b0,dstM = 4'b0;    //input for lsu
    reg[3:0] rA = 4'b0, rB = 4'b0;      //srcA and srcB-->rA,rB;
    wire[31:0] valA, valB,RAWed_valA;    //output of regfile
    reg[3:0] dstE_delayed;    //delayed dstE for matching time sequence
    assign RAWed_valA = (RAW_RA)? last_valM : valA;  //put valM to valA if RAW
    assign wdata_lsu = SW? RAWed_valA : wDat;      //MUX for wdata_lsu

    /*ALU*/
    reg[3:0] alufun;          //ALU function code
    reg[3:0] alufun_delayed; 
    reg[31:0] valC,valC_delayed;           //imm
    wire[31:0] srcA,RAWed_srcA;          //valA or valC
    wire[31:0] srcB,RAWed_srcB;          //valB
    assign srcA = (LW | SW |IRMOV)? valC : valA;  //MUX for srcA
    assign srcB = IRMOV?  31'b0: valB;                  //srcB is always valB
    assign RAWed_srcA = (RAW_RA)? last_valE : srcA;  //put valE to srcA if RAW
    assign RAWed_srcB = (RAW_RB)? last_valE : srcB;  //put valE to srcB if RAW
    wire[31:0] valE;           //result of ALU
    
    /*extra:RAW*/
    reg[31:0] last_instr,last_last_instr;
    reg[3:0] last_rA,last_last_rA;
    reg RAW_RA,RAW_RB,RAW_RA_delayed,RAW_RB_delayed;
    reg[31:0] last_valE;
    reg[31:0] last_valM;
    wire stall;
    assign stall = (working && (instr[31:28] == 4'b0010 && 
                      ((instr[23:20] == last_rA)|  (instr[19:16] == last_rA))))? 1'b1 : 1'b0;

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
        .dstE(dstE),      //rA
        .valM(lsu_valM),      //data to be written to regfile
        .dstM(lsu_dstM),       //rA
        .LW_DONE(LW_DONE) //data is ready
    );
    
    //instance for regfile
    regfile inst_regfile(  
        .dstM(lsu_dstM),        
        .valM(lsu_valM),
        .rA(rA),
        .rB(rB),
        .rID(rID),
        .reset(1'b0),
        .clock(clock),
        .valA(valA),
        .valB(valB),
        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3),
        .r4(r4),
        .r5(r5),
        .rdata(rdata)
    );

    //instance for ALU
    alu inst_alu(
        .aluA(RAWed_srcA),
        .aluB(RAWed_srcB),
        .alufun(alufun),
        .valE(valE)
    );

    //decode
     always @(posedge clock) begin
        if (working && (instr != 32'h0) && ~LW && ~SW) begin   //if LW/SW ,stall
            if (instr[31:28] == 4'b0001 && instr[27:24] == 4'b0000) begin   //IRMOV, rB -> valC
                IRMOV_delayed <= 1'b1;
                dstE_delayed <= instr[19:16];      //rB
                valC_delayed <= instr[15:0];       //valC
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b0;
                alufun_delayed <= 4'b0000;  //ADD
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0010 && instr[27:24] == 4'b0000) begin   //ADD,%rA ->valA, %rB -> valB
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0000;  //ADD
                dstE_delayed <= instr[23:20];  //rA
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b0;
                IRMOV_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0010 && instr[27:24] == 4'b0001) begin   //SUB,%rA ->valA, %rB -> valB
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0001;  //SUB
                dstE_delayed <= instr[23:20];  //rA
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b0;
                IRMOV_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0011 && instr[27:24] == 4'b0010) begin   //AND,%rA ->valA, %rB -> valB
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0010;  //AND
                dstE_delayed <= instr[23:20];  //rA
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b0;
                IRMOV_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0011 && instr[27:24] == 4'b0011) begin   //XOR,%rA ->valA, %rB -> valB
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                alufun_delayed <= 4'b0011;  //XOR
                dstE_delayed <= instr[23:20];  //rA
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b0;
                IRMOV_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0100 && instr[27:24] == 4'b0000)begin   //LW
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                valC_delayed <= instr[15:0];  //valC
                alufun_delayed <= 4'b0000;  //ADD
                dstE_delayed <= instr[23:20];  //rA for lsu
                SW_delayed <= 1'b0;
                LW_delayed <= 1'b1;
                IRMOV_delayed <= 1'b0;
                dstM <= 4'b1111;   //把dsM悬空，以免干扰lsu写入寄存器
                pc <= pc + 1;   //update PC
            end
            else if (instr[31:28] == 4'b0100 && instr[27:24] == 4'b0001)begin   //SW
                rA <= instr[23:20];      //rA
                rB <= instr[19:16];      //rB
                valC_delayed <= instr[15:0];  //valC
                dstE_delayed <= 4'b1111;
                alufun_delayed <= 4'b0000;  //ADD
                //SW does't need to write back
                SW_delayed <= 1'b1;
                LW_delayed <= 1'b0;
                IRMOV_delayed <= 1'b0;
                pc <= pc + 1;   //update PC
            end

            /*process RAW*/
            if (instr[31:28] != 4'b0001 && IRMOV_delayed == 1'b1 &&      //RAW after IRMOV
                    (instr[23:20] == dstE_delayed | instr[19:16] == dstE_delayed)) begin
                        if (instr[23:20] == dstE_delayed) begin
                            RAW_RA_delayed <= 1'b1;
                        end
                        if (instr[19:16] == dstE_delayed) begin
                            RAW_RB_delayed <= 1'b1;
                        end  
                    end
            else begin
                RAW_RA_delayed <= 1'b0;
                RAW_RB_delayed <= 1'b0;
            end

            last_rA <= instr[23:20];          //RAW after other instrs
            last_last_rA <= last_rA;
            last_instr <= instr;
            last_last_instr <= last_instr;
            if ((last_last_instr[31:28] != 8'b0100 && instr[23:20] == last_last_rA) | 
                   (last_instr[31:28] != 8'b0100 && instr[23:20] == last_rA) && instr[31:28] != 4'b0001) 
                    RAW_RA_delayed <= 1'b1; // raw in rA
            else RAW_RA <= 1'b0;
            if ((last_last_instr[31:28] != 8'b0100 && instr[19:16] == last_last_rA) |
                   (last_instr[31:28] != 8'b0100 && instr[19:16] == last_rA)&& instr[31:28] != 4'b0001)  
                   RAW_RB_delayed <= 1'b1; // raw in rb
            else RAW_RB <= 1'b0;

        end

        else if (working && (LW | SW)) begin  //LW/SW is working
            if (LW) begin
                LW_delayed <= 1'b0;
            end
            if (SW) begin
                SW_delayed <= 1'b0;
            end
            dstE_delayed <= 4'b1111;      //if stall then disable dstE
        end
        else if (instr == 32'h0) begin
        dstE_delayed <= 4'b1111;    
        end

    end

    //delay unit
    always @(posedge clock) begin
        alufun <= alufun_delayed;  // 将alufun延后1周期以配合ALU时序
        dstE <= dstE_delayed;      //将rA保存1个周期，用于输入lsu
        SW <= SW_delayed;          //将SW保存1个周期，用于alu&lsu
        LW <= LW_delayed;          //将LW保存1个周期，用于alu&lsu
        valC <= valC_delayed;      //将valC保存1个周期，用于alu
        IRMOV <= IRMOV_delayed;    //将IRMOV保存1个周期，用于alu
        last_valE <= valE;
        last_valM <= lsu_valM;
        RAW_RA <= RAW_RA_delayed;
        RAW_RB <= RAW_RB_delayed;
    end

endmodule