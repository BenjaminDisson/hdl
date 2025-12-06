#Repertoire de simulation RTL
cd $env(PATH_BIBLI_HDL)/workspace_altera/TteValidation/uartahblite/sim

#Permet de continuer le script lorsqu'il se met en pause à la fin du test_bench (surtout pour le mode batch)
onbreak {resume}
onerror {resume}

# ---------------------------------
# - Creation de la librairie work -
# ---------------------------------
vlib work


# ---------------
# - Compilation -
# ---------------
# Primitive
vlog C:/intelFPGA_lite/20.1/quartus/eda/sim_lib/altera_mf.v

# Src
#vlog ../src/FifoOneClock.v
vlog ../../alt_ip/uart_alt_fifoscC4GX.v
vlog ../src/UartTx.sv
vlog ../src/UartRx.sv
vlog ../src/TopUartAhbLite.sv

# Tb
vlog ../tb/TopUartAhbLite_tb.sv



#Simulation du test bench
#vsim -novopt TopUartAhbLite_tb # novopt depreciated
vsim TopUartAhbLite_tb


#Ajout des "waves" qui nous interessent(pour le mode interactif)
#do $env(PATH_BIBLI_HDL)/workspace_altera/TteValidation/uartahblite/run/wave.do
do $env(PATH_BIBLI_HDL)/workspace_altera/TteValidation/uartahblite/sim/wave.do

#Commande pour désactiver les messages du package numeric_std 
#set NumericStdNoWarnings 1

#Lancement de la simulation
run -all

#Pour quitter la simulation
#quit -sim

#Pour quitter Modelsim (mode batch)
#quit -f

# -----------------
# - SystemVerilog -
# -----------------
#vsim -novopt -assertdebug -assertcover test
#view assertions