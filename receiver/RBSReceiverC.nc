#include <message.h>
#include <AM.h>
#include <stdint.h>
#include <TinyError.h>
#include "rbs_msg.h"

module RBSReceiverC {
  uses {
    interface Boot;
    interface Receive;
    interface LocalTime<TMilli>;
    interface Leds;
    interface AMSend; // added for sending debug packets with diff
  }
}
implementation {
  static message_t debugMsg;

  event void Boot.booted() {
    call Leds.led0On();
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    error_t err;
    rbs_msg* dbgMsg;
    rbs_msg* rmsg = (rbs_msg*)payload;
    uint32_t now = call LocalTime.get();
    uint32_t diff = now - rmsg->timestamp;
    
    dbg("RBSReceiverC", "Diff: %lu\n", diff);
    
    // Create a new debug packet embedding the computed diff:
    dbgMsg = call AMSend.getPayload(&debugMsg, sizeof(rbs_msg));
    if (dbgMsg != NULL) {
       dbgMsg->timestamp = rmsg->timestamp;
       dbgMsg->diff = diff;
       err = call AMSend.send(AM_BROADCAST_ADDR, &debugMsg, sizeof(rbs_msg));
       if (err == SUCCESS) {
         call Leds.led1Toggle();
       }
    }
    
    return msg;
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    // Optional: handle the debug message send completion.
  }
}
