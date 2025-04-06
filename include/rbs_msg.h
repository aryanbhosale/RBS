#ifndef RBS_MSG_H
#define RBS_MSG_H

enum {
  AM_RBS_MSG = 0x90
};

typedef nx_struct rbs_msg {
  nx_uint32_t timestamp;
  nx_uint32_t diff;  // new field for debug: time difference
} rbs_msg;

#endif // RBS_MSG_H
