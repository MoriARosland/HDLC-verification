`include "hdlc_shared.sv"

module hdlc_coverage (
    in_hdlc u_in_hdlc
);
    // Covergroup definition
    covergroup hdlc_cg @(posedge u_in_hdlc.Clk);
        // Cover frame size Rx
        Rx_FrameSizeBins : coverpoint u_in_hdlc.Rx_FrameSize {
            bins small_frame = {[3:15]};
            bins medium_frame = {[16:125]};
            bins max_size = {BUFFER_CAPACITY - 2}; // 126
            bins invalid_frame = default;
        }

        // Cover frame size Tx
        Tx_FrameSizeBins : coverpoint u_in_hdlc.Tx_FrameSize {
            bins small_frame = {[3:15]};
            bins medium_frame = {[16:125]};
            bins max_size = {BUFFER_CAPACITY - 2}; // 126
            bins invalid_frame = default;
        }

        // Check that Rx and Tx status bits have been toggled at least once
        // Rx status bits
        Cp_RxReady: coverpoint u_in_hdlc.Rx_Ready;
        Cp_RxFrameError: coverpoint u_in_hdlc.Rx_FrameError;
        Cp_RxAbortSignal: coverpoint u_in_hdlc.Rx_AbortSignal;

        // Tx status bits
        Cp_TxDone: coverpoint u_in_hdlc.Tx_Done;
        Cp_TxEnable: coverpoint u_in_hdlc.Tx_Enable;
        Cp_TxAbortedTrans: coverpoint u_in_hdlc.Tx_AbortedTrans;
        
        // Check for edge cases Overflow, AbortSignal, FrameError, Drop
        Cp_RxOverflow: coverpoint u_in_hdlc.Rx_Overflow;
        Cp_RxDrop: coverpoint u_in_hdlc.Rx_Drop;
        Cp_TxAbortFrame: coverpoint u_in_hdlc.Tx_AbortFrame;
        Cp_TxFull: coverpoint u_in_hdlc.Tx_Full;
    endgroup

    // Instantiate covergroup
    hdlc_cg hdlc_coverage_inst;
    initial begin
        hdlc_coverage_inst = new();
    end

endmodule