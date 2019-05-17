/* Infix notation calculator.  */

%{
	#include <ctype.h>
	#include <stdio.h>
	#define YYDEBUG 1
  int yylex();
  void yyerror(const char *s);
%}

%token INT8 INT10 INT16 ID
%token IF ELSE THEN WHILE DO

%define parse.trace

%% /* The grammar follows.  */

p:l  { printf (" p reduced from l -->"); }
|l p { printf (" p reduced from l p -->"); }
;

l:s			{ printf (" l reduced from s -->"); }
;

s:ID '=' e						{ printf (" s reduced from ID=e -->"); }
|'{' p '}'						{ printf (" s reduced from {P}  -->"); }
|IF c THEN s 					{ printf (" s reduced from if then -->"); }
|IF c THEN s ELSE s		{ printf (" s reduced from if then else-->"); }
|WHILE c DO s					{ printf (" s reduced from while do -->"); }
;

c:e '>' e			{ printf (" c reduced from e>e -->"); }
|e '<' e			{ printf (" c reduced from e<e -->"); }
|e '=' e			{ printf (" c reduced from e=e -->"); }
|c ';'				{}
;

e:t           { printf (" e reduced from t -->"); }
|e '+' t			{ printf (" e reduced from e+t -->"); }
|e '-' t			{ printf (" e reduced from e-t -->"); }
;

t:f					{ printf (" t reduced from f -->"); }
|t '*' f			{ printf (" t reduced from t*f -->"); }
|t '/' f			{ printf (" t reduced from t/f -->"); }
;

f:'(' e ')' { printf (" f reduced from (e) -->"); }
|ID					{ printf (" f reduced from ID -->"); }
|INT8				{ printf (" f reduced from INT8 -->"); }
|INT10			{ printf (" f reduced from INT10 -->"); }
|INT16			{ printf (" f reduced from INT16 -->"); }
;


%%

int
main (void)
{
	yydebug = 1;
  return yyparse ();
}

/* Called by yyparse on error.  */
void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}
