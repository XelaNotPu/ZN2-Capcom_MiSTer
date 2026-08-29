derive_pll_clocks
derive_clock_uncertainty

create_generated_clock -name {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk} -source {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|vco0ph[0]} -divide_by 5 -multiply_by 1 -duty_cycle 50.00 { emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk }

set_false_path -from {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}
set_false_path -from {emu|pll|pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk} -to {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}
set_false_path -from {FPGA_CLK1_50} -to {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}
set_false_path -from {FPGA_CLK2_50} -to {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}
set_false_path -from {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk} -to {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}

set_false_path -from {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk} -to {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk} -to {emu|pll|pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk} -to {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}
set_false_path -from {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk} -to {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}
set_false_path -from {emu|pll2|pll2_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk} -to {FPGA_CLK1_50}
# QSound sample-fetch clock-domain-crossing synchronizers (clk_1x <-> clk_2x).
# Each is a 2-FF synchronizer whose FIRST stage samples an asynchronous signal from
# the other domain (qsnd_req_tog: clk_2x->clk_1x ; sdramCh4_done: clk_1x->clk_2x).
# Metastability is handled by the 2-FF chain, so the crossing INTO the first stage
# must be a false path (else STA times the unrelated-phase crossing and reports a
# spurious large negative slack). Only the first sync FF is relaxed; the rest are
# timed normally within their own domain.
set_false_path -to [get_registers {*qsnd_req_sync[0]}]
set_false_path -to [get_registers {*qsnd_done_sync[0]}]
# [2026-08-15 REVERTED — this block was the DSP-freeze regression]
# The false_paths below were WRONG: clk (clk_1x 33.87MHz) and clk_dsp (clk_2x
# 67.74MHz) are PHASE-ALIGNED from the same PLL (2x), so the dsp_irq_s and
# cpu2dsp_s[*] crossings from clk->clk_dsp are SYNCHRONOUS, not async. False-
# pathing them let the fitter skew them arbitrarily -> the DL-1425 DSP never
# cleanly latched the host command -> never consumed it (pids never pulsed) ->
# dsp_irq stuck high -> dsp_ready(D007 bit7) stuck low -> Z80 hangs forever in
# DSP init at 0x00C8 (JTAG PC-fetch probe: 456k spins/2s, cen frozen, pids=0).
# Removing them lets STA time the synchronous crossing so the fitter meets it.
# (Working ZN-1 Capcom has NO such false_paths.)
