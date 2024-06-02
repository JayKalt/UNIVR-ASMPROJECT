/*
 *                            UTILIZZO
 * 
 * 	1.	Serve un file degli ordini che non abbia piu di 10 ordini.
 * 		Ogni ordine deve essere su una riga e deve essere fatto cosi:
 * 														
 * 				      	  Ordini.txt
 * 						 _____________
 * 						| x1,y1,z1,t1 |
 * 						| x2,y2,z2,t2 |
 * 						| x3,y3,z3,t3 |
 * 						|	  ...	  |
 * 						|	  ...	  |
 * 						|     ...	  | 
 * 						|			  | 
 * 		
 * 		dove, x: identificativo prodotto
 * 			  y: tempo di produzione del prodotto
 * 		      z: scadenza del tempo di produzione
 * 			  t: priorita del prodotto
 * 
 * 
 *	2.	Per avviare il programma:
 * 					./nomeprogramma file.txt
 * 
 * 
 * 
 * 								NOTE
 * 
 * Il flag DEBUG in prossimita di alcune funzioni indica che sono funzioni
 * utili solo durante la fase di debug e quindi sono commentate se il
 * programma va eseguito normalmente
 * 
 * 
 * 
 * 						CASISTICHE DA RIVEDERE
 * 
 * 1. Se le slot totali dei prodotti superano le slot massime (100)
 * 2. Modalita di uscita dal file
 * 3. Punto bonus - I risultati non sono salvati da nessuna parte
 * 4. Allocazione dinamica degli array?
 * 5. Menu di visualizzazione
 * 
 * E' realizzabile in ASM o ci sono modifiche da fare?
 *
 */

#include <stdio.h>

void visualizza_prodotti(int, int*, int*, int*, int*);

void edf(int, int*, int*, int*, int*);
void hpf(int, int*, int*, int*, int*);
void output(int, int*, int*, int*, int*);

int main(int argc, char **argv){
	
	FILE *fp;
	
	int id_prodotto[10];
	int slot_produzione[10];
	int scadenza[10];
	int priorita[10];
	
	int n_prod = 0;
	
	// LETTURA FILE
	if(argc == 2){
		fp = fopen(argv[1], "r");
		if(fp){
			
			//printf("\n\n------ FILE LETTO CORRETTAMENTE -----\n");									//DEBUG

			// SCANSIONE VALORI
			while(!feof(fp)){
				fscanf(fp, "%d,%d,%d,%d", &id_prodotto[n_prod], &slot_produzione[n_prod], &scadenza[n_prod], &priorita[n_prod]);
				n_prod++;
			}

			//printf("Numero prodotti nel file: %d\n", n_prod);											//DEBUG
			//visualizza_prodotti(n_prod, id_prodotto, slot_produzione, scadenza, priorita);			//DEBUG

				

			// ALGORITMI
			int algoritmo;
			printf("--- MENU PRINCIPALE ---\nScegli algoritmo:\n 1. EDF\n 2. HPF\n\n");
			do{
				printf("  --> ");
				scanf("%d", &algoritmo);
				if(algoritmo == 1){
					//ALGORITMO ERLIEST DEADLINE FRIST (EDF)
					edf(n_prod, id_prodotto, slot_produzione, scadenza, priorita);
					printf("\n\nPianificazione EDF:\n");
					//visualizza_prodotti(n_prod, id_prodotto, slot_produzione, scadenza, priorita);	//DEBUG
				}else if(algoritmo == 2){
					//ALGORITMO HIGHER PRIORITY FIRST (HPF)
					hpf(n_prod, id_prodotto, slot_produzione, scadenza, priorita);
					printf("\n\nPianificazione HPF:\n");
					//visualizza_prodotti(n_prod, id_prodotto, slot_produzione, scadenza, priorita);	//DEBUG
				}else
					printf("Algoritmo non valido\n");
			}while(algoritmo > 2 || algoritmo < 1);

			
			// STATS
			output(n_prod, id_prodotto, slot_produzione, scadenza, priorita); 
			
			fclose(fp);
		}else
			printf("Errore apertura file\n");
	}else
		printf("Errore input argomenti\n");
			
	

	return 0;
}

void visualizza_prodotti(int n_prod, int *id_prodotto, int *slot_produzione, int *scadenza, int *priorita){
	
	for(int i = 0; i < n_prod; i++){
		printf("%3d:", id_prodotto[i]);
		printf("%2d,", slot_produzione[i]);
		printf("%2d,", scadenza[i]);
		printf("%2d\n", priorita[i]);
	}
	printf("\n");
} 

void edf(int n_prod, int *id_prodotto, int *slot_produzione, int *scadenza, int *priorita){
	
	int tmp;
	
	for(int i = 0; i < n_prod - 1; i++){
		for(int j = 0; j < n_prod - i - 1; j++){
			if(scadenza[j] > scadenza[j + 1] || (scadenza[j] == scadenza[j + 1] && priorita[j] < priorita[j + 1])){
				
				// Scambio id_prodotto
				tmp = id_prodotto[j];
				id_prodotto[j] = id_prodotto[j + 1];
				id_prodotto[j + 1] = tmp;
				
				// Scambio slot_produzione
				tmp = slot_produzione[j];
				slot_produzione[j] = slot_produzione[j + 1];
				slot_produzione[j + 1] = tmp;
				
				// Scambio scadenza
				tmp = scadenza[j];
				scadenza[j] = scadenza[j + 1];
				scadenza[j + 1] = tmp;
				
				// Scambio priorita
				tmp = priorita[j];
				priorita[j] = priorita[j + 1];
				priorita[j + 1] = tmp;
			
			}
		}
	}
}

void hpf(int n_prod, int *id_prodotto, int *slot_produzione, int *scadenza, int *priorita){
	
	int tmp;
	
	for(int i = 0; i < n_prod - 1; i++){
		for(int j = 0; j < n_prod - i - 1; j++){
			if(priorita[j] < priorita[j + 1] || (priorita[j] == priorita[j + 1] && scadenza[j] > scadenza[j + 1])){
				
				// Scambio id_prodotto
				tmp = id_prodotto[j];
				id_prodotto[j] = id_prodotto[j + 1];
				id_prodotto[j + 1] = tmp;
				
				// Scambio slot_produzione
				tmp = slot_produzione[j];
				slot_produzione[j] = slot_produzione[j + 1];
				slot_produzione[j + 1] = tmp;
				
				// Scambio scadenza
				tmp = scadenza[j];
				scadenza[j] = scadenza[j + 1];
				scadenza[j + 1] = tmp;
				
				// Scambio priorita
				tmp = priorita[j];
				priorita[j] = priorita[j + 1];
				priorita[j + 1] = tmp;
			
			}
		}
	}
}

void output(int n_prod, int *id_prodotto, int *slot_produzione, int *scadenza, int *priorita){
	
	int penalty = 0;
	int slot_totali = 0;

	for(int i = 0; i < n_prod; i++){
		printf("%d:%d\n", id_prodotto[i], slot_totali);
		slot_totali += slot_produzione[i];
		if(slot_totali > scadenza[i])
			penalty = (slot_totali - scadenza[i]) * priorita[i];
	}

	printf("Conclusione: %d\n", slot_totali);
	printf("Penalty: %d$\n\n", penalty);
}
