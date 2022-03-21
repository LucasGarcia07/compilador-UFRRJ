%{
#include <string>
%}

ESPACO      [ \t]
DIGITO      [0-9]
MAIUSCULA   [A-Z]
MINUSCULA   [a-z]
LETRA       {MAIUSCULA}|{MINUSCULA}

DELIM       {ESPACO}+
INT         {DIGITO}+
FLOAT       {DIGITO}+(\.{DIGITO}*)?([eE][\-\+]?{DIGITO}+)?[fF]
DOUBLE	    {DIGITO}+(\.{DIGITO}*)?([eE][\-\+]?{DIGITO}+)?[dD]?
CHAR        \'({LETRA}|{INT})\'
STRING      \"(({LETRA}|{DIGITO})*)\"
BOOL        "true"|"false"


ID          {LETRA}({LETRA}|{INT})*

%%

[\n]        { yylineno++; }

{DELIM} 	{}

"main"		{ return TK_MAIN; }

"int"		{ yylval.trans = yytext; return TK_INT_TYPE; }
"float"		{ yylval.trans = yytext; return TK_FLOAT_TYPE; }
"double"	{ yylval.trans = yytext; return TK_DOUBLE_TYPE; }
"long"		{ yylval.trans = yytext; return TK_LONG_TYPE; }
"char"		{ yylval.trans = yytext; return TK_CHAR_TYPE; }
"string"	{ yylval.trans = yytext; return TK_STRING_TYPE; }
"bool"      { yylval.trans = yytext; return TK_BOOL_TYPE; }

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }
"=="        { return TK_EQUAL; }
"!="        { return TK_DIFFERENCE; }
">="        { return TK_GTE; }
"<="        { return TK_LTE; }
">"         { return TK_GT; }
"<"         { return TK_LT; }
"and"       { return TK_AND; }
"or"        { return TK_OR; }
"not"       { return TK_NOT; }

{STRING} {
    yylval.trans = "";
    yylval.label = yytext;
    yylval.type = "string";
    return TK_STRING;
}

{INT} {
    yylval.trans = "";
    yylval.label = yytext;
    yylval.type = "int";
    return TK_NUM;
}

{DOUBLE} { 
    yylval.trans = "";
    yylval.label = yytext;
    yylval.type = "double";
    return TK_NUM;
}

{FLOAT} { 
    yylval.trans = "";
    yylval.label = yytext;
    yylval.type = "float";
    return TK_NUM;
}

{CHAR}      {
    yylval.trans = "";
    yylval.label = yytext;
    yylval.type = "char";
    return TK_CHAR;
}

{BOOL} {
    yylval.trans = "";
    yylval.label = yytext;
    yylval.type = "bool";
    return TK_BOOL;
}

{ID} { 
    yylval.trans = "";
    yylval.label = yytext; 
    return TK_ID; 
}

.			{ *yytext; }

%%
