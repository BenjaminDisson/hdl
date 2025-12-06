#Repertoire de simulation RTL
#cd $env(PATH_BIBLI_HDL)/cos_sin/modelsimRTL
cd M:/workspace_xilinx/kontopsxil/sim

#Permet de continuer le script lorsqu'il se met en pause à la fin du test_bench (surtout pour le mode batch)
onbreak {resume}
onerror {resume}

#Creation de la librairie work
vlib work

#Compilation
vcom -93 M:/workspace_xilinx/kontopsxil/src/FrameGeneratorGMII.vhd
vcom -93 M:/workspace_xilinx/kontopsxil/tb/tb.vhd





#Simulation du test bench
vsim FrameGeneratorGMII_tb

#Ajout des "waves" qui nous interessent(pour le mode interactif)
#do $env(PATH_BIBLI_HDL)/cos_sin/modelsimRTL/wave.do

#Commande pour désactiver les messages du package numeric_std 
set NumericStdNoWarnings 1

#Lancement de la simulation
#run -all

#Pour quitter la simulation
#quit -sim

#Pour quitter Modelsim (mode batch)
#quit -f
