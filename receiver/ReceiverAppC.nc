#include "RBS.h"
#include <AM.h>
#include <message.h>

/**
 * ReceiverAppC wires up the ReceiverC module to TinyOS services:
 *  - MainC (boot)
 *  - ActiveMessageC (radio on/off, receive interface)
 *  - LocalTimeMilliC (millisecond-resolution local time)
 */
configuration ReceiverAppC {}
implementation {
  components MainC, ReceiverC as App;
  components ActiveMessageC;
  components LocalTimeMilliC; // Declare the singleton component directly

  App.Boot -> MainC.Boot;
  App.AMControl -> ActiveMessageC;
  App.Receive -> ActiveMessageC.Receive[AM_RBS_MSG];
  App.LocalTime -> LocalTimeMilliC;
}
