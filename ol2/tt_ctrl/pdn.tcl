#
# Custom PDN configuration for tt_ctrl
#
# We need to fit the voltage rails at exactly the right spot
# to not conflict with the met4 vertical spine
#
# Copyright 2020-2022 Efabless Corporation
# Copyright 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl
set_global_connections

# Voltage nets
set_voltage_domain -name CORE -power $::env(VDD_NET) -ground $::env(GND_NET)

# Design is a macro in the core
define_pdn_grid \
    -name stdcell_grid \
    -starts_with POWER \
    -voltage_domain CORE \
    -pins $::env(FP_PDN_VERTICAL_LAYER)

add_pdn_stripe \
    -grid stdcell_grid \
    -layer $::env(FP_PDN_VERTICAL_LAYER) \
    -width $::env(FP_PDN_VWIDTH) \
    -pitch $::env(FP_PDN_VPITCH) \
    -offset $::env(FP_PDN_VOFFSET) \
    -spacing $::env(FP_PDN_VSPACING) \
    -starts_with POWER

# Adds the standard cell rails
add_pdn_stripe \
    -grid stdcell_grid \
    -layer $::env(FP_PDN_RAIL_LAYER) \
    -width $::env(FP_PDN_RAIL_WIDTH) \
    -followpins \
    -starts_with POWER

add_pdn_connect \
    -grid stdcell_grid \
    -layers "$::env(FP_PDN_RAIL_LAYER) $::env(FP_PDN_VERTICAL_LAYER)"
