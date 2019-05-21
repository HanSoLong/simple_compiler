/* Infix notation calculator.  */

%{
	#include <ctype.h>
	#include <stdio.h>
	#include<string.h>
	#include<stdlib.h>
	#define YYDEBUG 1
	int place_counter;
  int yylex();
  void yyerror(const char *s);
  extern FILE* yyin;
  struct node{
  	char *code;
  	char *place;
  };
  char* place_gen();
  char* calc_gen(char* place, char* a, char* b, char item);
	struct node* node_gen();
%}

%union{
	char *c;
	long int i;
	struct node * n;
}

%token <i> INT8
%token <i> INT10
%token <i> INT16
%token <c> ID
%token IF ELSE THEN WHILE DO

%type <n> p
%type <n> l
%type <n> s
%type <n> c
%type <n> t
%type <n> f

%right '='
%left '+' '-'
%left '*' '/'

%define parse.trace
%initial-action
{
	place_counter = 0;
}
%% /* The grammar follows.  */

p:l  {  }
|l p {  }
;

l:s ';'			{  }
;

s:ID '=' t  					{  }
|'{' p '}'						{  }
|IF c THEN s 					{ printf("if s goto true\n"); printf("goto next\n");}
|IF c THEN s ELSE s		{ printf("if s goto ture\n"); printf("goto else\n"); }
|WHILE c DO s					{  }
;

c:t '>' t			{  }
|t '<' t			{  }
|t '=' t			{  }
;

t:f					{ $$=node_gen(); $$->place = $1->place; $$->code = $1->code; }
|t '*' t		{ $$=node_gen(); $$->place = place_gen(); $$->code = calc_gen($$->place, $1->place,$3->place,'*'); printf("%s\n",$$->code); }
|t '/' t		{ $$=node_gen(); $$->place = place_gen(); $$->code = calc_gen($$->place, $1->place,$3->place,'/'); printf("%s\n",$$->code); }
|t '+' t		{ $$=node_gen(); $$->place = place_gen(); $$->code = calc_gen($$->place, $1->place,$3->place,'+'); printf("%s\n",$$->code); }
|t '-' t		{ $$=node_gen(); $$->place = place_gen(); $$->code = calc_gen($$->place, $1->place,$3->place,'-'); printf("%s\n",$$->code); }
;

f:'(' t ')' { $$=node_gen(); $$->place = $2->place; $$->code = $2->code; }
|ID					{ $$=node_gen(); $$->place = $1; }
|INT8				{ $$=node_gen(); sprintf($$->place, "%d", (int)$1); }
|INT10			{ $$=node_gen(); sprintf($$->place, "%d", (int)$1); }
|INT16			{ $$=node_gen(); sprintf($$->place, "%d", (int)$1); }
;

%%

int
main (int argc,char* argv[])
{
	if(argc>1)
	{
		if(!(yyin = fopen(argv[1], "r"))) 
		{
			perror(argv[1]);
			return (1);
		}
	}
	yydebug = 0;
  return yyparse ();
}

/* Called by yyparse on error.  */
void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}

char* 
place_gen()
{
	char *t = (char*)malloc(20*sizeof(char));
	char *current_index = (char*)malloc(20*sizeof(char));
	sprintf(current_index, "%d", place_counter++);
	strcat(t,"t");
	strcat(t,current_index);
	return t;
}

char* 
calc_gen(char* place, char* a, char* b, char item)
{
	char *t = (char*)malloc((strlen(place)+strlen(a)+strlen(a)+strlen(&item)+strlen("=")+2)*sizeof(char));
	strcat(t,place);
	strcat(t,"=");
	strcat(t,a);
	strcat(t,&item);
	strcat(t,b);
	return t;
}

struct node*
node_gen(){
	struct node* temp = malloc(sizeof(struct node));
	temp->code = (char*)malloc(200*sizeof(char));
	temp->place = (char*)malloc(200*sizeof(char));
	return temp;
}

