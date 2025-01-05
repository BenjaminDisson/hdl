#Repertoire de simulation RTL
cd $env(PATH_BIBLI_HDL)/InferMem/sim

#Permet de continuer le script lorsqu'il se met en pause à la fin du test_bench (surtout pour le mode batch)
onbreak {resume}
onerror {resume}

#Creation de la librairie work
vlib work

#Compilation
vcom -93 $env(PATH_BIBLI_HDL)/InferMem/src/InferRam1c2p.vhd
vcom -93 $env(PATH_BIBLI_HDL)/InferMem/src/InferFifo1c.vhd
vcom -93 $env(PATH_BIBLI_HDL)/InferMem/src/Wrapper_Ram1c2p.vhd
vcom -93 $env(PATH_BIBLI_HDL)/InferMem/src/Wrapper_Fifo1c.vhd
vcom -93 $env(PATH_BIBLI_HDL)/InferMem/src/InferMem_pkg.vhd
vcom -93 $env(PATH_BIBLI_HDL)/InferMem/tb/tb_Wrapper_Fifo1c.vhd





#Simulation du test bench
vsim -voptargs="+acc" -t ps tb_Wrapper_Fifo1c

#Ajout des "waves" qui nous interessent(pour le mode interactif)
do $env(PATH_BIBLI_HDL)/InferMem/sim/wave.do

#Commande pour désactiver les messages du package numeric_std 
set NumericStdNoWarnings 1

#Lancement de la simulation
run -all

#Pour quitter la simulation
#quit -sim

#Pour quitter Modelsim (mode batch)
#quit -f
