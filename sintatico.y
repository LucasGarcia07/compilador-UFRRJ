%{
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <fstream>
#include <vector>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;

struct atributos
{
	string label;
	string trans;
	string type;
};

int yylex(void);
void yyerror(string);
string gentempcode();
%}

%token TK_FIM TK_ERROR
%token TK_PARAM
%token TK_NUM TK_CHAR TK_BOOL
%token TK_MAIN TK_ID TK_INT_TYPE TK_FLOAT_TYPE TK_CHAR_TYPE 
%token TK_DOUBLE_TYPE TK_LONG_TYPE TK_STRING_TYPE TK_BOOL_TYPE
%token TK_BREAK
%token TK_AND
%token TK_OR
%token TK_NOT
%token TK_GTE
%token TK_LTE
%token TK_DIFFERENCE
%token TK_EQUAL

%start S

%left '+' '-'
%left '*' '/'
%left '<' '>' TK_LTE TK_GTE TK_DIFFERENCE TK_EQUAL
%left TK_AND TK_OR TK_NOT

%%

S 			: TK_INT_TYPE TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.trans << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.trans = $2.trans;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.trans = $1.trans + $2.trans;
			}
			|
			{
				$$.trans = "";
			}
			;

COMANDO 	: E ';'
			;

E 			: E '+' E
			{
				string temp = gentempcode();
				
				if($1.type == $3.type){
					$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " + " + $3.label + $3.type + " POW " + ";\n";
					$$.label = temp;
				}else{
					$$.type = "err";
					$$.trans = "err";
				}	
			}
			| E '-' E
			{
				string temp = gentempcode();
				if($1.type == $3.type){
					$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " - " + $3.label + ";\n";
					$$.label = temp;
				}else{
					$$.type = "err";
					$$.trans = "err";
				}	
				
			}
			| E '*' E
			{
				string temp = gentempcode();
				if($1.type == $3.type){
					$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " * " + $3.label + ";\n";
					$$.label = temp;
				}else{
					$$.type = "err";
					$$.trans = "err";
				}	
			}
			| E '/' E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " / " + $3.label + ";\n";
			}
			| E '<' E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " < " + $3.label + ";\n";
			}
			| E '>' E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " > " + $3.label + ";\n";
			}
			| E '<=' E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " <= " + $3.label + ";\n";
			}
			| E '>=' E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " >=" + $3.label + ";\n";
			}
			| E '==' E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " ==" + $3.label + ";\n";
			}
			| E '!=' E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " !=" + $3.label + ";\n";
			}
			| E TK_AND E
			{
				string temp = gentempcode();

				if(($1.type == "bool") && ($3.type == "bool")){
					
					$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
						" = " + $1.label + " && " + $3.label + ";\n";
					$$.label = temp;
				}else{
					$$.type = "err" + $1.type + " " + $3.type + " POW";
					
				}
			}
			| E TK_OR E
			{
				string temp = gentempcode();
				
				if($1.type == $3.type){
					
					$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
						" = " + $1.label + " || " + $3.label + ";\n";
					$$.label = temp;
				}else{
					$$.type = "err";
					$$.trans = "err";
				}
			}
			| E 'not' E
			{	
				string temp = gentempcode();

				if($3.type == "bool"){
					$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " ! " + $3.label + ";\n";
					$$.label = temp;
				}else{
					$$.type = "err";
					$$.trans = "err";
				}
			}
			| TK_ID '=' E
			{
				$$.trans = $1.trans + $3.trans + "\t" + $1.label + " = " + $3.label + ";\n";
			}
			| TK_NUM
			{
				$$.label = gentempcode();
				$$.trans = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				$$.label = gentempcode();
				$$.trans = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			;

%%

#include "lex.yy.c"

int yyparse();

string gentempcode()
{
	var_temp_qnt++;
	return "t" + std::to_string(var_temp_qnt);
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	yyparse();

	return 0;
}

void yyerror(string MSG)
{
	cout << MSG << endl;
	exit (0);
}				
