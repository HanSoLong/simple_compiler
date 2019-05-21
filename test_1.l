%option noyywrap
%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
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
[a-zA-Z]+[a-zA-Z0-9_]*  {yylval.c = yytext;return ID;}
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


0|([1-9]+[0-9]*) {yylval.i = strtol(yytext,NULL,0);return INT10;}
0[1-7]+[0-7]* {yylval.i = strtol(yytext,NULL,0);return INT8;}
[ \t] {}
. {}

%%

