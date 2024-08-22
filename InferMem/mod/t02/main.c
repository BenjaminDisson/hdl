#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <time.h>

/* Je définie la fonction hasard() */
int hasard(int min, int max);

int main()
{
  srand(time(NULL)); //Très important
  int alea=0;
  int min = 0;
  int max = 65535;
  int tableau_init[256]= {0};
  int tableau_second[256]= {0};
  int tableau_ram[256]={0};

  /*int din = 0, write = 0, adrin = 0, adrout = 0;
  int dout = 0;
 */

  int compteur = 0;

  FILE* fichier_in = NULL;
  FILE* fichier_ref = NULL;



  for (compteur = 0; compteur < 256 ; compteur++)
  {
      tableau_init[compteur]=hasard(min, max);
  }

  for (compteur = 0; compteur < 256 ; compteur++)
  {
      tableau_second[compteur]=hasard(min, max);
  }

  fichier_in = fopen("data.in", "w");
  fichier_ref = fopen("data.ref", "w");

    //verification que l'ouverture des fichiers a fonctionné
    if (fichier_in == NULL || fichier_ref == NULL)
    {
            printf("Erreur d'ouverture de fichier !\n");
    }


  fprintf(fichier_in,"4444 1 00 00\n");
  fprintf(fichier_ref,"0000\n");
  tableau_ram[0]=17476;

  //Ecriture dans la ram du tableau 1
  for (compteur = 1 ; compteur < 200 ; compteur++)
  {
      tableau_ram[compteur]=tableau_init[compteur];
      fprintf(fichier_in,"%04x 1 %02x %02x\n",tableau_init[compteur],compteur,compteur-1);
      fprintf(fichier_ref,"%04x\n",tableau_ram[compteur-1]);
  }


//-------------------------------------------------------------------------------------
  fprintf(fichier_ref,"4444\n");
  for (compteur = 1 ; compteur < 99 ; compteur++)
  {
      fprintf(fichier_in,"0017 0 %02x %02x\n",compteur,compteur-1);
      fprintf(fichier_ref,"%04x\n",tableau_ram[compteur]);
  }
   fprintf(fichier_in,"0017 0 63 62\n");
   fprintf(fichier_ref,"%04x\n",tableau_ram[99]);
//-------------------------------------------------------------------------------------


      tableau_ram[200]=tableau_init[200];
      fprintf(fichier_in,"%04x 1 C8 63\n",tableau_init[200]);
      fprintf(fichier_ref,"%04x\n",tableau_ram[200]);

  for (compteur = 201 ; compteur < 255 ; compteur++)
  {
      tableau_ram[compteur]=tableau_init[compteur];
      fprintf(fichier_in,"%04x 1 %02x %02x\n",tableau_init[compteur],compteur,compteur-1);
      fprintf(fichier_ref,"%04x\n",tableau_ram[compteur]);
  }
      tableau_ram[255]=tableau_init[255];
      fprintf(fichier_in,"%04x 1 ff fe\n",tableau_init[255]);
      fprintf(fichier_ref,"%04x\n",tableau_ram[7]);


//-------------------------------------------------------------------------------------
  for (compteur = 0 ; compteur < 100 ; compteur++)
  {
      fprintf(fichier_in,"%04x 0 %02x 07\n",tableau_init[compteur],compteur);
      fprintf(fichier_ref,"%04x\n",tableau_ram[7]);
  }
//-------------------------------------------------------------------------------------

int tmp_alea = 7;

  for (compteur = 0 ; compteur < 299 ; compteur++)
  {
      alea = hasard(0, 255);
      tableau_ram[alea]=tableau_second[alea];
      fprintf(fichier_in,"%04x 1 %02x %02x\n",tableau_second[alea],alea,tmp_alea);
      fprintf(fichier_ref,"%04x\n",tableau_second[alea]);
      tmp_alea = alea;
  }

      alea = hasard(0, 255);
      tableau_ram[alea]=tableau_second[alea];
      fprintf(fichier_in,"%04x 1 %02x %02x\n",tableau_second[alea],alea,tmp_alea);
      //fprintf(fichier_ref,"0000\n");


  for (compteur = 0 ; compteur < 255 ; compteur++)
  {

      fprintf(fichier_in,"%04x 0 %02x %02x\n",0,0,compteur);
      fprintf(fichier_ref,"%04x\n",tableau_ram[compteur]);

  }

      fprintf(fichier_in,"%04x 0 %02x 255\n",0,0);

  return 0;
}

int hasard(int min, int max)
{
    return rand() % (max-min) + min;
}
