#include <message.h>
#include <AM.h>
#include "rbs_msg.h"
#include <stdint.h>
#include <TinyError.h>

configuration RBSReceiverAppC { }
implementation {
  components MainC, RBSReceiverC, LedsC, LocalTimeMilliC, ActiveMessageC, new AMSenderC(AM_RBS_MSG);
  
  RBSReceiverC.Boot -> MainC.Boot;
  RBSReceiverC.Leds -> LedsC;
  RBSReceiverC.LocalTime -> LocalTimeMilliC;
  RBSReceiverC.Receive -> ActiveMessageC.Receive[AM_RBS_MSG];
  RBSReceiverC.AMSend -> AMSenderC;
}
