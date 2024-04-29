#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
#include <math.h>

#define P_ent 8
#define P_fra 7

/* Declaration des fonctions */
int hasard(int min, int max);
void frac2bin(char*,float,int,int,int*);
void int2bin(char*,int,int,int,int*);



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

    float cpt_data = 0.0;
    int signe = 0; // 0 = positif // 1 = negatif
    int retenue = 0; // 0 = non // 1 = oui
    int partie_entiere = 0;
    float partie_decimal = 0.0;
    int cpt_str = 0;

    char str_tot_ang[1+P_ent+P_fra+1] = "";
    char str_tot_cos[1+P_ent+P_fra+1] = "";
    char str_tot_sin[1+P_ent+P_fra+1] = "";
    char str_ent[16] = "";
    char str_fra[16] = "";

    float val_cos = 0.0,val_sin = 0.0;

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
    for (cpt_data = -180.0 ; cpt_data < 180.0 ; cpt_data=cpt_data + 0.0078125*200)//1/2^7
    {

        /*********************
        ** Fichier d'entrée **
        *********************/
        /*if (cpt_data > 0.0)
        {
            partie_entiere = floor(cpt_data);
        }
        else
        {
            partie_entiere = ceil(cpt_data);
        }*/
        if (cpt_data > 0.0 || cpt_data == 0.0)
        {
            signe = 0; // signe positif
            partie_entiere = (int)(cpt_data);
            partie_decimal = cpt_data - partie_entiere;
        }
        else
        {
            signe = 1; // signe négatif
            partie_entiere = -((int)(cpt_data));
            partie_decimal = -(cpt_data + partie_entiere);
        }

        frac2bin(str_fra,partie_decimal,P_fra, signe, &retenue);
        int2bin(str_ent,partie_entiere,1+P_ent,signe, &retenue);



        for (cpt_str = 0 ; cpt_str < 1+P_ent ; cpt_str++)
        {
            str_tot_ang[cpt_str] = str_ent[cpt_str];
        }
        for (cpt_str = 0 ; cpt_str < P_fra ; cpt_str++)
        {
            str_tot_ang[1+P_ent+cpt_str] = str_fra[P_fra-1-cpt_str];
        }

        fprintf(fichier_in,"0000000000000000 0000000000000000 %s 1\n",str_tot_ang);


        /*************************
        ** Fichier de référence **
        *************************/
        /* Partie Cosinus */
        /* -------------- */
        /* 1bit de signe | 8 bit entier | 7 bits decimal */

        val_cos = cos(cpt_data*M_PI/180);

        if (val_cos > 0.0 || val_cos == 0.0)
        {
            signe = 0; // signe positif
            partie_entiere = (int)(val_cos);
            partie_decimal = val_cos - partie_entiere;
        }
        else
        {
            signe = 1; // signe négatif
            partie_entiere = -((int)(val_cos));
            partie_decimal = -(val_cos + partie_entiere);
        }

        frac2bin(str_fra,partie_decimal,7, signe, &retenue);
        int2bin(str_ent,partie_entiere,8+1,signe, &retenue);


        for (cpt_str = 0 ; cpt_str < 1+8 ; cpt_str++)
        {
            str_tot_cos[cpt_str] = str_ent[cpt_str];
        }
        for (cpt_str = 0 ; cpt_str < 7 ; cpt_str++)
        {
            str_tot_cos[1+8+cpt_str] = str_fra[7-1-cpt_str];
        }

        /* Partie sinus */
        /* ------------ */
        /* 1 bit de signe | 8 bit entier | 7 bits decimal */
        val_sin = sin(cpt_data*M_PI/180);

        if (val_sin > 0.0 || val_sin == 0.0)
        {
            signe = 0; // signe positif
            partie_entiere = (int)(val_sin);
            partie_decimal = val_sin - partie_entiere;
        }
        else
        {
            signe = 1; // signe négatif
            partie_entiere = -((int)(val_sin));
            partie_decimal = -(val_sin + partie_entiere);
        }

        frac2bin(str_fra,partie_decimal,7, signe, &retenue);
        int2bin(str_ent,partie_entiere,8+1,signe, &retenue);



        for (cpt_str = 0 ; cpt_str < 1+8 ; cpt_str++)
        {
            str_tot_sin[cpt_str] = str_ent[cpt_str];
        }
        for (cpt_str = 0 ; cpt_str < 7 ; cpt_str++)
        {
            str_tot_sin[1+8+cpt_str] = str_fra[7-1-cpt_str];
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
void frac2bin(char* str_fra,float value,int nb_bits, int signe, int *retenue)
{
    int modif_bits = nb_bits,i=0;
    sprintf(str_fra,"0000000");



    while (nb_bits > 0)
    {
        if (value*2 > 1 || value*2 == 1)
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

    if (signe == 1)
    {
        //inversion des bits
        for(i=0;i<modif_bits;i++)
        {
            if (str_fra[i] == '1')
            {
                str_fra[i] = '0';
            }
            else
            {
                str_fra[i] = '1';
            }
        }
        //complément à 2
        for(i=0;i<modif_bits;i++)
        {
            if (i==0)
            {
                if (str_fra[0] == '1')
                {
                    str_fra[0] = '0';
                    *retenue = 1;
                }
                else
                {
                    str_fra[0] = '1';
                    *retenue = 0;
                }
            }
            else
            {
                if (str_fra[i] == '1' && *retenue==1)
                {
                    str_fra[i] = '0';
                    *retenue = 1;
                }
                else if(str_fra[i] == '1' && *retenue==0)
                {
                    str_fra[i] = '1';
                    *retenue = 0;
                }
                else if(str_fra[i] == '0' && *retenue==1)
                {
                    str_fra[i] = '1';
                    *retenue = 0;
                }
                else if(str_fra[i] == '0' && *retenue==0)
                {
                    str_fra[i] = '0';
                    *retenue = 0;
                }

            }
        }
    }
}
//------------------------------------------------------------------------------------------------------------
void int2bin(char* str_ent,int value, int nb_bits, int signe, int *retenue)
{

    int modif_bits = nb_bits,i=0;
    sprintf(str_ent,"000000000");


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
        value = value/2 ;
        nb_bits--;
    }

    if (signe == 1)
    {
        //inversion des bits
        for(i=0;i<modif_bits;i++)
        {
            if (str_ent[i] == '1')
            {
                str_ent[i] = '0';
            }
            else
            {
                str_ent[i] = '1';
            }
        }
        //complément à 2
        for(i=modif_bits;i>0;i--)
        {
            /*if (i == modif_bits)
            {
                if (str_ent[i-1] == '1')
                {
                    str_ent[i-1] = '0';
                    retenue = 1;
                }
                else
                {
                    str_ent[i-1] = '1';
                    retenue = 0;
                }
            }
            else
            {*/
                if (str_ent[i-1] == '1' && *retenue==1)
                {
                    str_ent[i-1] = '0';
                    *retenue = 1;
                }
                else if(str_ent[i-1] == '1' && *retenue==0)
                {
                    str_ent[i-1] = '1';
                    *retenue = 0;
                }
                else if(str_ent[i-1] == '0' && *retenue==1)
                {
                    str_ent[i-1] = '1';
                    *retenue = 0;
                }
                else if(str_ent[i-1] == '0' && *retenue==0)
                {
                    str_ent[i-1] = '0';
                    *retenue = 0;
                }
            //}
        }
    }
}
