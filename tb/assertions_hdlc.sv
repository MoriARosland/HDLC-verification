//////////////////////////////////////////////////
// Title:   assertions_hdlc
// Author:  
// Date:    
//////////////////////////////////////////////////

/* The assertions_hdlc module is a test module containing the concurrent
   assertions. It is used by binding the signals of assertions_hdlc to the
   corresponding signals in the test_hdlc testbench. This is already done in
   bind_hdlc.sv 

   For this exercise you will write concurrent assertions for the Rx module:
   - Verify that Rx_FlagDetect is asserted two cycles after a flag is received
   - Verify that Rx_AbortSignal is asserted after receiving an abort flag
*/

module assertions_hdlc (
  output int   ErrCntAssertions,
  input  logic Clk,
  input  logic Rst,
  input  logic Rx,
  input  logic Rx_FlagDetect,
  input  logic Rx_ValidFrame,
  input  logic Rx_AbortDetect,
  input  logic Rx_AbortSignal,
  input  logic Rx_Overflow,
  input  logic Rx_WrBuff,
  input  logic Rx_EoF,
  input  logic Tx,
  input  logic Tx_AbortFrame,
  input  logic Tx_AbortedTrans,
  input  logic Tx_ValidFrame,
  input  logic Tx_Enable,
  input  logic [7:0] Tx_FrameSize,
  input  logic [7:0] Tx_BufferCount,
  input  logic Tx_Done
);

  logic TransmittInProgress; // Used for zero pattern checking
  logic DataTransmittInProgress; // Used for zero insert checking

  const int FLAG_TRANSMIT_DELAY = 8; // 8 flag bits
  const int DATA_TRANSFER_START_DELAY = 9; // 8 flag bits + 1 zero start bit

  initial begin
    ErrCntAssertions  =  0;
    TransmittInProgress = '0;
    DataTransmittInProgress = '0;
  end

  initial begin // Track the state of the Tx serial-line
    forever begin
      wait(Tx_ValidFrame); // Transmission has started
      TransmittInProgress = 1'b1;

      wait(!Tx_ValidFrame); // Transmission has ended

      // Wait for end flag to transmit, which starts on the NEXT clk cycle.
      // Therefore +1.
      repeat(1 + FLAG_TRANSMIT_DELAY) @(posedge Clk);

      TransmittInProgress = 1'b0;
    end
  end

  initial begin // Track when data is on the Tx serial-line (including FCS, no flags)
    forever begin
      wait(TransmittInProgress); // Transmission has started

      // Wait for start flag and start zero-bit to transmit, which starts on the NEXT clock edge.
      // Therefore +1
      repeat(1 + DATA_TRANSFER_START_DELAY) @(posedge Clk); 
      DataTransmittInProgress = 1'b1;

      wait(!Tx_ValidFrame); // Transmission has ended
      DataTransmittInProgress = 1'b0;
    end
  end

  /// Sequence utilities (Rx and Tx use some of the same sequences):

  sequence AbortFlag_sequence(serial_line); 
    // Note that least significant bit is received first
    !serial_line ##1 serial_line[*7]; // Pattern: 1111 1110
  endsequence

  sequence FrameFlag_sequence(serial_line);
    !serial_line ##1 serial_line[*6] ##1 !serial_line; // Pattern: 0111 1110
  endsequence

  // If either an abort flag or regular flag is detected while
  // Rx_ValidFrame is high, we know a transmission has ended, and
  // that EoF must be asserted.
  sequence EndOfFrame_sequence;
    (AbortFlag_sequence(Rx) or FrameFlag_sequence(Rx)) ##0 Rx_ValidFrame;
  endsequence

  /*******************************************
   *  Verify correct Rx_FlagDetect behavior  *
   *******************************************/

  // Check if flag sequence is detected
  property RX_FlagDetect;
    @(posedge Clk) FrameFlag_sequence(Rx) |-> ##2 Rx_FlagDetect;
  endproperty

  RX_FlagDetect_Assert : assert property (RX_FlagDetect) begin
    $display("PASS: Flag detect");
  end else begin 
    $error("Flag sequence did not generate FlagDetect"); 
    ErrCntAssertions++; 
  end

  /********************************************
   *  Verify correct Rx_AbortSignal behavior  *
   ********************************************/

  //If abort is detected during valid frame. then abort signal should go high
  property RX_AbortSignal;
    // INSERT CODE HERE
    @(posedge Clk) disable iff (!Rx_ValidFrame) (Rx_AbortDetect) |=> Rx_AbortSignal; 
  endproperty

  RX_AbortSignal_Assert : assert property (RX_AbortSignal) begin
    $display("PASS: Abort signal");
  end else begin 
    $error("AbortSignal did not go high after AbortDetect during validframe"); 
    ErrCntAssertions++; 
  end

  // Verify correct behaviour when receiving an abort pattern (Spec10)
  property RX_AbortDetect;
    @(posedge Clk) disable iff (!Rx_ValidFrame) (AbortFlag_sequence(Rx)) |=> ##1 Rx_AbortDetect;
  endproperty

  Rx_AbortDetect_Assert : assert property (RX_AbortDetect) begin
    $display("PASS: Abort flag successfully generated abort signal (RX)");
  end else begin
    $error("FAIL: Abort flag did not generate abort signal (RX)");
    ErrCntAssertions++; 
  end

  // Verify generation of end of frame (Spec12)
  // Spec does not specify when Rx_EoF should be asserted,
  // So we give it arbitrarily 7 clock cycles to go high.
  property RX_EndOfFrame;
    @(posedge Clk) EndOfFrame_sequence |=> ##[0:6] Rx_EoF;
  endproperty

  Rx_EndOfFrameDetect : assert property (RX_EndOfFrame) begin
    $display("RX_EndOfFrame:: PASS: Succesfully generated end of frame");
  end else begin
    $error("RX_EndOfFrame:: PASS: Failed to generate end of frame");
    ErrCntAssertions++; 
  end

  
