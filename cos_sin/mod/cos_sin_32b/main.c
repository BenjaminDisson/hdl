#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
#include <math.h>

#define P_ent 8
#define P_fra 23


/* Declaration des fonctions */
int hasard(int min, int max);
void int2bin(char*,int,int);
void frac2bin(char*,float,int);


int main()
{
/****************************************
** fonctionnement de la fonction random *
****************************************/
//srand(time(NULL)); //Très important
//int i = 0;
//i = hasard(0, 65535);


/*****************************
** Déclaration des variables *
*****************************/

    double  cpt_data = 0.0;
    int partie_entiere = 0;
    double  partie_decimal = 0.0;
    int cpt_str = 0;

    char str_tot_ang[1+P_ent+P_fra+1] = "";
    char str_tot_cos[1+P_ent+P_fra+1] = "";
    char str_tot_sin[1+P_ent+P_fra+1] = "";
    char str_ent[1+P_ent+P_fra] = "";
    char str_fra[1+P_ent+P_fra] = "";

    double  val_cos = 0.0,val_sin = 0.0;

/************************
** Gestion des fichiers *
************************/

    FILE* fichier_in = NULL;
    FILE* fichier_ref = NULL;
    fichier_in = fopen("data.in", "w");
    fichier_ref = fopen("data.ref", "w");

    //verification que l'ouverture des fichiers a fonctionné
    if (fichier_in == NULL)
    {
            printf("Erreur d'ouverture de fichier !\n");
    }

    if (fichier_ref == NULL)
    {
            printf("Erreur d'ouverture de fichier !\n");
    }

/************************
** Gestion des fichiers *
************************/
    for (cpt_data = 0.0 ; cpt_data < 10.0 ; cpt_data=cpt_data + 0.000011920928955078125)// 1/2^23*100   + 0.0078125)//1/2^7
    {

        /*********************
        ** Fichier d'entrée **
        *********************/
        if (cpt_data > 0.0)
        {
            partie_entiere = floor(cpt_data);
        }
        else
        {
            partie_entiere = ceil(cpt_data);
        }
        partie_decimal = cpt_data - partie_entiere;

        int2bin(str_ent,partie_entiere,1+P_ent);
        frac2bin(str_fra,partie_decimal,P_fra);


        for (cpt_str = 0 ; cpt_str < 1+P_ent ; cpt_str++)
        {
            str_tot_ang[cpt_str] = str_ent[cpt_str];
        }
        for (cpt_str = 0 ; cpt_str < P_fra ; cpt_str++)
        {
            str_tot_ang[1+P_ent+cpt_str] = str_fra[P_fra-1-cpt_str];
        }

        fprintf(fichier_in,"00000000000000000000000000000000 00000000000000000000000000000000 %s\n",str_tot_ang);


        /*************************
        ** Fichier de référence **
        *************************/
        /* Partie Cosinus */
        /* -------------- */
        /* 1bit de signe | 1 bit entier | 14 bits decimal */
        /*
        val_cos = cos(cpt_data*M_PI/180);
        if (val_cos > 0.0)
        {
            partie_entiere = floor(val_cos);
        }
        else
        {
            partie_entiere = ceil(val_cos);
        }

        partie_decimal = val_cos - partie_entiere;
        int2bin(str_ent,partie_entiere,1+1);
        frac2bin(str_fra,partie_decimal,14);

        for (cpt_str = 0 ; cpt_str < 1+1 ; cpt_str++)
        {
            str_tot_cos[cpt_str] = str_ent[cpt_str];
        }
        for (cpt_str = 0 ; cpt_str < 14 ; cpt_str++)
        {
            str_tot_cos[1+1+cpt_str] = str_fra[14-1-cpt_str];
        }
        */


        /* 1bit de signe | 8 bit entier | 7 bits decimal */

        val_cos = cos(cpt_data*M_PI/180);
        if (val_cos > 0.0)
        {
            partie_entiere = floor(val_cos);
        }
        else
        {
            partie_entiere = ceil(val_cos);
        }

        partie_decimal = val_cos - partie_entiere;
        int2bin(str_ent,partie_entiere,1+P_ent);
        frac2bin(str_fra,partie_decimal,P_fra);

        for (cpt_str = 0 ; cpt_str < 1+P_ent ; cpt_str++)
        {
            str_tot_cos[cpt_str] = str_ent[cpt_str];
        }
        for (cpt_str = 0 ; cpt_str < P_fra ; cpt_str++)
        {
            str_tot_cos[1+P_ent+cpt_str] = str_fra[P_fra-1-cpt_str];
        }

        /* Partie sinus */
        /* ------------ */
        /* 1 bit de signe | 1 bit entier | 14 bits decimal */
        /*
        val_sin = sin(cpt_data*M_PI/180);
        if (val_sin > 0.0)
        {
            partie_entiere = floor(val_sin);
        }
        else
        {
            partie_entiere = ceil(val_sin);
        }

        partie_decimal = val_sin - partie_entiere;
        int2bin(str_ent,partie_entiere,1+1);
        frac2bin(str_fra,partie_decimal,14);

        for (cpt_str = 0 ; cpt_str < 1+1 ; cpt_str++)
        {
            str_tot_sin[cpt_str] = str_ent[cpt_str];
        }
        for (cpt_str = 0 ; cpt_str < 14 ; cpt_str++)
        {
            str_tot_sin[1+1+cpt_str] = str_fra[14-1-cpt_str];
        }
        */

        /* 1 bit de signe | 8 bit entier | 7 bits decimal */
        val_sin = sin(cpt_data*M_PI/180);
        if (val_sin > 0.0)
        {
            partie_entiere = floor(val_sin);
        }
        else
        {
            partie_entiere = ceil(val_sin);
        }

        partie_decimal = val_sin - partie_entiere;
        int2bin(str_ent,partie_entiere,1+P_ent);
        frac2bin(str_fra,partie_decimal,P_fra);

        for (cpt_str = 0 ; cpt_str < 1+P_ent ; cpt_str++)
        {
            str_tot_sin[cpt_str] = str_ent[cpt_str];
        }
        for (cpt_str = 0 ; cpt_str < P_fra ; cpt_str++)
        {
            str_tot_sin[1+P_ent+cpt_str] = str_fra[P_fra-1-cpt_str];
        }



        fprintf(fichier_ref,"%s %s\n",str_tot_cos,str_tot_sin);
    }

    /************************
    ** Gestion des fichiers *
    ************************/
    fclose(fichier_in);
    fclose(fichier_ref);

    return 0;
}

//------------------------------------------------------------------------------------------------------------
int hasard(int min, int max)
{
    return rand() % (max-min) + min;
}

//------------------------------------------------------------------------------------------------------------
void int2bin(char* str_ent,int value, int nb_bits)
{
    sprintf(str_ent,"000000000");

    if (value < 0)
    {
         value = pow(2,P_ent)*2+value;
    }
    while (value > 0)
    {
        if (value%2==1)
        {
            str_ent[nb_bits-1] = '1';
                    }
        else
        {
            str_ent[nb_bits-1] = '0';
        }
        nb_bits--;
        value = value/2 ;
    }
}

//------------------------------------------------------------------------------------------------------------
void frac2bin(char* str_fra,float value,int nb_bits)
{
    sprintf(str_fra,"000000000000000");

    while (nb_bits > 0)
    {
        if (value*2 > 1)
        {
            str_fra[nb_bits-1] = '1';
            value = value * 2 - 1;
         }
        else
        {
            str_fra[nb_bits-1] = '0';
            value = value * 2;
        }
        nb_bits--;
    }
}
