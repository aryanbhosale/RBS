#include "RBS.h"
#include <AM.h>
#include <message.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

module ReceiverC {
  uses interface Boot;
  uses interface SplitControl as AMControl;
  uses interface Receive;
  uses interface LocalTime<TMilli> as LocalTime;  // Using millisecond local time
}
implementation {
  // Circular buffer for recent offset values (differences between local and beacon time)
  enum { MAX_HISTORY = 10 };
  static int32_t offsetHistory[MAX_HISTORY];
  static uint8_t histCount = 0;
  static uint8_t histIndex = 0;
  static int32_t offsetSum = 0;

  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t error) {
    if (error != SUCCESS) {
      dbg("RBS", "Receiver: Radio start failed (error %hhu).\n", error);
      return;
    }
    dbg("RBS", "Receiver: Radio started, waiting for beacon messages.\n");
  }

  event void AMControl.stopDone(error_t error) {
    // Not used
  }

  event message_t* Receive.receive(message_t *msgPtr, void *payload, uint8_t len) {
    RBSMsg_t *rcvPayload;
    uint32_t beaconTime;
    uint32_t localTime;
    int32_t offset;
    int32_t avgOffset;

    if (len < sizeof(RBSMsg_t)) {
      return msgPtr;
    }

    rcvPayload = (RBSMsg_t*) payload;
    // Since nx_uint32_t is defined as a plain uint32_t in your setup,
    // simply use its value directly:
    beaconTime = rcvPayload->beacon_timestamp;

    // Capture the local arrival time (in milliseconds)
    localTime = call LocalTime.get();

    // Compute the offset (local time minus beacon time)
    offset = (int32_t)((int64_t)localTime - (int64_t)beaconTime);

    // Update the history buffer and running sum of offsets
    if (histCount == MAX_HISTORY) {
      offsetSum -= offsetHistory[histIndex];
    }
    offsetHistory[histIndex] = offset;
    offsetSum += offset;
    if (histCount < MAX_HISTORY) {
      histCount++;
    }
    histIndex = (histIndex + 1) % MAX_HISTORY;
    avgOffset = (histCount > 0) ? (offsetSum / histCount) : 0;

    dbg("RBS", "Receiver: average offset = %ld ticks\n", (long)avgOffset);

    return msgPtr;
  }
}
