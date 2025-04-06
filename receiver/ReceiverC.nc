#include "RBS.h"

module ReceiverC {
  uses interface Boot;
  uses interface SplitControl as AMControl;
  uses interface Receive;
  uses interface LocalTime<T32khz> as LocalTime;
}
implementation {
  // Circular buffer for recent offset values (differences between local and beacon time)
  enum { MAX_HISTORY = 10 };
  static int32_t offsetHistory[MAX_HISTORY];
  static uint8_t histCount = 0;
  static uint8_t histIndex = 0;
  static int32_t offsetSum = 0;

  event void Boot.booted() {
    // Start the radio to begin receiving beacon broadcasts
    call AMControl.start();
  }

  event void AMControl.startDone(error_t error) {
    if (error != SUCCESS) {
      dbg("RBS", "Receiver: Radio start failed (error %hhu).\n", error);
      return;
    }
    dbg("RBS", "Receiver: Radio started, waiting for beacon messages.\n");
    // Radio is now on and ready to receive broadcasts
  }

  event void AMControl.stopDone(error_t error) {
    // Not used in this application
  }

  event message_t* Receive.receive(message_t *msgPtr, void *payload, uint8_t len) {
    if (len < sizeof(RBSMsg_t)) {
      // Ignore messages too short to contain a valid RBS timestamp
      return msgPtr;
    }
    // Extract the beacon's timestamp from the received message (network to host endian conversion)
    RBSMsg_t *rcvPayload = (RBSMsg_t*) payload;
    uint32_t beaconTime = nx_ntoh_uint32(rcvPayload->beacon_timestamp.nxdata);
    // Capture the local arrival time
    uint32_t localTime = call LocalTime.get();
    // Compute the offset (local time minus beacon time)
    int32_t offset = (int32_t)((int64_t)localTime - (int64_t)beaconTime);
    // Update the history buffer and running sum of offsets
    if (histCount == MAX_HISTORY) {
      // Buffer full: remove oldest offset from sum (to be overwritten)
      offsetSum -= offsetHistory[histIndex];
    }
    // Store the new offset in the history buffer
    offsetHistory[histIndex] = offset;
    offsetSum += offset;
    if (histCount < MAX_HISTORY) {
      histCount++;  // grow buffer until full
    }
    // Advance index (wrap around circular buffer)
    histIndex = (histIndex + 1) % MAX_HISTORY;
    // Compute average offset from history
    int32_t avgOffset = offsetSum / histCount;
    dbg("RBS", "Receiver: average offset = %ld ticks\n", (long)avgOffset);
    return msgPtr;
  }
}
