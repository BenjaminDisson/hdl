#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define PI 3.141592653
#define P_ent 8
#define P_fra 7

/* Declaration des fonctions */
void int2bin(char*,int,int);
void frac2bin(char*,float,int);
void bin2frac(char* ,float ,int ,float );

int main()
{
/*****************************
** Déclaration des variables *
*****************************/

    float cpt_data = 0.0;
    int partie_entiere = 0;
    float partie_decimal = 0.0;
    int cpt_str = 0;

    char str_tot_ang[1+P_ent+P_fra+1] = "";
    char str_tot_cos[1+P_ent+P_fra+1] = "";
    char str_tot_sin[1+P_ent+P_fra+1] = "";
    char str_ent[16] = "";
    char str_fra[16] = "";

    float val_cos = 0.0,val_sin = 0.0;


//Debug
char str_x[16] = "";
char str_dx[16] = "";
char str_y[16] = "";
char str_dy[16] = "";
char str_a[16] = "";
char str_da[16] = "";




	//double x,y,dx,dy,da,a,d2;
	float x,y,dx,dy,da,a,d2,arrondi;
	int i;
	float angle=0.0;

	x=0.60725293500888133000; //Valeur de K
	y=0.0;
	d2=2.0; // Diviseur
	arrondi= 0.0078125;

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

/***********************
** Gestion des angles *
***********************/
    for (cpt_data = -30 ; cpt_data < 30 ; cpt_data=cpt_data + 0.0078125)//1/2^7
    //for (cpt_data = 0.88 ; cpt_data < 0.9 ; cpt_data=cpt_data + 0.0078125)//1/2^7
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

        fprintf(fichier_in,"0000000000000000 0000000000000000 %s\n",str_tot_ang);

	    /*************************
        ** Fichier de référence **
        *************************/
		if (cpt_data > 90.0 )
		{
			angle = 180.0 - cpt_data;
		}
		else if (cpt_data < - 90.0)
		{
			angle = 180.0 + cpt_data;
		}
		else
		{
			angle = cpt_data;
		}

		a = angle;

		//DEBUG 1 LIGNE
//		printf("\nDONNEES D'ENTREE : angle= %0.6lf / ON INTRODUIT : x=%0.6lf y=%0.6lf\n", a,x,y); // Affichage du résultat






		for(i=0; i<=16; i++)
		{
			d2=d2/2; // Multiple de 2-i
			dx=x*d2;
			dy=y*d2;
			da=atan(d2);
			da= 180.0*da/PI; // Pour une valeur en

//printf("arr= %f | x=%f | dx=%f\n",arrondi,x,dx);





			//superdebug
			frac2bin(str_x,x,7);
			frac2bin(str_dx,dx,7);
			frac2bin(str_y,y,7);
			frac2bin(str_dy,dy,7);
			frac2bin(str_da,da,7);

//			printf("arr= %f |x=%s | dx=%s| x=%f | dx=%f| y=%s| dy=%s| da=%s\n",arrondi,str_x,str_dx,x,dx,str_y,str_dy,str_da);

			if(a<0.0)
			{
				x += dy;
				y -= dx;
				a += da;
			}
			else
			{
				x -= dy;
				y += dx;
				a -= da;
			}
		//DEBUG 1 LIGNE
		//}


            if (cpt_data > 90.0 )
            {
                x = -x;
            }


            if (cpt_data < - 90.0)
            {
                x = -x;
                y = -y;
            }





            /* Partie Cosinus */
            /* -------------- */
            /* 1bit de signe | 8 bit entier | 7 bits decimal */
            if (x > 0.0)
            {
                partie_entiere = floor(x);
            }
            else
            {
                partie_entiere = ceil(x);
            }

            partie_decimal = x - partie_entiere;

            //printf("DEBUG partie entiere =%d     partie decimal =%f\n ",partie_entiere,partie_decimal);
            int2bin(str_ent,partie_entiere,1+8);
            frac2bin(str_fra,partie_decimal,7);

            for (cpt_str = 0 ; cpt_str < 1+8 ; cpt_str++)
            {
                str_tot_cos[cpt_str] = str_ent[cpt_str];
            }
            for (cpt_str = 0 ; cpt_str < 7 ; cpt_str++)
            {
                str_tot_cos[1+8+cpt_str] = str_fra[7-1-cpt_str];
            }



            //Calcul de la nouvelle valeur de X pour éviter les problèmes de précisions
            //#########################################################################//
            bin2frac(str_fra,partie_decimal,7,dx);
            dx = partie_entiere + partie_decimal;



            /* Partie sinus */
            /* ------------ */
            /* 1 bit de signe | 8 bit entier | 7 bits decimal */
            if (y > 0.0)
            {
                partie_entiere = floor(y);
            }
            else
            {
                partie_entiere = ceil(y);
            }

            partie_decimal = y - partie_entiere;
            int2bin(str_ent,partie_entiere,1+8);
            frac2bin(str_fra,partie_decimal,7);

            for (cpt_str = 0 ; cpt_str < 1+8 ; cpt_str++)
            {
                str_tot_sin[cpt_str] = str_ent[cpt_str];
            }
            for (cpt_str = 0 ; cpt_str < 7 ; cpt_str++)
            {
                str_tot_sin[1+8+cpt_str] = str_fra[7-1-cpt_str];
            }

            //Calcul de la nouvelle valeur de Y pour éviter les problèmes de précisions
            //#########################################################################//
            bin2frac(str_fra,partie_decimal,7,dy);
            dy = partie_entiere + partie_decimal;

            //DEBUG 2 LIGNE
//            printf("COS %s SIN %s ITER= %d angle=%f\n\n",str_tot_cos,str_tot_sin,i,a);
		}

		fprintf(fichier_ref,"%s %s\n",str_tot_cos,str_tot_sin);


		//Remise à zero
		x=0.60725293500888133000; //Valeur de K
		y=0.0;
		d2=2.0; // Diviseur


		//printf("cos(beta) = %0.6lf , sin(beta) = %0.6lf \n\n", x,y); // Affichage du résultat
		//printf("Pour le PC en degree, cos(beta) = %0.6lf , sin(beta) = %0.6lf\n", cos(cpt_data*PI/180) , sin(cpt_data*PI/180) );
		//printf("L'erreur est de : %0.6lf et %0.6lf\n\n", cos(cpt_data*PI/180)-x , sin(cpt_data*PI/180)-y );

	}
	/************************
    ** Gestion des fichiers *
    ************************/
    fclose(fichier_in);
    fclose(fichier_ref);


	return 0;
}

