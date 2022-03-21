%{
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <set>
#include <fstream>
#include <vector>
#include <list>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;

struct atributos
{
	string label;
	string trans;
	string type;
};

typedef struct
{
	string ref;
	string type;
} variable;

map<string,variable> variables;

map<string,set<string>> conversion_map = {
	{"int", {"double", "float", "bool", "long"}},
	{"double", {"float", "int", "long"}},
	{"float", {"double", "int", "long"}},
	{"bool", {"int", "long"}}};

int yylex(void);
void yyerror(string);
string gentempcode();
%}

%token TK_FIM TK_ERROR
%token TK_PARAM
%token TK_STRING
%token TK_NUM TK_CHAR TK_BOOL
%token TK_MAIN TK_ID TK_INT_TYPE TK_FLOAT_TYPE TK_CHAR_TYPE
%token TK_DOUBLE_TYPE   
%token TK_LONG_TYPE TK_STRING_TYPE TK_BOOL_TYPE
%token TK_BREAK
%token TK_AND
%token TK_OR
%token TK_NOT
%token TK_GTE
%token TK_LTE
%token TK_GT
%token TK_LT
%token TK_DIFFERENCE
%token TK_EQUAL

%start S

%left TK_LT TK_GT TK_LTE TK_GTE TK_DIFFERENCE TK_EQUAL
%left '+' '-'
%left '*' '/'

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
					$$.trans = $1.trans + $3.trans + "\t" + $1.type + " " +  temp + ";\n" +
					"\t" + temp + " = " + $1.label + " + " + $3.label + ";\n";
					$$.label = temp;
				}else{
					yyerror("+ operator expectates a values with the same type.");
				}
			}
			| E '-' E
			{
				string temp = gentempcode();
				if($1.type == $3.type){
					$$.trans = $1.trans + $3.trans + "\t" + $1.type + " " +  temp + ";\n" +
					"\t" + temp + " = " + $1.label + " - " + $3.label + ";\n";
					$$.label = temp;
				}else{
					yyerror("- operator expectates a values with the same type.");
				}	
				
			}
			| E '*' E
			{
				string temp = gentempcode();
				if($1.type == $3.type){
					$$.trans = $1.trans + $3.trans + "\t" + $1.type + " " +  temp + ";\n" +
					"\t" + temp + " = " + $1.label + " * " + $3.label + ";\n";
					$$.label = temp;
				}else{
					yyerror("* operator expectates a values with the same type.");
				}	
			}
			| E '/' E
			{
				string temp = gentempcode();
				if($1.type == $3.type){
					$$.trans = $1.trans + $3.trans + "\t" + $1.type + " " +  temp + ";\n" +
					"\t" + temp + " = " + $1.label + " / " + $3.label + ";\n";
					$$.label = temp;
				}else
				{
					yyerror("/ operator expectates a values with the same type.");
				}
			}
			| E TK_LT E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + "bool " + $$.label + 
					" = " + $1.label + " < " + $3.label + ";\n";
			}
			| E TK_GT E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + "bool " + $$.label + 
					" = " + $1.label + " > " + $3.label + ";\n";
			}
			| E TK_LTE E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " <= " + $3.label + ";\n";
			}
			| E TK_GTE E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " >=" + $3.label + ";\n";
			}
			| E TK_EQUAL E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " ==" + $3.label + ";\n";
			}
			| E TK_DIFFERENCE E
			{
				$$.label = gentempcode();
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " !=" + $3.label + ";\n";
			}
			| E TK_AND E
			{
				string temp = gentempcode();
					
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " && " + $3.label + ";\n";
				$$.label = temp;
			}
			| E TK_OR E
			{
				string temp = gentempcode();
					
				$$.trans = $1.trans + $3.trans + "\t" + $$.label + 
					" = " + $1.label + " " + " || " + $3.label + ";\n";
				$$.label = temp;
			}
			| TK_NOT E
			{	
				string temp = gentempcode();

				$$.trans = $2.trans + "\t" + $2.label + 
				" = " + "!" + $2.label + ";\n";
				$$.label = temp;
			}
			
			| TK_ID '=' E
			{
				if (variables.find($1.label) != variables.end()){
					variable current = variables[$1.label];
					
					if(current.type == $3.type){
						$$.type = $3.type;
						$$.trans = $1.trans + $3.trans  + "\t" + $1.label + " = " + $3.label + ";\n";
					}else
					{
						yyerror($3.type + " value is being assigned to a " + current.type + " variable.");
					}
					
				
				}else
				{
					variables[$1.label] = {$1.trans, $3.type};
					$$.type = $3.type;
					$$.trans = $1.trans + $3.trans  + "\t" + $3.type + " " + $1.label + " = " + $3.label + ";\n";
				}
			}
			| '('TYPE')' E{
				string temp = gentempcode();
				
				set<string> possible_types = conversion_map[$4.type];
				if(possible_types.size() == 0) {
					yyerror("There isn't a native cast from " + $4.type + " to other types!");
				} else if(possible_types.find($2.trans) != possible_types.end()) {
					$$.trans = $4.trans + "\t" + $2.trans + " " + temp + ";\n" + "\t" + temp + " = " + "(" + $2.trans + ") " + $4.label + ";\n";
					$$.label = temp;
					$$.type = $2.trans;
				} else{
					yyerror("There isn't a native cast from \033[1;31m" + $4.type + "\033[0m to \033[1;31m"+ $2.trans +"\033[0m!");
				}
			}
			
			| VALUE {
				$$.trans = $1.trans;
				$$.label = $1.label;
				$$.type = $1.type;
			};

TYPE 		: TK_INT_TYPE
			| TK_FLOAT_TYPE
			| TK_DOUBLE_TYPE
			| TK_LONG_TYPE
			| TK_CHAR_TYPE
			| TK_STRING_TYPE
			| TK_BOOL_TYPE;

VALUE       : TK_STRING
			{
				$$.label = gentempcode();	
				$$.trans = "\t" + $1.type + " " + $$.label + ";\n" + "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_NUM {
				string temp = gentempcode();
				string value = $1.label;
				
				if ($1.type == "float") {
					value = to_string(stof(value));
				} else if ($1.type == "double") {
					value = to_string(stod(value));
				} else if ($1.type == "long") {
					value = to_string(stol(value));
				}	
				$$.trans = "\t" + $1.type + " " + temp + ";\n" + "\t" + temp + " = " + value + ";\n";
				$$.label = temp;
			}
			| TK_BOOL {
				string temp = gentempcode();
				if($1.label == "falso"){
					$1.label = "0";
				}else{
					$1.label = "1";
				}
				$$.trans = "\tint " + temp + " = " + $1.label + ";\n";
				$$.label = temp;
			}
			| TK_ID
			{
				$$.label = gentempcode();
				$$.trans = "\t" + $$.label + " = " + $1.label + ";\n";
			};
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
	// "\033[1;31mbold red text\033[0m\n"
	cout << "At line " + to_string(yylineno - 1) + ": " + MSG <<endl;
	exit (0);
}				
