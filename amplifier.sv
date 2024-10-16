module amplifier
#(
    parameter WIDTH = 16      // Width of the audio signal (e.g., 16 bits)
)
(
    input wire signed [WIDTH-1:0] audio_in, // Input audio signal
    input wire [3:0] gain,                 // Gain control (e.g., 4-bit value for gain from 0 to 15)
    output wire signed [WIDTH-1:0] audio_out // Amplified audio signal
);

// Internal signal for scaled output
wire signed [WIDTH+3:0] scaled_audio;

// Multiply the audio input by the gain
assign scaled_audio = audio_in * gain;

// Clip the output to avoid overflow and distortion
assign audio_out = (scaled_audio > $signed({1'b0, {WIDTH{1'b1}}})) ? {1'b0, {WIDTH{1'b1}}} : // Max positive value
                   (scaled_audio < $signed({1'b1, {WIDTH{1'b0}}})) ? {1'b1, {WIDTH{1'b0}}} : // Max negative value
                   scaled_audio[WIDTH-1:0]; // Otherwise, use scaled value

endmodule