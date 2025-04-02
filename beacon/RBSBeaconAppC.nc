#include "rbs_msg.h"
#include <stdint.h>
#include <TinyError.h>

configuration RBSBeaconAppC { }
implementation {
  components MainC, RBSBeaconC, LedsC, new TimerMilliC() as Timer, LocalTimeMilliC, ActiveMessageC;

  RBSBeaconC.Boot -> MainC.Boot;
  RBSBeaconC.Leds -> LedsC;
  RBSBeaconC.BeaconTimer -> Timer;
  RBSBeaconC.LocalTime -> LocalTimeMilliC;
  RBSBeaconC.AMSend -> ActiveMessageC.AMSend[AM_RBS_MSG];
}
