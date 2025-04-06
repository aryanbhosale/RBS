#include "RBS.h"

configuration BeaconAppC {}
implementation {
  components MainC, BeaconC as App;
  components ActiveMessageC;
  components new TimerMilliC();
  components LocalTimeMilliC;
  
  App.Boot -> MainC.Boot;
  App.AMControl -> ActiveMessageC;                      // Radio control (on/off)
  App.AMSend -> ActiveMessageC.AMSend[AM_RBS_MSG];        // Sending interface for RBS messages
  App.Packet -> ActiveMessageC.Packet;        // Packet utility (for getPayload)
  App.BeaconTimer -> TimerMilliC;                        // Millisecond timer for periodic beacons
  App.LocalTime -> LocalTimeMilliC;                      // Millisecond local time interface
}
