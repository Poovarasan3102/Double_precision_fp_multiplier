package dpfpmultiplier;

import FIFO :: *;

interface MulIfc ;
method Action fp1 (Bit#(64) input1);
method Action fp2 (Bit#(64) input2);
method ActionValue#(Bit#(64)) output1;
method ActionValue#(Bit#(6)) outputflag;

endinterface


module mkmul(MulIfc) ;

    //flags
    Reg#(Bit#(1)) overflow<- mkReg(0);
    Reg#(Bit#(1)) underflow<- mkReg(0);
    Reg#(Bit#(1)) infinite<- mkReg(0);
    Reg#(Bit#(1)) nan<- mkReg(0);
    FIFO#(Bit#(1)) positive_infinite <- mkFIFO;   

    FIFO#(Bit#(1)) sfifo <- mkFIFO;
    FIFO#(Bit#(11)) expfifo <- mkFIFO;
    FIFO#(Bit#(11)) expoutfifo <- mkFIFO;
    FIFO#(Bit#(52)) manfifo <- mkFIFO;

    FIFO#(Bit#(1)) is1fifo <- mkFIFO;
    FIFO#(Bit#(11)) ie1fifo <- mkFIFO;
    FIFO#(Bit#(52)) im1fifo <- mkFIFO;

    FIFO#(Bit#(1)) is2fifo <- mkFIFO;
    FIFO#(Bit#(11)) ie2fifo <- mkFIFO;
    FIFO#(Bit#(52)) im2fifo <- mkFIFO;

    FIFO#(Bit#(106)) pdtfifo <- mkFIFO;

    (* descending_urgency = "multiply, normalize" *)


    rule multiply;
                
                sfifo.enq(is1fifo.first ^ is2fifo.first);

                Bit#(12) exptemp=extend((ie1fifo.first+ie2fifo.first) - 1023);

                if((ie1fifo.first==2047)&&(ie2fifo.first==2047))
                nan<=1;
                else if((ie1fifo.first==2047)||(ie2fifo.first==2047)) begin
                    infinite<=1;
                    nan<=0;
                    if((is1fifo.first ^ is2fifo.first)==1) begin
                        // $display ("  hi") ;
                    positive_infinite.enq(0);
                    end 
                    else 
                    positive_infinite.enq(1);
                    end
                    
                else begin
                positive_infinite.enq(0);
                infinite<=0;
                end
        
                                
                expfifo.enq(exptemp[10:0]);
                pdtfifo.enq({53'b0,1,im1fifo.first} * {53'b0,1,im2fifo.first});
                
                is1fifo.deq;
                is2fifo.deq;
                ie1fifo.deq;
                ie2fifo.deq;    
                im1fifo.deq;
                im2fifo.deq;
       

     endrule
    
    
    rule normalize;


        Bit#(11) exp=expfifo.first;
        Bit#(106) mp=pdtfifo.first;
        Bit#(11) e1,e2;
        
        if (mp[105] == 1) begin
                // Normalize the mantissa to 52 bits and increment the exponent
                manfifo.enq(mp[104:53]);
                expoutfifo.enq(exp + 1);
                e1=exp+1;
            end else begin
                // Normalize the mantissa to 52 bits without incrementing the exponent
                manfifo.enq(mp[103:52]);
                expoutfifo.enq(exp);
                e1=exp;
        end

        

        e2=e1+1023;


        if (e2<1)
        begin
        underflow<=1;
        overflow<=0;
        end
        else if(e1>1023)
        begin
        overflow<=1;
        underflow<=0;
        end
        else 
        begin
        overflow<=0;
        underflow<=0;
        end

        expfifo.deq;
        pdtfifo.deq;
        
    endrule

    method Action fp1 (Bit#(64) input1);

    is1fifo.enq(input1[63]);
    ie1fifo.enq(input1[62:52]);
    im1fifo.enq(input1[51:0]);
     
    endmethod

    method Action fp2 (Bit#(64) input2);

    is2fifo.enq(input2[63]);
    ie2fifo.enq(input2[62:52]);
    im2fifo.enq(input2[51:0]);
        
    endmethod

    method ActionValue#(Bit#(64)) output1;

    Bit#(64) outputfp;
    outputfp={sfifo.first,expoutfifo.first,manfifo.first};  

    sfifo.deq;
    manfifo.deq;
    expoutfifo.deq;
    return outputfp;
        
    endmethod

    method ActionValue#(Bit#(6)) outputflag;

    Bit#(6) flags;
    if(infinite==1)
    flags={overflow,underflow,infinite, positive_infinite.first,~positive_infinite.first,nan};
    else
    flags={overflow,underflow,3'b0,nan};

    positive_infinite.deq();
    return flags;

    endmethod

    endmodule

endpackage
