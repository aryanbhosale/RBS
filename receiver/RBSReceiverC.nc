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
  }
}
implementation {

  event void Boot.booted() {
    call Leds.led0On();
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    rbs_msg* rmsg = (rbs_msg*)payload;
    uint32_t now = call LocalTime.get();
    uint32_t diff = now - rmsg->timestamp;
    
    dbg("RBSReceiverC", "Diff: %lu\n", diff);
    call Leds.led1Toggle();
    
    return msg;
  }
}
