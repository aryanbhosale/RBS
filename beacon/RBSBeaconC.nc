#include "rbs_msg.h"
#include <stdint.h>
#include <TinyError.h>

module RBSBeaconC {
  uses {
    interface Boot;
    interface Timer<TMilli> as BeaconTimer;
    interface AMSend;
    interface LocalTime<TMilli>;
    interface Leds;
  }
}
implementation {
  static message_t beaconMsg;

  event void Boot.booted() {
    call Leds.led0On();
    call BeaconTimer.startPeriodic(1000);
  }

  event void BeaconTimer.fired() {
    error_t err;
    rbs_msg* rmsg = call AMSend.getPayload(&beaconMsg, sizeof(rbs_msg));
    if (rmsg == NULL) {
      return;
    }
    
    rmsg->timestamp = call LocalTime.get();
    
    err = call AMSend.send(AM_BROADCAST_ADDR, &beaconMsg, sizeof(rbs_msg));
    if (err == SUCCESS) {
      call Leds.led1Toggle();
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    // Optional: handle send completion.
  }
}
