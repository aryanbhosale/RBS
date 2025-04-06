#ifndef RBS_H
#define RBS_H

typedef nx_struct RBSMsg {
  nx_uint32_t beacon_timestamp;  // Timestamp from beacon (in local time ticks)
} RBSMsg_t;

enum {
  AM_RBS_MSG = 0x93   // Unique Active Message type for RBS messages
};

#endif