//------------------------------------------------------------------------------------------------------------
void int2bin(char* str_ent,int value, int nb_bits)
{
    sprintf(str_ent,"000000000");

    if (value < 0)
    {
         value = pow(2,8)*2+value;
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
    int signe_de_value = 0; //positif
    int modif_bits = 0,i=0, retenue=0;
    sprintf(str_fra,"0000000");

    if (value<0)
    {
        signe_de_value = 1;
        modif_bits = nb_bits;
        value = 0-value;
    }
    else
    {
        signe_de_value = 0;
    }

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

    if (signe_de_value == 1)
    {
        //iversion des bits
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
        for(i=modif_bits;i>0;i--)
        {
            if (i==modif_bits)
            {
                if (str_fra[i-1] == '1')
                {
                    str_fra[i-1] = '0';
                    retenue = 1;
                }
                else
                {
                    str_fra[i-1] = '1';
                    retenue = 0;
                }
            }
            else
            {
                if (str_fra[i-1] == '1' and retenue==1)
                {
                    str_fra[i-1] = '0';
                    retenue = 1;
                }
                else if(str_fra[i-1] == '1' and retenue==0)
                {
                    str_fra[i-1] = '1';
                    retenue = 0;
                }
                else if(str_fra[i-1] == '0' and retenue==1)
                {
                    str_fra[i-1] = '1';
                    retenue = 0;
                }
                else if(str_fra[i-1] == '0' and retenue==0)
                {
                    str_fra[i-1] = '0';
                    retenue = 0;
                }

            }
        }
    }
}

//-----------------------------------------------
// bin2frac(str_fra,partie_decimal,7);
void bin2frac(char* str_fra,float value,int nb_bits,float valeur_origine)
{
    int i=0;

    for (i = 0; i < nb_bits; i++)
    {
        //value = value + str_fra[i] * (1/2)**(i+1.0);
        value = value + str_fra[i] * (1/2^(i+1));
    }
    if (valeur_origine<0)
    {
        value = 0 - value;
    }
}

