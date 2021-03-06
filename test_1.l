%option noyywrap
%option yylineno
%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
char* copy_ID_name(char* text);
%}
%%

00.* {return 1111; }
0x[0-9a-fA-F]+[0-9a-fA-F]* {yylval.i = strtol(yytext,NULL,0);return INT16;}
[0-9]+[a-zA-Z_]+ {return 1111; }
[0-9A-Za-z]+if|if[0-9A-Za-z]+|[0-9A-Za-z]+if[0-9A-Za-z]+ {return 1111; }
"if" {return IF; }
"then" {return THEN; }
"else" {return ELSE; }
"while" {return WHILE; }
"do" {return DO; }
"interrupt" {return 0;}
[a-zA-Z]+[a-zA-Z0-9_]*  {yylval.c = copy_ID_name(yytext);return ID;}
"+" {return '+';}
"-" {return '-';}
"*" {return '*';}
"/" {return '/';}
">" {return '>';}
"<" {return '<';}
"=" {return '=';}
"(" {return '(';}
")" {return ')';}
";" {return ';';}
"{" {return '{';}
"}" {return '}';}
\n { }

0|([1-9]+[0-9]*) {yylval.i = strtol(yytext,NULL,0);return INT10;}
0[1-7]+[0-7]* {yylval.i = strtol(yytext,NULL,0);return INT8;}
[ \t] {}
. {}

%%
char* 
copy_ID_name(char* text)
{
	char*temp = malloc((strlen(yytext)+1)*sizeof(char));
	int i = 0;
	for(i=0;i<strlen(yytext);i++)
	{
		temp[i] = yytext[i];
	}
	strcat(temp,"");
	return temp;
}
