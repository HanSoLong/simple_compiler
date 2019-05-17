%option noyywrap
%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
%}
%%

00.* {yylval = 1111;return 1111; }
0x[0-9a-fA-F]+[0-9a-fA-F]* {yylval = strtol(yytext,NULL,0);return INT16;}
[0-9]+[a-zA-Z_]+ {yylval = 1111;return 1111; }
[0-9A-Za-z]+if|if[0-9A-Za-z]+|[0-9A-Za-z]+if[0-9A-Za-z]+ {yylval = 1111;return 1111; }
"if" {yylval = 0; return IF; }
"then" {yylval = 0; return THEN; }
"else" {yylval = 0; return ELSE; }
"while" {yylval = 0; return WHILE; }
"do" {yylval = 0; return DO; }
[a-zA-Z]+[a-zA-Z0-9_]*  {yylval = 0;return ID;}
"+" {yylval =0;return '+';}
"-" {yylval =0;return '-';}
"*" {yylval =0;return '*';}
"/" {yylval =0;return '/';}
">" {yylval =0;return '>';}
"<" {yylval =0;return '<';}
"=" {yylval =0;return '=';}
"(" {yylval =0;return '(';}
")" {yylval =0;return ')';}
";" {yylval =0;return ';';}
"{" {yylval =0;return '{';}
"}" {yylval =0;return '}';}


0|([1-9]+[0-9]*) {yylval = strtol(yytext,NULL,0);return INT10;}
0[1-7]+[0-7]* {yylval = strtol(yytext,NULL,0);return INT8;}
[ \t] {}
. {}

%%

