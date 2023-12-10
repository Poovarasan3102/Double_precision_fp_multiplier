**Project Title: Pipelined Double precision (fp64) Floating point Multiplier** 
*Gayathri Subramanian - cs23z065 Poovarasan M - me23z055*

**DESIGN**

**Project Structure**

**Input Processing:

  **Double Precision Floating Point Input:
	Two individual methods(input1, input 2) are implemented to receive the double precision floating point values as inputs.  Each method utilizes three separate FIFOs for efficient data buffering and handling:
	**Sign FIFO: This FIFO stores the sign bit of the input value.
	**Exponent FIFO: This FIFO stores the exponent bits of the input value.
	**Mantissa FIFO: This FIFO stores the mantissa bits of the input value.
Each bit of the input value is enqueued in the corresponding FIFO sequentially.

**De-queuing Inputs:
  At the start of the multiply rule, the sign, exponent, and mantissa bits are read from their respective FIFOs through first method and the same is dequeued at the end of the rule. This ensures that the rule's processing block operates on the latest received data.

**Sign Manipulation:
  The sign bits of both input operands are retrieved and compared.
Based on the comparison, the sign of the final result is determined using logic operation XOR. The final sign bit is then enqueued into the Sign Output FIFO.

**Exponent Manipulation:
  The exponent bits of both input operands are retrieved.  The final adjusted exponent is calculated by adding the values and subtracting bias value (1023) and subsequently enqueued into the Exponent Output FIFO.

While performing Exponent Manipulation, the multiply rule also checks for potential infinite (positive or negative) and NaN (Not a Number when either input is Infinite) conditions.  If either of them is detected, the appropriate flag (Infinite, Positive Infinite, Negative Infinite, NaN) is set.

**Mantissa Manipulation:
  The mantissa bits of both input operands are retrieved.  The actual multiplication operation is performed on the aligned mantissa (after adding the hidden significant bit) bits using * operator in Bluespec.  The resulting mantissa bits are then enqueued into the Mantissa Output FIFO.

**Output Enqueuing:
  The processed and manipulated sign, exponent, and mantissa bits are enqueued in their respective output FIFOs. These FIFOs serve as buffers for the subsequent stages in the pipeline.

**Normalization Process:

The exponent and mantissa bits obtained from the multiply rule are received as inputs in normalize rule.  The mantissa is analyzed to check if its most significant bit (MSB) is 1.
If the MSB is 1, indicating a non-normalized representation, the following steps are performed:
 *The mantissa is shifted one bit to the right (mantissa[104:53] is considered).
 *The exponent is incremented by 1 to maintain the correct value of the result.
Otherwise, the value of exponent is unchanged and normalized mantissa (mantissa[103:52] is considered) is obtained.
 *The normalized mantissa and the adjusted exponent are then enqueued in their respective output FIFOs.

**Overflow and Underflow Detection:

 While performing normalization, the normalize rule also checks for potential overflow and underflow conditions.  If either overflow or underflow is detected, the appropriate flag is set.

**Output Delivery:

 The normalized mantissa, adjusted exponent, and overflow/underflow flags are enqueued in their respective output FIFOs.

**Result Retrieval:

Two separate methods are implemented outside the normalize rule to retrieve the final results:
 *output1 method retrieves the mantissa and exponent bits from their respective FIFOs and combines them to form the final double precision floating point result.
 *outputflag method retrieves the flags and provides information on potential errors or exceptions during the multiplication process.

**Design Decisions**

Use of FIFO to pipeline the design: 

We have used multiple FIFOs (or each stage of pipeline) for two key reasons:

	**Pipelining: By introducing a buffer between stages, the FIFO queue enables a pipelined design. This allows different stages to operate independently, even if they have different clock cycles, without losing data.

	**Data Preservation: The FIFO ensures that data is not lost due to variations in the processing time of different operations. It acts as a temporary storage space, holding data until the next stage is ready to receive it.

Handling Overflow and Underflow: 

To prevent incorrect data at the output, we have implemented checks for both overflow and underflow conditions in the pipeline. These checks set appropriate flags to indicate when the data cannot be represented using 64-bit representation, enabling the external system to take corrective action.

3. Efficient Type Handling: 

We have utilized the * operator in Bluespec to achieve efficient type handling within the pipelined design. This operator offers several advantages:

	**Reduced Hardware Footprint: It minimizes the hardware resources required for type management, leading to a more compact and efficient implementation in hardware.

	**Simplified Design: It eliminates the need for additional logic for type conversion or manipulation, resulting in a cleaner and easier-to-understand design.

**These design decisions contribute to the overall efficiency, reliability, and performance of the pipelined multiplier module. They ensure smooth data flow, prevent data loss, and optimize hardware utilization.

**TESTING AND VERIFICATION**

**Verification Methodology**

To comprehensively verify our design, we have developed and tested using test benches, covering multiple corner cases and verifying flags of the module in Bluespec SystemVerilog:

