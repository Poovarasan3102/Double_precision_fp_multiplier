import merged ::* ;

module mktester(Empty);

Reg#(int) clk <- mkReg(0) ;
Reg#(int) count <- mkReg(1) ;

Reg#(Bit#(64)) outputmul <- mkReg(0) ;
Reg#(Bit#(64)) ip1 <- mkReg(0) ;
Reg#(Bit#(64)) ip2 <- mkReg(0) ;
Reg#(Bit#(2)) flags<-mkReg(0);

MulIfc mul <- mkmul() ;

Bit#(64) pyld1, pyld2, pyld3, pyld4, pyld5 ;

pyld1=64'b0100000000111001100000000000000000000000000000000000000000000000;
pyld2=64'b1011111111011000000000000000000000000000000000000000000000000000;

pyld3=64'b0011111111011000000000000000000000000000000000000000000000000000;

pyld4=64'b0000000000000000000000000000000000000000000000000000000000000000;
pyld5=64'b0101011110100000000000000000000000000000000000000000000000000000;


rule timer;
      clk <= clk +1 ;

      if(clk == 25) begin 
         $finish;
      end

endrule

rule data;

if(clk == 1 ) // Positive number x Negative number
begin 
      ip1<=pyld1;
      ip2<=pyld2;
      mul.fp1(pyld1);
      mul.fp2(pyld2);
end

if(clk == 2 ) // Positive number x Positive number
begin 
      ip1<=pyld1;
      ip2<=pyld3;
      mul.fp1(pyld1);
      mul.fp2(pyld3);
end

if(clk == 3 ) // Multiply by zero
begin 
      ip1<=pyld4;
      ip2<=pyld5;
      mul.fp1(pyld4);
      mul.fp2(pyld5);
end

endrule

rule outputd;

if(clk<15) begin
         let a <-mul.output1;
         let b <-mul.outputflag;
         outputmul<=a;
         $display ("Sample no: %0d",count) ;
         $display ("Output: %b",a) ;
         $display ("Flags: %b",b) ;
         flags<=b;
         count<=count+1;
      end

endrule

endmodule
