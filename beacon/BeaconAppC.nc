#include "RBS.h"

configuration BeaconAppC {}
implementation {
  components MainC, BeaconC as App;
  components ActiveMessageC;
  components new TimerMilliC();
  components LocalTimeC;
  
  App.Boot -> MainC.Boot;
  App.AMControl -> ActiveMessageC;                      // Radio control (on/off)
  App.AMSend -> ActiveMessageC.AMSend[AM_RBS_MSG];      // ActiveMessage sending interface for RBS type
  App.Packet -> ActiveMessageC.Packet[AM_RBS_MSG];      // Packet utility (for getPayload)
  App.BeaconTimer -> TimerMilliC;                       // Millisecond timer for periodic beacons
  App.LocalTime -> LocalTimeC.LocalTime;                // Local time interface (32kHz tick counter)
}