1. Valid Case Verification (tb.bsv):

	**This test bench focuses on validating the functionality of the double precision floating point multiplication unit under various extreme and special conditions.

	**Edge cases: Exploring situations like the smallest and largest representable numbers, and ensuring the results conform to the IEEE-754 standard.  We tested for different combinations at different clock cycle:

  **Case1: Positive number x Negative number
	input1=>64'b0100000000111001100000000000000000000000000000000000000000000000
	input2=>64'b1011111111011000000000000000000000000000000000000000000000000000
        output=>64'b1100000000100011001000000000000000000000000000000000000000000000

  **Case2: Positive number x Positive number
	input1=>64'b0100000000111001100000000000000000000000000000000000000000000000
	input2=>64'b0011111111011000000000000000000000000000000000000000000000000000
        output=>64'b0100000000100011001000000000000000000000000000000000000000000000

  **Case3: Multiply by Zero
	input1=>64'b0000000000000000000000000000000000000000000000000000000000000000
	input2=>64'b0101011110100000000000000000000000000000000000000000000000000000
        output=>64'b0001011110110000000000000000000000000000000000000000000000000000


2. Flag Verification (tb_flag.bsv):

	**This test bench specifically focuses on verifying the behavior of the flag signals generated by the multiplier unit. Bit [5] of flag indicates overflow, Flag[4] indicates overflow, Flag[3] indicates Infinte Flag, Flag[2] indicates Positive Infinite, Flag[1] indicates Negative Infinite and Flag[0] indicates NaN. It tests various input scenarios and ensures that the flags are set correctly for:

	**Overflow: When the result of the multiplication exceeds the representable range.

           **Case1: Overflow 
		input1=>64'b0011111111111111111111111111111111111111111111111111111111111111
		input2=>64'b0011111111111111111111111111111111111111111111111111111111111111
                output=>64'b0100000000001111111111111111111111111111111111111111111111111110

                Flags: 100000

	**Underflow: When the result of the multiplication is too small to be represented accurately.

           **Case2: Underflow 
		input1=>64'b0000000000000000000000000000000000000000000000000000000000000001
		input2=>64'b0000000000000000000000000000000000000000000000000000000000000001
        	output=>64'b0100000000010000000000000000000000000000000000000000000000000010

                Flags: 010000

	**Infinite: When the result of the multiplication is close to infinity.

           **Case3: Positive Infinite
		input1=>64'b0111110111111000000000000000000000000000000000000000000000000000
		input2=>64'b0111111111110100000000000000000000000000000000000000000000000000
        	output=>64'b0100000000001111111111111111111111111111111111111111111111111110

                Flags: 001100

           **Case4: Negative Infinite
		input1=>64'b0111111111110100000000000000000000000000000000000000000000000000
		input2=>64'b1111110111110100000000000000000000000000000000000000000000000000
        	output=>64'b1011110111111001000000000000000000000000000000000000000000000000

                Flags: 001010

           **Case4: NaN
		input1=>64'b0111111111111000000000000000000000000000000000000000000000000000
		input2=>64'b0111111111110100000000000000000000000000000000000000000000000000
        	output=>64'b0011110111111110000000000000000000000000000000000000000000000000

                Flags: 000001

**These two test benches provide comprehensive coverage for our double precision floating point multiplication unit, ensuring its accuracy, reliability, and adherence to the IEEE-754 standard. Further, the operation of the pipelined multiplier has been verified by simulating the design and verifying the outputs using ‘GTK Wave’.

**How to Run**

1. It is assumed the system has Bluespec System Verilog compiler and the source code in working directory. 
2. Enter into the running_environment directory  #cd running_environment
3. Enter command #make clean and #make compile link simulate  //This will executes the required command to compile and simulate the .bsv with the testbench and generates the vcd file that can be viewed in via GTK.
4. We have two test bench as I mentioned earlier (tb.bsv and tb_flag.bsv)
5. To test the corner cases with tb.bsv make the following change in th Makefile in the running_environment directory and then execute the 3rd step
   TOPFILE   = tb.bsv
   TOPMODULE = mktester
6. To test the flag cases with tb_flag.bsv make the following change in th Makefile in the running_environment directory and then execute the 3rd step
   TOPFILE   = tb_flag.bsv
   TOPMODULE = mktester_flag
7. Enter command #make verilog to generate the equivalent verilog file for the BSV Design.
8. The verilog file will be generated in the running_environment/verilog_dir, which we will be using for the synthesis using opensource tool (Openlane)
9. Enter the OpenLane directory and enter command #sudo make mount //you will enter into the openlane environment
10 Add your file in the OpenLane/designs directory by creating folder like example spm design and specify the top module in the config.json 
11 Then run this command #./flow.tcl -design design_directory

**SYNTHESIS**

We used OpenLane synthesis tool that will generate the synthesis report in the working directory of the design in the runs directory and we can find the Area and STA summary on that directory.
