// THE DUCK DAC
//       (@_
//    \\\_\
//    <____)

module sigma_delta_dac #(parameter MSBI = 7, parameter INV = 1'b1)
(
    output reg      DACout,   // Average Output for analog low-pass filter
    input  [MSBI:0] DACin,    // DAC input (MSBI defines the highest input bit)
    input           CLK,      // Clock input
    input           RESET     // Reset input
);

reg [MSBI+2:0] DeltaAdder;   // Output of the Delta Adder
reg [MSBI+2:0] SigmaAdder;   // Output of the Sigma Adder
reg [MSBI+2:0] SigmaLatch;   // Latched output of Sigma Adder

// Sequential logic handles the main DAC process
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        // Initialize SigmaLatch to half-scale on reset
        SigmaLatch <= {1'b1, {MSBI+1{1'b0}}};  // Equivalent to 1 << (MSBI + 1)
        DACout <= INV;  // Output the inverse if INV is 1, otherwise 0
    end else begin
        // DeltaB is either a positive or negative reference level depending on SigmaLatch MSB
        // It effectively performs Sigma-Delta modulation
        DeltaAdder <= DACin + {SigmaLatch[MSBI+2], SigmaLatch[MSBI+2]} << (MSBI + 1); 
        SigmaAdder <= DeltaAdder + SigmaLatch;  // Accumulate the error (Sigma)
        SigmaLatch <= SigmaAdder;  // Update the feedback latch
        
        // DACout is based on the MSB of the accumulator, inverted if INV=1
        DACout <= SigmaLatch[MSBI+2] ^ INV;
    end
end

endmodule