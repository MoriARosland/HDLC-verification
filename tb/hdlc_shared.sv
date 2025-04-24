enum logic[2:0] {
  Tx_SC,
  Tx_Buff,
  Rx_SC,
  Rx_Buff,
  Rx_Len
} RegAddr;

enum int {        
  Rx_Ready,
  Rx_Drop,
  Rx_FrameError,
  Rx_AbortSignal,
  Rx_Overflow,
  Rx_FCSen
} RxSC_bits;

enum int {        
  Tx_Done,
  Tx_Enable,
  Tx_AbortFrame,
  Tx_AbortedTrans,
  Tx_Full
} TxSC_bits;

const logic [7:0] FRAME_FLAG = 8'b01111110;
const int BUFFER_CAPACITY = 128;
const int FLAG_AND_FCS_BYTES = 4; // 2 Flag bytes + 2 FCS bytes

/*********************************
 * Status register test patterns *
 *********************************/

typedef struct {
    bit [2:0] bit_pos;
    logic expected;
    string pass_msg;
    string fail_msg;
} status_bit_check_t;

// Constant array for VerifyAbortReceive
const status_bit_check_t ABORT_RECEIVE_CHECKS[] = '{
    '{Rx_Ready, 0, "Rx_ready is low", "Rx_ready should be low"},
    '{Rx_FrameError, 0, "Rx_FrameError is low", "Rx_FrameError should be low"},
    '{Rx_Overflow, 0, "Rx_Overflow is low", "Rx_Overflow should be low"},
    '{Rx_AbortSignal, 1, "Rx_AbortSignal is high", "Rx_AbortSignal is not high"}
};

// Constant array for VerifyNormalReceive
const status_bit_check_t NORMAL_RECEIVE_CHECKS[] = '{
    '{Rx_Ready, 1, "Rx_ready is high", "Rx_ready should be high"},
    '{Rx_FrameError, 0, "Rx_FrameError is low", "Rx_FrameError should be low"},
    '{Rx_Overflow, 0, "Rx_Overflow is low", "Rx_Overflow should be low"},
    '{Rx_AbortSignal, 0, "Rx_AbortSignal is low", "Rx_AbortSignal should not be high"}
};

// Constant array for VerifyOverflowReceive
const status_bit_check_t OVERFLOW_RECEIVE_CHECKS[] = '{
    '{Rx_Ready, 1, "Rx_Buff has data to read", "Rx_Ready not set in Rx_SC"},
    '{Rx_FrameError, 0, "No frame error", "Rx_FrameError asserted in Rx_SC"},
    '{Rx_Overflow, 1, "Overflow signal asserted", "Rx_Overflow not asserted in Rx_SC"},
    '{Rx_AbortSignal, 0, "No abort signal", "Rx_AbortSignal asserted in Rx_SC"}
};

// Constant array for VerifyErrorReceive
const status_bit_check_t ERROR_RECEIVE_CHECKS[] = '{
    '{Rx_Ready, 0, "Rx_Ready is low after error", "Rx_Ready is high after error"},
    '{Rx_FrameError, 1, "Rx_FrameError is high after error", "Rx_FrameError is low after error"},
    '{Rx_Overflow, 0, "Rx_Overflow is low after error", "Rx_Overflow is high after error"},
    '{Rx_AbortSignal, 0, "Rx_AbortSignal is low after error", "Rx_AbortSignal is high after error"}
};

// Constant array for VerifyDropReceive
const status_bit_check_t DROP_RECEIVE_CHECKS[] = '{
    '{Rx_Ready, 0, "Rx_Ready is low after dropped frame", "x_Ready is high after dropped frame"},
    '{Rx_FrameError, 0, "Rx_FrameError is low after dropped frame", "Rx_FrameError is high after dropped frame"},
    '{Rx_Overflow, 0, "Rx_Overflow is low after dropped frame", "Rx_Overflow is high after dropped frame"},
    '{Rx_AbortSignal, 0, "Rx_AbortSignal is low after dropped frame", "Rx_AbortSignal is high after dropped frame"}
};
