//////////////////////////////////////////////////
// Title:   testPr_hdlc
// Author: 
// Date:  
//////////////////////////////////////////////////

/* testPr_hdlc contains the simulation and immediate assertion code of the
   testbench. 

   For this exercise you will write immediate assertions for the Rx module which
   should verify correct values in some of the Rx registers for:
   - Normal behavior
   - Buffer overflow 
   - Aborts

   HINT:
   - A ReadAddress() task is provided, and addresses are documentet in the 
     HDLC Module Design Description
*/

program testPr_hdlc(
  in_hdlc uin_hdlc
);
  
  int TbErrorCnt;

  // HDLC register addresses:
  const logic [2:0] RX_BUFFER_ADDR = 3'b011;
  const logic [2:0] RX_LEN_ADDR = 3'b100;
  const logic [2:0] RXSC = 3'b010;

  /****************************************************************************
   *                                                                          *
   *                               Student code                               *
   *                                                                          *
   ****************************************************************************/

  `include "hdlc_shared.sv"

  // VerifyAbortReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer is zero after abort.
  task VerifyAbortReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;

    //Verify status register bits
    ReadAddress(Rx_SC, ReadData);
    // INSERT CODE HERE
    assert (ReadData[Rx_Ready] == 1) begin
      $error("ABORT_RECEIVE: ERROR: Rx_ready should not be high");
      ++TbErrorCnt;
    end else
      $display("ABORT_RECEIVE:: SUCCESS: Rx_ready is low");

    assert (ReadData[Rx_FrameError] == 1) begin
      $error("ABORT_RECEIVE: ERROR: Rx_FrameError should not be high");
      ++TbErrorCnt;
    end else
      $display("ABORT_RECEIVE:: SUCCESS: Rx_FrameError is low");

    assert (ReadData[Rx_Overflow] == 1) begin
      $error("ABORT_RECEIVE: ERROR: Rx_Overflow should not be high");
      ++TbErrorCnt;
    end else
      $display("ABORT_RECEIVE:: SUCCESS: Rx_Overflow is low");

    assert (ReadData[Rx_AbortSignal] == 1)
      $display("ABORT_RECEIVE:: SUCCESS: Rx_FrameError is low");
    else begin
      $error("ABORT_RECEIVE: ERROR: Rx_AbortSignal should not be low");
      ++TbErrorCnt;
    end
    
     // Verify all bytes from the Rx_Buff are zero
     for (int i = 0; i < Size; i++) begin
        ReadAddress(RX_BUFFER_ADDR, ReadData);
        assert (ReadData == 0)
            // $display("SUCCESS: Rx_Buff is empty: ReadData = %0h", ReadData);
        else begin
            $error("ERROR: Rx_Buff is not empty: ReadData = %0h", ReadData);
            ++TbErrorCnt;
        end
    end

  endtask

  // VerifyNormalReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer contains correct data.
  task VerifyNormalReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    wait(uin_hdlc.Rx_Ready);
    //Verify status register bits
    ReadAddress(Rx_SC, ReadData);

    // INSERT CODE HERE
    assert (ReadData[Rx_Overflow] == 1) begin
      $error("NORMAL RECEIVE:: ERROR: x OVERFLOW DETECTED!\n");
      ++TbErrorCnt;
    end else
      $display("NORMAL RECEIVE: SUCCESS: No Rx overflow detected\n");

    assert (ReadData[Rx_AbortSignal] == 1) begin
      $error("NORMAL RECEIVE:: ERROR: Rx ABORT DETECTED!\n");
      ++TbErrorCnt;
    end else
      $display("NORMAL RECEIVE:: SUCCESS: No Rx abort detected\n");

    assert (ReadData[Rx_FrameError] == 1) begin
      $error("NORMAL RECEIVE:: ERROR: INVALID Rx FRAME DETECTED!\n");
      ++TbErrorCnt;
    end else 
      $display("NORMAL RECEIVE:: SUCCESS: FRAME IS VALID\n");

    assert (ReadData[Rx_Ready] == 1)
      $display("NORMAL RECEIVE:: SUCCESS: Rx BUFFER IS READY\n");
    else begin
      $error("NORMAL RECEIVE:: ERROR: Rx BUFFER NOT READY\n");
      ++TbErrorCnt;
    end

    // Verify all bytes from the Rx_Buff
    for (int i = 0; i < Size; i++) begin
        ReadAddress(RX_BUFFER_ADDR, ReadData);
        assert (data[i] == ReadData)
            // $display("Rx_Buff has correct data at index %0d: data[%0d] = %0h, ReadData = %0h", 
                      // i, i, data[i], ReadData);
        else begin
            $error("DATA ERROR: Mismatch at index %0d: data[%0d] = %0h, ReadData = %0h", 
                    i, i, data[i], ReadData);
                    ++TbErrorCnt;
        end
    end
  
  endtask

  // VerifyOverflowReceive should verify that the Rx_Overflow bit is high when more than
  // 128 bytes have been received.
  task VerifyOverflowReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    
    wait(uin_hdlc.Rx_Ready);
     // Verify status register bits
    ReadAddress(Rx_SC, ReadData);

    // INSERT CODE HERE
    assert (ReadData[Rx_Ready] == 1)
      $display("OVERFLOW_RECEIVE:: SUCCESS: Rx_ready is high");
    else begin
      $error("OVERFLOW_RECEIVE:: ERROR: Rx_ready should not be low");
      ++TbErrorCnt;
    end

    assert (ReadData[Rx_FrameError] == 1) begin
      $error("OVERFLOW_RECEIVE: ERROR: Rx_FrameError should not be high");
      ++TbErrorCnt;
    end else
      $display("OVERFLOW_RECEIVE:: SUCCESS: Rx_FrameError is low");

    assert (ReadData[Rx_Overflow] == 1)
      $display("OVERFLOW_RECEIVE:: SUCCESS: Rx_Overflow is high");
    else begin
      $error("OVERFLOW_RECEIVE:: ERROR: Rx_Overflow is low");
      ++TbErrorCnt;
    end

    assert (ReadData[Rx_AbortSignal] == 1) begin
      $error("OVERFLOW_RECEIVE:: ERROR: Rx_AbortSignal should not be low");
      ++TbErrorCnt;
    end else
      $display("OVERFLOW_RECEIVE: SUCCESS: Rx_AbortSignal is low");

    // Verify all bytes from the Rx_Buff
    for (int i = 0; i < Size; i++) begin
        ReadAddress(RX_BUFFER_ADDR, ReadData);
        assert (data[i] == ReadData)
            // $display("Rx_Buff has correct data at index %0d: data[%0d] = %0h, ReadData = %0h", 
                      // i, i, data[i], ReadData);
        else begin
            $error("DATA ERROR: Mismatch at index %0d: data[%0d] = %0h, ReadData = %0h", 
                    i, i, data[i], ReadData);
                    ++TbErrorCnt;
        end
    end
  
  endtask

  // VerifyErrorReceive checks that a Rx_FrameError is generated if Non-byte aligned data
  // or error in FCS checking is detected. (Spec 16)
  task VerifyErrorReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;

    // Verify status register bits
    ReadAddress(Rx_SC, ReadData);

    assert (ReadData[Rx_Ready] == 0)
      $display("ERROR_RECEIVE:: SUCCESS: Rx_Ready is low after error");  
    else begin
      $error("ERROR_RECEIVE:: ERROR: Rx_Ready is high after error");
      ++TbErrorCnt;
    end

    assert (ReadData[Rx_FrameError] == 1)
      $display("ERROR_RECEIVE:: SUCCESS: Rx_FrameError is high after error");
    else begin
      $error("ERROR_RECEIVE:: ERROR: Rx_FrameError is low after error");
      ++TbErrorCnt;
    end

    assert (ReadData[Rx_Overflow] == 0)
      $display("ERROR_RECEIVE:: SUCCESS: Rx_Overflow is low after error");
    else begin
      $error("ERROR_RECEIVE:: ERROR: Rx_Overflow is high after error");
      ++TbErrorCnt;
    end
    assert (ReadData[Rx_AbortSignal] == 0)
      $display("ERROR_RECEIVE:: SUCCESS: Rx_AbortSignal is low after error");
    else begin
      $error("ERROR_RECEIVE:: ERROR: Rx_AbortSignal is high after error");
      ++TbErrorCnt;
    end

    assert (ReadData[Rx_Drop] == 0)
      $display("ERROR_RECEIVE:: SUCCESS: Rx_Drop is low after error");
    else begin
      $error("ERROR_RECEIVE:: ERROR: Rx_Drop is high after error");
      ++TbErrorCnt;
    end
    
     // Verify all bytes from the Rx_Buff are zero
     for (int i = 0; i < Size; i++) begin
        ReadAddress(RX_BUFFER_ADDR, ReadData);
        assert (ReadData == 0)
            // $display("ERROR_RECEIVE:: SUCCESS: Rx_Buff is empty: ReadData = %0h", ReadData);
        else begin
            $error("ERROR_RECEIVE:: ERROR: Rx_Buff is not empty: ReadData = %0h", ReadData);
            ++TbErrorCnt;
        end
    end
  endtask

  task VerifyDropReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    // Verify status register bits
    ReadAddress(Rx_SC, ReadData);
    //Check all flags
    assert (ReadData[Rx_Ready] == 0)
      $display("DROP_RECEIVE:: SUCCESS: Rx_Ready is low after dropped frame");
    else begin
      $error("DROP_RECEIVE:: ERROR: Rx_Ready is high after dropped frame");
      ++TbErrorCnt;
    end

    assert (ReadData[Rx_FrameError] == 0)
      $display("DROP_RECEIVE:: SUCCESS: Rx_FrameError is low after dropped frame");
    else begin
      $error("DROP_RECEIVE:: ERROR: Rx_FrameError is high after dropped frame");
      ++TbErrorCnt;
    end

    assert (ReadData[Rx_Overflow] == 0)
      $display("DROP_RECEIVE:: SUCCESS: Rx_Overflow is low after dropped frame");
    else begin
      $error("DROP_RECEIVE:: ERROR: Rx_Overflow is high after dropped frame");
      ++TbErrorCnt;
    end

    assert (ReadData[Rx_AbortSignal] == 0)
      $display("DROP_RECEIVE:: SUCCESS: Rx_AbortSignal is low after dropped frame");
    else begin
      $error("DROP_RECEIVE:: ERROR: Rx_AbortSignal is high after dropped frame");
      ++TbErrorCnt;
    end

    // Verify all bytes from the Rx_Buff are zero
     for (int i = 0; i < Size; i++) begin
        ReadAddress(RX_BUFFER_ADDR, ReadData);
        assert (ReadData == 0)
            // $display("DROP_RECEIVE:: SUCCESS: Rx_Buff is empty: ReadData = %0h", ReadData);
        else begin
            $error("DROP_RECEIVE:: ERROR: Rx_Buff is not empty: ReadData = %0h", ReadData);
            ++TbErrorCnt;
        end
    end

  endtask

  // Spec 14
  task VerifyRxFrameSize(int Size);
    logic [7:0] ReadData;

    ReadAddress(RX_LEN_ADDR, ReadData);

    assert (ReadData == Size)
      $display("VerifyRxFrameSize:: SUCCESS: Rx_FrameLength matches received framelength");
    else begin
      $error("VerifyRxFrameSize:: ERROR: Rx_Framelength MISMATCH. Received: %0d, Expected: %0d", ReadData, Size);
      ++TbErrorCnt;
    end
  endtask

  task VerifyNormalTransmit(logic [125:0][7:0] TransmitData, logic [129:0][7:0] txFrame, int Size);
    logic [127:0][7:0] CRCdata;
    logic [15:0]       CRCbytes;
    logic [7:0]        TxStatus;

    //Verify startFlag
    assert(txFrame[0] == FRAME_FLAG)
      $display("PASS: startFlag transmitted");
      else begin
        $error("FAIL: startFlag not transmitted");
        ++TbErrorCnt;
      end

    //Verify endFlag
    assert(txFrame[Size+3] == FRAME_FLAG)
      $display("PASS: endFlag transmitted");
      else begin
        $error("FAIL: endFlag not transmitted");
        ++TbErrorCnt;
      end

    //Verify data
    for(int i = 0; i < Size; i++) begin
      assert(TransmitData[i] == txFrame[i+1])
        $display("VERIFY_TRANSMIT_NORMAL:: PASS: data transmitted correctly");
      else begin
        $error("VERIFY_TRANSMIT_NORMAL:: FAIL: data not transmitted correctly, buffData[%0d] = %0h, transData[%0d] = %0h", i, TransmitData[i], i, txFrame[i+1]);
        ++TbErrorCnt;
      end
    end

    //Verify FCS
    CRCdata[125:0] = TransmitData[125:0];
    CRCdata[Size] = '0;
    CRCdata[Size+1] = '0;
    //Find CRC
    GenerateFCSBytes(CRCdata, Size, CRCbytes);

    //Verify CRC bytes
    assert((txFrame[Size + 1] == CRCbytes[7:0]) && (txFrame[Size + 2] == CRCbytes[15:8]) )
      $display("VERIFY_TRANSMIT_NORMAL:: PASS: FCS transmitted correctly");
      else begin
        $error("VERIFY_TRANSMIT_NORMAL:: FAIL: FCS not transmitted correctly, got %0h, expected %0h", txFrame[Size + 1], CRCdata[7:0]);
        ++TbErrorCnt;
      end

    //Check status registers
    ReadAddress(Tx_SC, TxStatus);

    assert(TxStatus[Tx_Done] == 1)
      $display("VERIFY_TRANSMIT_NORMAL:: PASS: Tx_Done is high");
    else begin
      $error("VERIFY_TRANSMIT_NORMAL:: FAIL: Tx_Done is low");
      ++TbErrorCnt;
    end

    assert(TxStatus[Tx_AbortFrame] == 0 )
      $display("VERIFY_TRANSMIT_NORMAL:: PASS: Tx_AbortFrame is low");
    else begin
      $error("VERIFY_TRANSMIT_NORMAL:: FAIL: Tx_AbortFrame is high");
      ++TbErrorCnt;
    end

    assert(TxStatus[Tx_Full] == 0 )
      $display("VERIFY_TRANSMIT_NORMAL:: PASS: Tx_Full is low");
    else begin
      $error("VERIFY_TRANSMIT_NORMAL:: FAIL: Tx_Full is high");
      ++TbErrorCnt;
    end
    
  endtask

  task VerifyTransmitOverflow(logic [125:0][7:0] TransmitData, logic [129:0][7:0] txFrame, int Size);
  logic [7:0] TxStatus;
   //Check status registers
   ReadAddress(Tx_SC, TxStatus);
   //Check if Tx_Full is high
   assert(TxStatus[Tx_Full] == 1)
    $display("VERIFY_OVERFLOW_TRANSMIT:: PASS: Tx_Full is high");
   else begin
    $error("VERIFY_OVERFLOW_TRANSMIT:: FAIL: Tx_Full is low");
    ++TbErrorCnt;
   end

   //Check if Tx_Done is low
   assert(TxStatus[Tx_Done] == 0)
    $display("VERIFY_OVERFLOW_TRANSMIT:: PASS: Tx_Done is low");
   else begin
    $error("VERIFY_OVERFLOW_TRANSMIT:: FAIL: Tx_Done is high");
    ++TbErrorCnt;
   end

   //Check if Tx_AbortFrame is low
   assert(TxStatus[Tx_AbortFrame] == 0)
    $display("VERIFY_OVERFLOW_TRANSMIT:: PASS: Tx_AbortFrame is low");
   else begin
    $error("VERIFY_OVERFLOW_TRANSMIT:: FAIL: Tx_AbortFrame is high");
    ++TbErrorCnt;
   end
   
  endtask
  /****************************************************************************
   *                                                                          *
   *                             Simulation code                              *
   *                                                                          *
   ****************************************************************************/

  initial begin
    $display("*************************************************************");
    $display("%t - Starting Test Program", $time);
    $display("*************************************************************");

    Init();

    //Receive: Size, Abort, FCSerr, NonByteAligned, Overflow, Drop, SkipRead
    Receive( 10, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 40, 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive( 45, 0, 0, 0, 0, 0, 0); //Normal
    Receive(126, 0, 0, 0, 0, 0, 0); //Normal
    Receive(122, 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow (126 data bytes + 2 bytes for FCS + overflow bytes )
    Receive( 25, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 47, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 42, 0, 0, 0, 0, 1, 0); //FrameDropped
    Receive( 14, 0, 0, 0, 0, 0, 0); //Normal
    Receive( 14, 0, 0, 1, 0, 0, 0); //Non-byte Aligned Data
    Receive( 14, 0, 1, 0, 0, 0, 0); //FCS Checking error

    Transmit(10, 0, 0);//Normal
    Transmit(10, 0, 1);//Overflow

    $display("*************************************************************");
    $display("%t - Finishing Test Program", $time);
    $display("*************************************************************");
    $stop;
  end

  final begin

    $display("*********************************");
    $display("*                               *");
    $display("* \tAssertion Errors: %0d\t  *", TbErrorCnt + uin_hdlc.ErrCntAssertions);
    $display("*                               *");
    $display("*********************************");

  end

  task Init();
    uin_hdlc.Clk         =   1'b0;
    uin_hdlc.Rst         =   1'b0;
    uin_hdlc.Address     = 3'b000;
    uin_hdlc.WriteEnable =   1'b0;
    uin_hdlc.ReadEnable  =   1'b0;
    uin_hdlc.DataIn      =     '0;
    uin_hdlc.TxEN        =   1'b1;
    uin_hdlc.Rx          =   1'b1;
    uin_hdlc.RxEN        =   1'b1;

    TbErrorCnt = 0;

    #1000ns;
    uin_hdlc.Rst         =   1'b1;
  endtask

  task WriteAddress(input logic [2:0] Address ,input logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address     = Address;
    uin_hdlc.WriteEnable = 1'b1;
    uin_hdlc.DataIn      = Data;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.WriteEnable = 1'b0;
  endtask

  task ReadAddress(input logic [2:0] Address ,output logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address    = Address;
    uin_hdlc.ReadEnable = 1'b1;
    #100ns;
    Data                = uin_hdlc.DataOut;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.ReadEnable = 1'b0;
  endtask

  task InsertFlagOrAbort(int flag);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b0;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    if(flag)
      uin_hdlc.Rx = 1'b0;
    else
      uin_hdlc.Rx = 1'b1;
  endtask

  task MakeRxStimulus(logic [127:0][7:0] Data, int Size);
    logic [4:0] PrevData;
    PrevData = '0;
    for (int i = 0; i < Size; i++) begin
      for (int j = 0; j < 8; j++) begin
        if(&PrevData) begin
          @(posedge uin_hdlc.Clk);
          uin_hdlc.Rx = 1'b0;
          PrevData = PrevData >> 1;
          PrevData[4] = 1'b0;
        end

        @(posedge uin_hdlc.Clk);
        uin_hdlc.Rx = Data[i][j];

        PrevData = PrevData >> 1;
        PrevData[4] = Data[i][j];
      end
    end
  endtask

 task Receive(int Size, int Abort, int FCSerr, int NonByteAligned, int Overflow, int Drop, int SkipRead);
    logic [127:0][7:0] ReceiveData;
    logic       [15:0] FCSBytes;
    logic   [2:0][7:0] OverflowData;
    string msg;
    if(Abort)
      msg = "- Abort";
    else if(FCSerr)
      msg = "- FCS error";
    else if(NonByteAligned)
      msg = "- Non-byte aligned";
    else if(Overflow)
      msg = "- Overflow";
    else if(Drop)
      msg = "- Drop";
    else if(SkipRead)
      msg = "- Skip read";
    else
      msg = "- Normal";
    $display("*************************************************************");
    $display("%t - Starting task Receive %s", $time, msg);
    $display("*************************************************************");

    for (int i = 0; i < Size; i++) begin
      ReceiveData[i] = $urandom;
    end
    ReceiveData[Size]   = '0;
    ReceiveData[Size+1] = '0;

    //Calculate FCS bits;
    GenerateFCSBytes(ReceiveData, Size, FCSBytes);
    ReceiveData[Size]   = FCSBytes[7:0];
    ReceiveData[Size+1] = FCSBytes[15:8];

    //Enable FCS
    if(!Overflow && !NonByteAligned)
      WriteAddress(RXSC, 8'h20);
    else
      WriteAddress(RXSC, 8'h00);

     if(FCSerr) begin
      ReceiveData[Size-1] -= 1;
    end


    //Generate stimulus
    InsertFlagOrAbort(1);
    
    MakeRxStimulus(ReceiveData, Size + 2);
    
    if(Overflow) begin
      OverflowData[0] = 8'h44;
      OverflowData[1] = 8'hBB;
      OverflowData[2] = 8'hCC;
      MakeRxStimulus(OverflowData, 3);
    end

    if (NonByteAligned) begin
      @(posedge uin_hdlc.Clk);
      uin_hdlc.Rx = 0;
    end

    if(Abort) begin
      InsertFlagOrAbort(0);
    end else begin
      InsertFlagOrAbort(1);
    end

    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;

    repeat(8)
      @(posedge uin_hdlc.Clk);

    if(Drop) begin 
      WriteAddress(Rx_SC, 8'b1 << Rx_Drop);
    end
    
    if(!SkipRead && !Abort && !FCSerr && !NonByteAligned && !Drop)
      VerifyRxFrameSize(Size);  // Verify that Rx_len matches received number of bytes when Rx_Ready is high  

    if(Abort)
      VerifyAbortReceive(ReceiveData, Size);
    else if(Overflow)
      VerifyOverflowReceive(ReceiveData, Size);
    else if(Drop)
      VerifyDropReceive(ReceiveData, Size);
    else if(FCSerr || NonByteAligned)
      VerifyErrorReceive(ReceiveData, Size);
    else if(!SkipRead)
      VerifyNormalReceive(ReceiveData, Size);

    #5000ns;
  endtask

// Parses the incomming transmission into databytes and 
// removes transmission padding if 5 consequtive 1-bits are detected.
// Returns the parsed data buffer
 task automatic ParseTransmittedData(
    output logic [129:0][7:0] txData,
    input  int               frameSize
);
    int consequtiveOnes; // Dont init to prevent implicit static behaviour
    int byteIndex; // Dont init to prevent implicit static behaviour
    const int totalFrameBytes = frameSize + FLAG_AND_FCS_BYTES;

    consequtiveOnes = 0; 
    byteIndex = 0;

    do begin
      for (int bitIndex = 0; bitIndex < 8; bitIndex++) begin
        if (uin_hdlc.Tx == '0 && consequtiveOnes == 5) begin // Check for padded zeros
          consequtiveOnes = 0;
          bitIndex -= 1;            // Remove padded bit
        end else begin
          if (uin_hdlc.Tx == '1) ++consequtiveOnes;
          else consequtiveOnes = 0;
        
          txData[byteIndex][bitIndex] = uin_hdlc.Tx; // Save databit in data buffer
        end

        @(posedge uin_hdlc.Clk);  // Latch next bit

      end

      ++byteIndex;
    end while (byteIndex < totalFrameBytes);
endtask


  //-----------------------------------------------------------------------------
  // Transmit:
  //   - pushes Size bytes into the DUT’s Tx_Buff
  //   - kicks off the transfer
  //   - parses the transmitted data in ParseTransmittedData
  //   - hands over the parsed data to the assertions
  //-----------------------------------------------------------------------------
  task Transmit(
    int Size,
    int Abort,
    int Overflow
  );
    logic [125:0][7:0] TransmitData;
    logic [7:0]       TxStatus;
    logic [129:0][7:0] txFrame;
    int                frameLen;

    string             msg;
    if(Abort)
      msg = "- Abort";
    else if(Overflow)
      msg = "- Overflow";
    else
      msg = "- Normal";

    $display("*************************************************************");
    $display("%t - Starting task Transmit %s", $time, msg);
    $display("*************************************************************");
    $display("=== Transmit %0s (%0d bytes) ===", msg, Size);

    // Wait for tx ready (Tx_done low)
    do begin 
      ReadAddress(Tx_SC, TxStatus);
    end while (!TxStatus[Tx_Done]);

     // Write random data to Tx_buffer

    if(!Overflow) begin
      for (int i = 0; i < Size; i++) begin
        TransmitData[i] = $urandom;
        WriteAddress(Tx_Buff, TransmitData[i]);
      end
    end
    else begin
      $display("Overflowing buffer ...");
       //Write random data until we have overflowed
      for (int i = 0; i < BUFFER_CAPACITY + 1;i++) begin
        WriteAddress(Tx_Buff, $urandom);
      end
      VerifyTransmitOverflow(TransmitData, txFrame, Size);
    end
    
    WriteAddress(Tx_SC, 8'b1 << Tx_Enable); // Start transmission
    wait (!uin_hdlc.Tx);  // CRC calculation need to finish

    if (Abort) begin
      // let it send a few bits, then abort
      repeat(16) @(posedge uin_hdlc.Clk);
      WriteAddress(Tx_SC, 8'b1 << Tx_AbortFrame);
    end

    ParseTransmittedData(txFrame, Size);

    // Wait for the frame to be transmitted
    repeat(16)
      @(posedge uin_hdlc.Clk);
    // only capture & verify in the “normal” case
    if (!Abort && !Overflow) begin
      // hand off to your checker exactly as before
      $display("Start verify transmit normal");
      VerifyNormalTransmit(TransmitData, txFrame, Size);
      $display("End verify transmit normal");
    end
    #10000ns;
  endtask

  task GenerateFCSBytes(logic [127:0][7:0] data, int size, output logic[15:0] FCSBytes);
    logic [23:0] CheckReg;
    CheckReg[15:8]  = data[1];
    CheckReg[7:0]   = data[0];
    for(int i = 2; i < size+2; i++) begin
      CheckReg[23:16] = data[i];
      for(int j = 0; j < 8; j++) begin
        if(CheckReg[0]) begin
          CheckReg[0]    = CheckReg[0] ^ 1;
          CheckReg[1]    = CheckReg[1] ^ 1;
          CheckReg[13:2] = CheckReg[13:2];
          CheckReg[14]   = CheckReg[14] ^ 1;
          CheckReg[15]   = CheckReg[15];
          CheckReg[16]   = CheckReg[16] ^1;
        end
        CheckReg = CheckReg >> 1;
      end
    end
    FCSBytes = CheckReg;
  endtask

endprogram
