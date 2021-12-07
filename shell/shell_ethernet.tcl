set ETHClkNm [dict get $ETHentry SyncClk Label]
set ETHFreq  [dict get $ETHentry SyncClk Freq]
set ETHname  [dict get $ETHentry SyncClk Name]
set ETHintf  [dict get $ETHentry IntfLabel]

set ETHaddrWidth [dict get $ETHentry AxiAddrWidth]
set ETHdataWidth [dict get $ETHentry AxiDataWidth]
set ETHidWidth   [dict get $ETHentry AxiIdWidth]
set ETHUserWidth [dict get $ETHentry AxiUserWidth]

putdebugs "ETHClkNm     $ETHClkNm    "
putdebugs "ETHFreq      $ETHFreq     "
putdebugs "ETHname      $ETHname     "
putdebugs "ETHintf      $ETHintf     "
putdebugs "ETHaddrWidth $ETHaddrWidth"
putdebugs "ETHdataWidth $ETHdataWidth"
putdebugs "ETHidWidth   $ETHidWidth  "
putdebugs "ETHUserWidth $ETHUserWidth"


### Initialize the IPs
putmeeps "Packaging ETH IP..."
exec vivado -mode batch -nolog -nojournal -notrace -source $g_root_dir/ip/100GbEthernet/tcl/gen_project.tcl
putmeeps "... Done."
update_ip_catalog -rebuild

source $g_root_dir/ip/100GbEthernet/tcl/project_options.tcl
create_bd_cell -type ip -vlnv meep-project.eu:MEEP:MEEP_100Gb_Ethernet:$g_ip_version MEEP_100Gb_Ethernet_0

# create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 eth_axi
# connect_bd_intf_net [get_bd_intf_ports $ETHintf] [get_bd_intf_pins MEEP_100Gb_Ethernet_0/S_AXI]
# #set_property CONFIG.ASSOCIATED_BUSIF $ETHintf [get_bd_ports /$ETHClkNm]

# ## This might be hardcoded to the IP AXI bus width parameters until 
# ## we can back-propagate them to the Ethernet IP. 512,64,6
# set_property CONFIG.DATA_WIDTH $ETHdataWidth [get_bd_intf_ports /$ETHintf]
# set_property CONFIG.ADDR_WIDTH $ETHaddrWidth [get_bd_intf_ports /$ETHintf]
# set_property CONFIG.ID_WIDTH $ETHidWidth [get_bd_intf_ports /$ETHintf]

  set eth_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 eth_axi ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH $ETHaddrWidth \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH $ETHdataWidth \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH $ETHidWidth \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $eth_axi


make_bd_pins_external  [get_bd_pins MEEP_100Gb_Ethernet_0/qsfp_4x_grx_n] [get_bd_pins MEEP_100Gb_Ethernet_0/qsfp_4x_grx_p]
make_bd_pins_external  [get_bd_pins MEEP_100Gb_Ethernet_0/qsfp_refck_clk_n]
make_bd_pins_external  [get_bd_pins MEEP_100Gb_Ethernet_0/qsfp_refck_clk_p]
make_bd_pins_external  [get_bd_pins MEEP_100Gb_Ethernet_0/qsfp_4x_gtx_n]
make_bd_pins_external  [get_bd_pins MEEP_100Gb_Ethernet_0/qsfp_4x_gtx_p]
connect_bd_net [get_bd_pins MEEP_100Gb_Ethernet_0/s_axi_clk] [get_bd_pins clk_wiz_1/CLK0]
connect_bd_net [get_bd_pins rst_ea_CLK0/peripheral_aresetn] [get_bd_pins MEEP_100Gb_Ethernet_0/s_axi_resetn]
make_bd_pins_external  [get_bd_pins MEEP_100Gb_Ethernet_0/intc]


save_bd_design
## Create the Shell interface to the RTL
## CAUTION: The user can't specify USER, QOS and REGION signal for this interface
## This means those signals can't be in the module definition file


### Set Base Addresses to peripheral
# ETH
set ETHbaseAddr [dict get $ETHentry BaseAddr]

## Ethernet address space is 512K as the highest address. 
## TODO: Maybe it should be hardcoded

set ETHMemRange [expr {2**$ETHaddrWidth/1024}]

putdebugs "Base Addr ETH: $ETHbaseAddr"
putdebugs "Mem Range ETH: $ETHMemRange"

assign_bd_address [get_bd_addr_segs {MEEP_100Gb_Ethernet_0/S_AXI/reg0 }]

# set_property offset $ETHbaseAddr [get_bd_addr_segs {MEEP_100Gb_Ethernet_0/S_AXI/reg0 }]
# set_property range ${ETHMemRange}K [get_bd_addr_segs {MEEP_100Gb_Ethernet_0/S_AXI/reg0 }]


save_bd_design

# set_property CONFIG.ASSOCIATED_BUSIF $ETHintf [get_bd_ports /$ETHname]

