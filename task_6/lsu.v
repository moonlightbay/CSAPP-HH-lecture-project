/*ram 同时作为指令存储器和数据存储器，所以在 lsu 中需要对通过顶层的写入操作
和指令执行时的写入操作用 MUX 选择。*/
/*对ram而言，只有wEn,rEn,addr,wDat,rDat五个信号*/

module lsu(  //Load Store Unit
input clock,
input reset,
//write Inst signals from top module
input [8 : 0] addr,     //instr address could be input or PC
input wr,               //write enable of instr
input [31 : 0] wdata,   //instr or data to be written,decide by processor,instr or valA
input working,
output[31 : 0] instr,  //read value of instr
//write Data signals from front stages
input SW,            //SW is working
input LW,            //LW is working
input [31 : 0] valE, //write or read address from ALU
input [3 : 0] dstE, //reg address, dstE -> dstM
output wire[31 : 0] valM, //read value of data
output wire[3 : 0] dstM,//reg address
output reg LW_DONE //LW_DONE is used to notify the processor that the data is ready
//you can add other necessary signals freely...
);

/* signals for ram */
wire[31:0] ram_rdata;    //read data from ram,instr or data
wire[8:0] ram_addr;      //address for ram,instr or data
wire wEn;               //write enable for ram
wire rEn;                //read enable for ram

/* signals for regfile */
reg[3:0] dstM_reg; 

/* define the signals*/
assign wEn = working ? SW : wr;          //MUX for wEn
assign rEn = working;                       //rEn is always working
assign ram_addr = (SW | LW) ? valE[7:0] : addr;  //MUX for ram_addr
assign dstM = dstM_reg;                         //dstM is from dstM_reg

/* instance for ram */
ram inst_ram(
    .clock(clock),
    .addr(ram_addr),
    .wEn(wEn),
    .wDat(wdata),      
    .rEn(rEn),
    .rDat(ram_rdata)
);    //ram_rdata will be updated in the next clock cycle

/* MUX for instr and data */
assign instr = working ? ram_rdata : 32'b0; 
assign valM = working ? ram_rdata : 32'b0;   

always @(posedge clock) begin
    if (reset) begin
        dstM_reg <= 0;
    end
    else begin
        if (LW) begin
            dstM_reg <= dstE; 
            LW_DONE <= 1;     
        end
        else begin
            LW_DONE <= 0;
        end
    end
end

endmodule

