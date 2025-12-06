// count1s.c

#include "svdpi.h"

int count1s (int v) {
  int      n = 0;
  unsigned u = v;

  while (u) {
    n += u & 1;
    u /= 2;
  }

  // C functions can call SystemVerilog functions:
  sv_debug("Greetings from the C world!");
  
  return n;
}

// The following is rather contrived, but makes the point that C functions can
// call time-consuming SystemVerilog tasks.

int delay_via_c (int d) {

  // TO DO: Call a SystemVerilog task that executes a delay

  // need to return 0 for the imported task
  return 0;
}
