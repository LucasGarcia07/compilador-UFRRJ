%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
INT {DIGITO}+
FLOAT   	{DIGITO}+(\.{DIGITO}*)?([eE][\-\+]?{DIGITO}+)?[fF]
DOUBLE		{DIGITO}+(\.{DIGITO}*)?([eE][\-\+]?{DIGITO}+)?[dD]?
CHAR \'({LETRA}|{INT})\'
BOOL "true"|"false"

ID {LETRA}({LETRA}|{INT})*

%%

"\n"		{}

{DELIM} 	{}

"main"		{ return TK_MAIN; }

"int"		{ yylval.traducao = yytext; return TK_INT_TYPE; }
"float"		{ yylval.traducao = yytext; return TK_FLOAT_TYPE; }
"double"	{ yylval.traducao = yytext; return TK_DOUBLE_TYPE; }
"long"		{ yylval.traducao = yytext; return TK_LONG_TYPE; }
"char"		{ yylval.traducao = yytext; return TK_CHAR_TYPE; }
"string"	{ yylval.traducao = yytext; return TK_STRING_TYPE; }
"bool"      { yylval.traducao = yytext; return TK_BOOL_TYPE; }

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }
"=="        { return TK_EQUAL; }
"!="        { return TK_DIFFERENCE; }
">="        { return TK_GTE; }
"<="        { return TK_LTE; }
"and"       { return TK_AND; }
"or"        { return TK_OR; }
"not"        { return TK_NOT; }

{INT}		{
    yylval.traducao = "";
    yylval.label = yytext;
    yylval.tipo = "int";
    return TK_NUM;
}

{DOUBLE}    { 
    yylval.traducao = "";
    yylval.label = yytext;
    yylval.tipo = "double";
    return TK_NUM;
}

{FLOAT}     { 
    yylval.traducao = "";
    yylval.label = yytext;
    yylval.tipo = "float";
    return TK_NUM;
}

{CHAR}      {
    yylval.traducao = "";
    yylval.label = yytext;
    yylval.tipo = "char";
    return TK_CHAR;
}

{BOOL}      {
    yylval.traducao = "";
    yylval.label = yytext;
    yylval.tipo = "bool";
    return TK_BOOL;
}

{ID}		{ 
    yylval.traducao = "";
    yylval.label = yytext; 
    return TK_ID; 
}

.			{ *yytext; }

%%
