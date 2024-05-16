#include <stdio.h>

/*
typedef struct{
	short int id_code;
	short int prod_slot;
	short int expiry;
	short int priority;
} product;
*/

int main(int argc, char **argv){
	
	FILE *fp;
	/*
	int id_prodotto;
	int slot_produzione;
	int scadenza;
	
	int conclusione = 0;
	int penalty = 0;
	int max_slot = 100;
	*/
	int algoritmo;
	int n_prod = 0;
	char c;
	
	int prodotto[10][4];
	
	if(argc == 2){
		fp = fopen(argv[1], "r");
		if(fp){
			printf("-- FILE LETTO CORRETTAMENTE --\n\n");						  //debug
			
			while((c = fgetc(fp)) != EOF)
				if(c == '\n')
					n_prod++;
			printf("Numero prodotti nel file: %d\n\n", n_prod);					  //debug


			printf("1. EDF\n2. HPF\n");
			do{
				printf("Scegli algoritmo: ");
				scanf("%d", &algoritmo);
				if(algoritmo == 1)
					printf("Algoritmo EDF...\n");
				else if(algoritmo == 2)
					printf("Algoritmo HPF...\n");
				else
					printf("Algoritmo non valido\n");
			}while(algoritmo > 2 || algoritmo < 1);
		fclose(fp);
		}else
			printf("Errore apertura file\n");
	}else
		printf("Errore input argomenti\n");
	return 0;
}

