#include "RBS.h"

module BeaconC {
  uses interface Boot;
  uses interface SplitControl as AMControl;
  uses interface AMSend;
  uses interface Packet;
  uses interface Timer<TMilli> as BeaconTimer;
  uses interface LocalTime<T32khz> as LocalTime;
}
implementation {
  bool locked = FALSE;                  // Indicates if a send is in progress
  static message_t beaconMsg;           // Message buffer for broadcasts
  static RBSMsg_t *beaconPayload;       // Pointer to the payload within beaconMsg

  event void Boot.booted() {
    // Initialize payload pointer for the beacon message
    beaconPayload = (RBSMsg_t*) call Packet.getPayload(&beaconMsg, sizeof(RBSMsg_t));
    if (beaconPayload == NULL) {
      dbg("RBS", "Beacon: Packet payload too small, aborting.\n");
      return;
    }
    // Start the radio (will signal AMControl.startDone when complete)
    call AMControl.start();
  }

  event void AMControl.startDone(error_t error) {
    if (error != SUCCESS) {
      dbg("RBS", "Beacon: Radio start failed (error %hhu).\n", error);
      return;
    }
    // Radio is on – start periodic timer for beacon broadcasts (approximately 1 second interval)
    dbg("RBS", "Beacon: Radio started, sending beacons every 1024 ms.\n");
    call BeaconTimer.startPeriodic(1024);
  }

  event void AMControl.stopDone(error_t error) {
    // Not used in this application
  }

  event void BeaconTimer.fired() {
    if (locked) {
      // Skip this cycle if the previous message has not finished sending
      dbg("RBS", "Beacon: Previous message still sending, skip this beacon.\n");
      return;
    }
    // Get current local time and embed it into the beacon message
    uint32_t localTime = call LocalTime.get();
    nx_hton_uint32(beaconPayload->beacon_timestamp.nxdata, localTime);
    // Broadcast the message containing the reference timestamp
    error_t result = call AMSend.send(AM_BROADCAST_ADDR, &beaconMsg, sizeof(RBSMsg_t));
    if (result == SUCCESS) {
      locked = TRUE;
      dbg("RBS", "Beacon: Broadcasted reference time %lu ticks.\n", (unsigned long)localTime);
    } else {
      dbg("RBS", "Beacon: Send failed (error %hhu).\n", result);
    }
  }

  event void AMSend.sendDone(message_t *msgPtr, error_t error) {
    if (msgPtr == &beaconMsg) {
      // Transmission completed, unlock for the next send
      locked = FALSE;
      if (error != SUCCESS) {
        dbg("RBS", "Beacon: Message send failed (error %hhu).\n", error);
      }
    }
  }
}
