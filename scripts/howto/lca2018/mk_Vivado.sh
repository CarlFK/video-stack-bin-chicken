mkdir ~/local/Xilinx -p
sudo ln -sf ~/local/Xilinx /opt
sudo chown $USER: /opt/Xilinx
cd Xilinx_Vivado_2019.2_1106_2127

# this takes 10 min:
time ./xsetup -b Install -a XilinxEULA,3rdPartyEULA,WebTalkTerms -c ~/install_config.txt

# this 20 min
tar czf Vivado_2019_2.tgz Xilinx

