#include "RBS.h"

configuration ReceiverAppC {}
implementation {
  components MainC, ReceiverC as App;
  components ActiveMessageC;
  components LocalTimeC;

  App.Boot -> MainC.Boot;
  App.AMControl -> ActiveMessageC;                       // Radio control (on/off)
  App.Receive -> ActiveMessageC.Receive[AM_RBS_MSG];     // ActiveMessage receive interface for RBS type
  App.LocalTime -> LocalTimeC.LocalTime;                 // Local time interface (32kHz ticks)
}
