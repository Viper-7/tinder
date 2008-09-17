/* 
*
*   txt2bf - an ascii text to bf code convertor
*
*   (c) 2001 Sean Geoghegan 
*
*   This software is available free of charge for distribution,
*   modification and use (by executing the program) as long as the
*   following conditions are met: 
*
*   1. Every work copied or derived from this software distributed in any
*      form must come with this license; 
*   2. The only permitted change to this license is adding one's name
*      in the authors section when having modified the software. 
*
*   THE AUTHORS CANNOT BE HELD RESPONSIBLE FOR ANY
*   DIRECT OR INDIRECT HARM THIS SOFTWARE MIGHT CAUSE.
*
*    
*   The input file is given as a commandline arg,
*   the output file is written to file with the 
*   same name as the inut file but a .bf extenstion.
*
*   Author: Sean Geoghegan
*   Date: 21/12/2001
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#define VERSION "0.2"

#define INBUFFER  1001
#define BFDATA 0
#define BFCOUNTER 1
#define DEBUG 0

int errno;

typedef struct FACTOR_TYPE {
	int x;
	int y;
	int rem;
}FACTOR, *FACTOR_PTR;


/********************************************
*
*  Gets the factor with the least difference
*   and a remainder if the number is prime
*/
FACTOR get_closest_factors(int n){

	FACTOR factor;

	factor.x = (int)sqrt(n);
	factor.y = factor.x;

	while ( (factor.x * (factor.y + 1)) <= n )
		factor.y++;

	//factor.y--;
	factor.rem = n - (factor.x * factor.y);

	if(DEBUG) printf("Factors for %d are x=%d y=%d rem=%d\n",n,factor.x,factor.y,factor.rem);

	return factor;
}


/********************************************
*
*  Chops of the extension of a file, if there is
*  one and replaces it with .bf
*/
char* get_out_file(char* infile){

	char *outfile = calloc(strlen(infile)+4,1);
	char *p = outfile;

	strcpy(outfile,infile);
	
	while ( 1 ){

		if(*p == '.'){
			*++p = 'b';
			*++p = 'f';
			*++p = 0;
			break;
		} else if ( *p == 0 ){

			*p++ = '.';
			*p++ = 'b';
			*p++ = 'f';
			*p = 0;
			break;
		}

		p++;
	}
	return outfile;
}

/***************************************************
*
*   Appends a null terminated string to a char 
*   pointer.  Returns a pointer the end of the 
*   new string. The first character of str is
*   placed in the memory location defined by ptr
*
*   Condition: It is up to the caller to make sure
*   that the memory after the pointer has been allocated
*   bad things could happen otherwise.
*
*   Params:  ptr the pointer to a char to append to
*            str the string to append to the pointer
*
*   Returns: pointer the end of the new string
*/
char* append_to_ptr(char* ptr, char* str){

	//printf("appending\n");

	while ( *str > 0 ){
		*ptr = *str;
		ptr++;
		str++;
	}
	
	return ptr;
}

/**************************************************
*
*   Makes a string of character c of length n
*
*   The return string needs to be freed after use
*/
char* make_string(int n, char c){
	
	int i;
	char *str = calloc(n+1,1);
	char *p =str;

	//printf("Make String: %d %c\n",n,c);

	for (i=0;i<n;i++){
	
		*p++ = c;
	}
	*p = 0;
	return str;
}
		
		
/*************************************************
*
*   This does most of the work.  It converts a char[]
*   of ascii text into a char[] of bf code.
*/
char* convert(char* input){
	
	char* bfcode = calloc(5000,1);
	char* codeptr = bfcode;
	char* txtptr = input;
	char  bfdata = 0;
	int diff = 0;
	char *tempstr;


	while ( *txtptr > 0 ){
	
		diff = *txtptr - bfdata;

		// when have to increase the char
		if( diff > 0 ){

			//only find factors if the diff is
			//greater that 4			
			if ( diff > 4 ){

				FACTOR factors = get_closest_factors(diff);
				tempstr = make_string(factors.x,'+');
				*codeptr++ = '>';
				codeptr = append_to_ptr(codeptr,tempstr);
				codeptr = append_to_ptr(codeptr,"[<");
				free(tempstr);
				tempstr = make_string(factors.y,'+');
				codeptr = append_to_ptr(codeptr,tempstr);
				free(tempstr);
				codeptr = append_to_ptr(codeptr,">-]<");
	
				if(factors.rem > 0){
					tempstr = make_string(factors.rem,'+');
					codeptr = append_to_ptr(codeptr,tempstr);
					free(tempstr);
				}

			} else { //otherwise jsut increment it

				tempstr = make_string(diff,'+');
				codeptr = append_to_ptr(codeptr,tempstr);
				free(tempstr);
			}
			
		} else if ( diff < 0 ){ //same as above excpet decrementing

			if ( diff < -4 ){

				FACTOR factors = get_closest_factors(-diff);
				tempstr = make_string(factors.x,'+');
				*codeptr++ = '>';
				codeptr = append_to_ptr(codeptr,tempstr);
				codeptr = append_to_ptr(codeptr,"[<");
				free(tempstr);
				tempstr = make_string(factors.y,'-');
				codeptr = append_to_ptr(codeptr,tempstr);
				free(tempstr);
				codeptr = append_to_ptr(codeptr,">-]<");
	
				if(factors.rem > 0){
					tempstr = make_string(factors.rem,'-');
					codeptr = append_to_ptr(codeptr,tempstr);
					free(tempstr);
				}


			} else {
	
				tempstr = make_string(-diff,'-');
				codeptr = append_to_ptr(codeptr,tempstr);
				free(tempstr);
			}
			
		}			
		
		bfdata = *txtptr;	
		*codeptr++ = '.';
		txtptr++;
	}
	
	*codeptr = 0;	

	return bfcode;
}

/****************************************************
*  
*  Main method. 
*  
*  Accepts the input file as a command line arg
*  opens the file, reads it into an array and 
*  calls convert on the data
*/
int main(int argc, char *argv[]) {
	
	FILE* inputFile;
	FILE* outputFile;
	char input[INBUFFER];
	char *p = input;
	char c;
	char *outfile, *code;
	//char *test;
	
	if ( argc < 2 ){
		printf("Usage: txt2bf <input file>\n");
		return 0;
	} 

	if ( (strcmp(argv[1],"-V")) == 0 ){
		printf("txt2bf: ASCII Text to Brainfuck Convertor Version %s\n",VERSION);
		return 0;
	}

	if ( (inputFile = fopen(argv[1],"r")) ){

		//read the file into a buffer
		while((c = fgetc(inputFile)) > 0){

			if((p-input) >= (INBUFFER * sizeof(*p))){
				printf("Buffer overflow. Input file size limit of %d\n",INBUFFER-1);
				return 1;
			}

			*p = c;
			p++;
			
		}
		fclose(inputFile);
		*p = 0;

		outfile = get_out_file(argv[1]);
	
		
		if ( (outputFile = fopen(outfile,"w")) ){
			code = convert(input);
			fputs(code,outputFile);
			fclose(outputFile);
			free(code);

		} else {
			printf("Could not open file for writing: %s\nError ID: %d\n",outfile,errno);
		}
 		
		printf("Writing:  %s\n",outfile);
		free (outfile);
			
	} else {
		
		printf("Could not open file: %s\nError id: %d\n",argv[1],errno);
	}	
	return 0;
}
