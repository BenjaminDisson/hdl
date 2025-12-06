#Repertoire de simulation RTL
cd $env(PATH_BIBLI_HDL)/sha_RS232/modelsimRTL

#Permet de continuer le script lorsqu'il se met en pause à la fin du test_bench (surtout pour le mode batch)
onbreak {resume}
onerror {resume}

#Creation de la librairie work
vlib work

#Compilation
vcom -93 $env(PATH_BIBLI_HDL)/ramdp/source/ram_double_port.vhd
vcom -93 $env(PATH_BIBLI_HDL)/RS232_parallel/src/RS_vers_Parallele.vhd
vcom -93 $env(PATH_BIBLI_HDL)/RS232_parallel/src/Concatenation_parallele_RS.vhd



vcom -93 $env(PATH_BIBLI_HDL)/sha/src/keccak_round_constants_gen.vhd
vcom -93 $env(PATH_BIBLI_HDL)/sha/src/keccak_round.vhd
vcom -93 $env(PATH_BIBLI_HDL)/sha/src/keccak_globals.vhd
vcom -93 $env(PATH_BIBLI_HDL)/sha/src/keccak_buffer.vhd
vcom -93 $env(PATH_BIBLI_HDL)/sha/src/keccak.vhd

vcom -93 $env(PATH_BIBLI_HDL)/parallel_RS232/src/Parallele_vers_RS.vhd
vcom -93 $env(PATH_BIBLI_HDL)/parallel_RS232/src/Decatenation_parallele_RS.vhd

vcom -93 $env(PATH_BIBLI_HDL)/sha_RS232/src/Top_SHA_par_RS.vhd
vcom -93 $env(PATH_BIBLI_HDL)/sha_RS232/tb/tb_sha_RS232.vhd





#Simulation du test bench
vsim tb_sha_RS232

#Ajout des "waves" qui nous interessent(pour le mode interactif)
#do $env(PATH_BIBLI_HDL)/sha_RS232/modelsimRTL/wave.do

#Commande pour désactiver les messages du package numeric_std 
set NumericStdNoWarnings 1

#Lancement de la simulation
#run -all

#Pour quitter la simulation
#quit -sim

#Pour quitter Modelsim (mode batch)
#quit -f
