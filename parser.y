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

	typedef struct codeTable{
		char **code_list;
		int current_line;
	}codeTable;

	typedef struct backFillNode{
		int fill_line_number;
		struct backFillNode *next;
	}backFillNode;

	struct node{
  	char *place;
		int line_number;
		backFillNode *true_fill, *false_fill, *next_fill;
  };

	struct node* node_gen();
	void print_code(codeTable* program);
	codeTable* int_program;
		
  char* place_gen();
  void calc_gen(codeTable* program, char* place, char* a, char* b, char item);
	void append_code(codeTable* program, char* code);
	void assign_gen(codeTable* program, char* place1, char* place2);
	void fillback(codeTable* program, backFillNode* node, int destiny);
	backFillNode* init_back_fill_list(int position);
	void compare_gen(codeTable* program, char* place1, char* place2, char compare_symbol);
	codeTable* init_code_table();
	backFillNode* append_next_list_with_false_list(backFillNode* false_list, backFillNode* next_list);
	void goto_gen(codeTable* program, int destiny);
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
%type <n> line_indicator

%right '='
%left '+' '-'
%left '*' '/'

%define parse.trace
%initial-action
{
	place_counter = 0;
	int_program = init_code_table();
}

%% /* The grammar follows.  */

p:l line_indicator  { fillback(int_program, $1->next_fill, $2->line_number); }
|l line_indicator p { fillback(int_program, $1->next_fill, $2->line_number); }
;

l:s ';'			{  }
;

s:ID '=' t  					{ $$=node_gen(); 
												assign_gen(int_program, $1, $3->place);
											}
|'{' p '}'						{ $$->place = $2->place; }
|IF c THEN line_indicator s 					
											{ 
												$$=node_gen();
												fillback(int_program, $2->true_fill, $4->line_number); 
												$$->next_fill = append_next_list_with_false_list($2->false_fill,$5->next_fill); 
											}
|IF c THEN line_indicator s ELSE line_indicator s		
											{ 
												fillback(int_program, $2->true_fill, $4->line_number);
												fillback(int_program, $2->false_fill, $7->line_number); 
											}
|WHILE line_indicator c line_indicator DO s					
											{ 
												$$=node_gen();
												fillback(int_program, $6->next_fill, $2->line_number);
												fillback(int_program, $3->true_fill, $4->line_number);
												$$->next_fill = $3->false_fill;
												goto_gen(int_program,$2->line_number);
											}
;

line_indicator:
	{
		$$ = node_gen();
		$$->line_number = int_program->current_line;
	}

c:t '>' t			{ $$=node_gen();
								$$->true_fill = init_back_fill_list(int_program->current_line);
								$$->false_fill = init_back_fill_list(int_program->current_line + 1);
								compare_gen(int_program,$1->place,$3->place,'>');						  							  
							}
|t '<' t			{ $$=node_gen();
								$$->true_fill = init_back_fill_list(int_program->current_line);
								$$->false_fill = init_back_fill_list(int_program->current_line + 1);
								compare_gen(int_program,$1->place,$3->place,'<');	
							}
|t '=' t			{ $$=node_gen();
								$$->true_fill = init_back_fill_list(int_program->current_line);
								$$->false_fill = init_back_fill_list(int_program->current_line + 1);
								compare_gen(int_program,$1->place,$3->place,'=');	
 							}
;

t:f					{ $$=node_gen(); $$->place = $1->place; }
|t '*' t		{ $$=node_gen(); $$->place = place_gen(); calc_gen(int_program,$$->place, $1->place,$3->place,'*'); }
|t '/' t		{ $$=node_gen(); $$->place = place_gen(); calc_gen(int_program,$$->place, $1->place,$3->place,'/'); }
|t '+' t		{ $$=node_gen(); $$->place = place_gen(); calc_gen(int_program,$$->place, $1->place,$3->place,'+'); }
|t '-' t		{ $$=node_gen(); $$->place = place_gen(); calc_gen(int_program,$$->place, $1->place,$3->place,'-'); }
;

f:'(' t ')' { $$=node_gen(); $$->place = $2->place;}
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
  yyparse();
	print_code(int_program);
	return 0;
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

void 
calc_gen(codeTable* program, char* place, char* a, char* b, char item)
{
	char *t = (char*)malloc((strlen(place)+strlen(a)+strlen(a)+strlen(&item)+strlen("=")+20)*sizeof(char));
	strcat(t,place);
	strcat(t,"=");
	strcat(t,a);
	strcat(t,&item);
	strcat(t,b);
	append_code(program,t);
}

void
compare_gen(codeTable* program, char* place1, char* place2, char compare_symbol)
{
	char temp[200];
	sprintf(temp, "if %s %c %s goto:", place1, compare_symbol, place2);
	append_code(program, temp);
	char temp1[200];
	sprintf(temp1, "goto:");
	append_code(program, temp1);
}

void
goto_gen(codeTable* program, int destiny)
{
	char* temp = malloc(200*sizeof(char));
	if(destiny >= 0)
	{
		sprintf(temp, "goto: %d", destiny);
	}
	else
	{
		sprintf(temp, "goto");
	}
	append_code(program,temp);
}

void
assign_gen(codeTable* program, char* place1, char* place2)
{
	char* temp = malloc(200*sizeof(char));
	sprintf(temp, "%s = %s", place1, place2);
	append_code(program,temp);
}

struct node*
node_gen()
{
	struct node* temp = (struct node*)malloc(200*sizeof(char));;
	temp->place = (char*)malloc(200*sizeof(char));
	temp->line_number = int_program->current_line;
	temp->true_fill = NULL;
	temp->false_fill = NULL;
	temp->next_fill = NULL;
	return temp;
}

codeTable*
init_code_table()
{
	codeTable* temp = (codeTable*)malloc(sizeof(codeTable));
	temp->current_line = 0;
	temp->code_list = (char**)malloc(100*sizeof(char*));
	return temp;
}

backFillNode*
init_back_fill_list(int position)
{
	backFillNode* head = (backFillNode*)malloc(sizeof(backFillNode));
	head->fill_line_number = position;
	head->next = NULL;
	return head;
}

void 
append_code(codeTable* program, char* code)
{
	program->code_list[program->current_line] = malloc(sizeof(code)+20);
	strcpy(program->code_list[program->current_line],code);
	program->current_line++;
}

void 
fillback(codeTable* program, backFillNode* node, int destiny)
{
	if(node != NULL)
	{
		backFillNode* temp = node;
		char line[30];
		sprintf(line, " %d", destiny);
		while(temp != NULL)
		{
			if(temp->fill_line_number < program->current_line)
			{
				strcat(program->code_list[temp->fill_line_number], line);
			}
			temp = temp->next;
		}
	}
}

void
print_code(codeTable* program){
	int i = 0;
	for (i = 0; i < program->current_line; i++)
		printf("%2d: %s\n", i, program->code_list[i]);
}

backFillNode*
append_next_list_with_false_list(backFillNode* false_list, backFillNode* next_list)
{
	backFillNode* temp = NULL;
	if(next_list != NULL){
		false_list->next = next_list;
	}
	temp = false_list;
	return temp;
}
