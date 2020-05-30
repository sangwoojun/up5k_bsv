/*
 * Generated by Bluespec Compiler, version 2014.07.A (build 34078, 2014-07-30)
 * 
 * On Tue May 19 23:26:45 PDT 2020
 * 
 */

/* Generation options: */
#ifndef __mkBsvTop_bsim_h__
#define __mkBsvTop_bsim_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"


/* Class declaration for the mkBsvTop_bsim module */
class MOD_mkBsvTop_bsim : public Module {
 
 /* Clock handles */
 private:
  tClock __clk_handle_0;
 
 /* Clock gate handles */
 public:
  tUInt8 *clk_gate[0];
 
 /* Instantiation parameters */
 public:
 
 /* Module state */
 public:
  MOD_Fifo<tUInt32> INST_hwmain_ram_delayQ;
  MOD_Reg<tUInt8> INST_hwmain_ram_inCnt;
  MOD_Reg<tUInt8> INST_hwmain_ram_outCnt;
  MOD_Fifo<tUInt32> INST_hwmain_ram_outQ;
  MOD_RegFile<tUInt32,tUInt32> INST_hwmain_ram_ram;
  MOD_Reg<tUInt8> INST_hwmain_ram_readCnt;
  MOD_Fifo<tUInt8> INST_hwmain_relayUart;
  MOD_Reg<tUInt8> INST_initialized;
  MOD_Fifo<tUInt8> INST_uart_inQ;
  MOD_Reg<tUInt8> INST_uart_inReqId;
  MOD_Reg<tUInt8> INST_uart_outCnt;
  MOD_Fifo<tUInt8> INST_uart_outQ;
 
 /* Constructor */
 public:
  MOD_mkBsvTop_bsim(tSimStateHdl simHdl, char const *name, Module *parent);
 
 /* Symbol init methods */
 private:
  void init_symbols_0();
 
 /* Reset signal definitions */
 private:
  tUInt8 PORT_RST_N;
 
 /* Port definitions */
 public:
 
 /* Publicly accessible definitions */
 public:
  tUInt8 DEF_v__h1457;
  tUInt8 DEF__read__h760;
  tUInt8 DEF__read__h668;
  tUInt8 DEF_uart_outQ_first__0_BIT_0___d31;
 
 /* Local definitions */
 private:
  tUInt32 DEF_v__h320;
 
 /* Rules */
 public:
  void RL_uart_relayOut();
  void RL_uart_relayIn();
  void RL_hwmain_ram_dodelay();
  void RL_hwmain_ttt();
  void RL_doinit();
  void RL_relayUartIn();
  void RL_relayUartOut();
 
 /* Methods */
 public:
 
 /* Reset routines */
 public:
  void reset_RST_N(tUInt8 ARG_rst_in);
 
 /* Static handles to reset routines */
 public:
 
 /* Pointers to reset fns in parent module for asserting output resets */
 private:
 
 /* Functions for the parent module to register its reset fns */
 public:
 
 /* Functions to set the elaborated clock id */
 public:
  void set_clk_0(char const *s);
 
 /* State dumping routine */
 public:
  void dump_state(unsigned int indent);
 
 /* VCD dumping routines */
 public:
  unsigned int dump_VCD_defs(unsigned int levels);
  void dump_VCD(tVCDDumpType dt, unsigned int levels, MOD_mkBsvTop_bsim &backing);
  void vcd_defs(tVCDDumpType dt, MOD_mkBsvTop_bsim &backing);
  void vcd_prims(tVCDDumpType dt, MOD_mkBsvTop_bsim &backing);
};

#endif /* ifndef __mkBsvTop_bsim_h__ */