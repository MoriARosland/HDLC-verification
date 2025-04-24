//////////////////////////////////////////////////
// Title:   bind_hdlc
// Author:  Karianne Krokan Kragseth
// Date:    20.10.2017
//////////////////////////////////////////////////

module bind_hdlc ();

  bind test_hdlc assertions_hdlc u_assertion_bind(
    .ErrCntAssertions (uin_hdlc.ErrCntAssertions),
    .Clk              (uin_hdlc.Clk),
    .Rst              (uin_hdlc.Rst),
    .Rx               (uin_hdlc.Rx),
    .Rx_FlagDetect    (uin_hdlc.Rx_FlagDetect),
    .Rx_ValidFrame    (uin_hdlc.Rx_ValidFrame),
    .Rx_AbortDetect   (uin_hdlc.Rx_AbortDetect),
    .Rx_AbortSignal   (uin_hdlc.Rx_AbortSignal),
    .Rx_Overflow      (uin_hdlc.Rx_Overflow),
    .Rx_WrBuff        (uin_hdlc.Rx_WrBuff),
    .Rx_EoF           (uin_hdlc.Rx_EoF),
    .Tx               (uin_hdlc.Tx),
    .Tx_AbortFrame    (uin_hdlc.Tx_AbortFrame),
    .Tx_AbortedTrans  (uin_hdlc.Tx_AbortedTrans),
    .Tx_ValidFrame    (uin_hdlc.Tx_ValidFrame),
    .Tx_Enable        (uin_hdlc.Tx_Enable),
    .Tx_FrameSize     (uin_hdlc.Tx_FrameSize),
    .Tx_BufferCount   (uin_hdlc.Tx_BufferCount),
    .Tx_Done          (uin_hdlc.Tx_Done)
  );

endmodule