/********************************************
  * Verify correct Tx_AbortedTrans behaviour *
  ********************************************/

property TX_AbortedTrans;
  @(posedge Clk)
  !Tx_AbortFrame ##1 Tx_AbortFrame ##0 Tx_ValidFrame |=> ##1 Tx_AbortedTrans;
endproperty

TX_AbortedTrans_Assert : assert property (TX_AbortedTrans) begin 
  $display("TX_AbortedTrans_Assert: PASS: Tx_AbortedTrans asserted after aborting frame during transmission");
end else begin
  $error("TX_AbortedTrans_Assert:: Error: Tx_AbortedTrans not assert after aborting frame during transmission");
  ErrCntAssertions++;
end

/********************************************
 * Verify correct Tx_Complete on emptied TX buffer  *
 ********************************************/

property TransmitComplete;
  @(posedge Clk)
  TransmittInProgress ##0 (Tx_BufferCount == Tx_FrameSize - 1) |-> Tx_Done;
endproperty

TransmitComplete_Assert : assert property (TransmitComplete)
  $display("TransmitComplete_Assert: SUCCESS: Tx_Complete asserted after TX buffer emptied");
else begin
  $error("TransmitComplete_Assert: ERROR: Tx_Complete not asserted after TX buffer emptied");
  ++ErrCntAssertions;
end

/***********************************
  * Verify idle pattern generation *
  **********************************/

  // Only 1's should be on the Tx serial line when not transmitting a frame
  property TX_IdlePattern;
    @(posedge Clk) !TransmittInProgress |-> Tx;
  endproperty

  TX_IdlePattern_Assert : assert property (TX_IdlePattern)
  else begin
    $error("TX_IdlePattern_Assert:: FAIL: Did not generate idle pattern when not transmitting");
    ErrCntAssertions++;
  end

/***********************************
  * Verify Abort flag generation *
  **********************************/

  property TX_ZeroPadding;
    @(posedge Clk) disable iff (!DataTransmittInProgress)
      !Tx ##1 Tx[*5] |=> !Tx; // A zero should be inserted for every 5 consequtive 1's during datatransmission
  endproperty

  TX_ZeroPadding_Assert : assert property (TX_ZeroPadding)
  else begin
    $error("TX_ZeroPadding_Assert:: FAIL: Missing zero insertion");
    ErrCntAssertions++;
  end


  // Verify that an abort flag is transmitted when Tx_AbortFrame is asserted
  property TX_AbortFlag;
    @(posedge Clk) Tx_AbortFrame ##0 Tx_ValidFrame |=> ##3 AbortFlag_sequence(Tx);
    // It takes 3 clock cycles to propagate the Tx_AbortFrame signal and initiate
    // transmission of the abort flag
  endproperty


  TX_AbortFlag_Assert : assert property (TX_AbortFlag) begin 
    $display("TX_AbortFlag_Assert: PASS: Transmittet abort flag sequence");
  end else begin
    $error("TX_AbortFlag_Assert:: Error: Did not transmitt abort flag sequence");
    ErrCntAssertions++;
  end

endmodule
