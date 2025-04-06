#include "RBS.h"

module BeaconC {
  uses interface Boot;
  uses interface SplitControl as AMControl;
  uses interface AMSend;
  uses interface Packet;
  uses interface Timer<TMilli> as BeaconTimer;
  // Use the TMilli time interface for consistency:
  uses interface LocalTime<TMilli> as LocalTime;
}
implementation {
  bool locked = FALSE;                  // Prevent overlapping sends
  static message_t beaconMsg;           // Buffer for broadcast messages
  static RBSMsg_t *beaconPayload;       // Pointer to the payload within beaconMsg

  event void Boot.booted() {
    // Get the pointer to the message payload.
    beaconPayload = (RBSMsg_t*) call Packet.getPayload(&beaconMsg, sizeof(RBSMsg_t));
    if (beaconPayload == NULL) {
      dbg("RBS", "Beacon: Packet payload too small, aborting.\n");
      return;
    }
    // Start the radio.
    call AMControl.start();
  }

  event void AMControl.startDone(error_t error) {
    if (error != SUCCESS) {
      dbg("RBS", "Beacon: Radio start failed (error %hhu).\n", error);
      return;
    }
    dbg("RBS", "Beacon: Radio started, sending beacons every 1024 ms.\n");
    // Start periodic transmission (1024 ms period)
    call BeaconTimer.startPeriodic(1024);
  }

  event void AMControl.stopDone(error_t error) {
    // Not used.
  }

  event void BeaconTimer.fired() {
    uint32_t localTime;
    error_t result;
    if (locked) {
      dbg("RBS", "Beacon: Previous message still sending, skip this beacon.\n");
      return;
    }
    // Get current local time (in milliseconds)
    localTime = call LocalTime.get();
    // Directly assign the timestamp value (ensuring consistency)
    beaconPayload->beacon_timestamp = localTime;
    // Broadcast the message containing the reference timestamp.
    result = call AMSend.send(AM_BROADCAST_ADDR, &beaconMsg, sizeof(RBSMsg_t));
    if (result == SUCCESS) {
      locked = TRUE;
      dbg("RBS", "Beacon: Broadcasted reference time %lu ticks.\n", (unsigned long)localTime);
    } else {
      dbg("RBS", "Beacon: Send failed (error %hhu).\n", result);
    }
  }

  event void AMSend.sendDone(message_t *msgPtr, error_t error) {
    if (msgPtr == &beaconMsg) {
      // Unlock for the next transmission.
      locked = FALSE;
      if (error != SUCCESS) {
        dbg("RBS", "Beacon: Message send failed (error %hhu).\n", error);
      }
    }
  }
}
