/*ram 同时作为指令存储器和数据存储器，所以在 lsu 中需要对通过顶层的写入操作
和指令执行时的写入操作用 MUX 选择。*/


module lsu(  //Load Store Unit
input clock,
input reset,
//write Inst signals from top module
input [8 : 0] addr,
input wr,
input [31 : 0] wdata,
input working,
//write Data signals from front stages
input [31 : 0] valE, //write or read address
input [3 : 0] dstE, //reg address, dstE -> dstM
output [31 : 0] valM, //read value
output [3 : 0] dstM //reg address
//you can add other necessary signals freely...
);

