#include <stdio.h>

void visualizza_prodotti(int, int*, int*, int*, int*);
int main(int argc, char **argv){
	
	FILE *fp;
	
	int id_prodotto[10];
	int slot_produzione[10];
	int scadenza[10];
	int priorita[10];
	
	int n_prod = 0;
	
	if(argc == 2){
		fp = fopen(argv[1], "r");
		if(fp){
			printf("-- FILE LETTO CORRETTAMENTE --\n\n");					  				//debug
			while (!feof(fp)){
				fscanf(fp, "%d", &id_prodotto[n_prod]);
				fscanf(fp, "%d", &slot_produzione[n_prod]);
				fscanf(fp, "%d", &scadenza[n_prod]);
				fscanf(fp, "%d", &priorita[n_prod]);
				n_prod++;
			}
			
			printf("Numero prodotti nel file: %d\n\n", n_prod);								//debug
			visualizza_prodotti(n_prod, id_prodotto, slot_produzione, scadenza, priorita);	//debug 
				
			/*
			int algoritmo;
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
			*/
			
		fclose(fp);
		}else
			printf("Errore apertura file\n");
	}else
		printf("Errore input argomenti\n");
	
	

	return 0;
}

void visualizza_prodotti(int n_prod, int *id_prodotto, int *slot_produzione, int *scadenza, int *priorita){
	
	for(int i = 0; i < n_prod; i++){
		printf("%d,", id_prodotto[i]);
		printf("%d,", slot_produzione[i]);
		printf("%d,", scadenza[i]);
		printf("%d\n", priorita[i]);
	}
}
	
	
	
/* CHATGPT > VERSIONE SUA
#include <stdio.h>

void visualizza_prodotti(int, int*, int*, int*, int*);

int main(int argc, char **argv) {
    FILE *fp;
    int id_prodotto[10];
    int slot_produzione[10];
    int scadenza[10];
    int priorita[10];
    int n_prod = 0;

    if (argc == 2) {
        fp = fopen(argv[1], "r");
        if (fp) {
            printf("-- FILE LETTO CORRETTAMENTE --\n\n");
            while (n_prod < 10 && fscanf(fp, "%d %d %d %d", &id_prodotto[n_prod], &slot_produzione[n_prod], &scadenza[n_prod], &priorita[n_prod]) == 4) {
                n_prod++;
            }

            printf("Numero prodotti nel file: %d\n\n", n_prod);
            visualizza_prodotti(n_prod, id_prodotto, slot_produzione, scadenza, priorita);

            fclose(fp);
        } else {
            printf("Errore nell'apertura del file.\n");
        }
    } else {
        printf("Errore negli argomenti di input.\n");
    }

    return 0;
}

void visualizza_prodotti(int n_prod, int *id_prodotto, int *slot_produzione, int *scadenza, int *priorita) {
    for (int i = 0; i < n_prod; i++) {
        printf("%d, %d, %d, %d\n", id_prodotto[i], slot_produzione[i], scadenza[i], priorita[i]);
    }
}
*/ 
