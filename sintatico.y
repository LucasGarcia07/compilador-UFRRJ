%{
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <fstream>
#include <vector>
#include <stdlib.h> 
#include <stdio.h>  
#include <string.h>

#define YYSTYPE attributes

using namespace std;

struct attributes {
	string label;  // nome da variável usada no cód. intermediário (ex: "t0")
	string type;   // tipo no código intermediário (ex: "int")
	string transl; // código intermediário (ex: "int t11 = 1;")
	int lenght;    // tamanho do vetor de char
};

typedef struct var_info {
	string type; // tipo da variável usada no cód. intermediário (ex: "int")
	string name; // nome da variável usada no cód. intermediário (ex: "t0")
	int collumn; // número de colunas da matriz 
	int line;    // número de linhas na matriz
} var_info;

string type1, type2, op, typeRes, value;
ifstream opMapFile, padraoMapFile;

vector<string> decls;
map<string, string> opMap;
vector<map<string, var_info>> varMap;
map<string, string> padraoMap;
vector<int> stack;
int tempGen = 0;
int beginGen = 0;
int endGen = 0;
int beginGenLoop = 1;
int endGenLoop = 1;
int openBlock = 0;
int controlTiesContinue = 1;
int controlTiesBreak = 1;

string getNextVar();
string getCurrentVar();

string getBeginLabel();
string getPrevBeginLabel();
string getCurrentBeginLabel();

string getBeginLabelLoop();
string getPrevBeginLabelLoop ();
string getCurrentBeginLabelLoop ();
string getCurrentBeginLabelContinue();
void setBeginLabelLoop(int );

string getEndLabel();
string getEndLabelLoop();

string getCurrentEndLabel();
string getPrevEndLabelLoop ();
string getCurrentEndLabelLoop();
string getCurrentEndLabelLoopBreak();
void setEndLabelLoop(int );

void trueFlagOpenBlock();
void falseFlagOpenBlock();
int getFlagOpenBlock();

void pushContext();
void popContext();

int findValue(string );
var_info* findVar(string label);
void insertVar(string label, var_info info);
void insertGlobalVar(string label, var_info info);

int yylex(void);
void yyerror(string);
%}

%token TK_PARAM
%token TK_NUM TK_CHAR TK_STRING TK_BOOL
%token TK_MAIN TK_ID TK_INT_TYPE TK_FLOAT_TYPE TK_CHAR_TYPE 
%token TK_DOUBLE_TYPE TK_LONG_TYPE TK_STRING_TYPE TK_BOOL_TYPE
%token TK_FIM TK_ERROR
%token TK_BREAK
%token TK_AND
%token TK_OR
%token TK_NOT
%token TK_GTE
%token TK_LTE
%token TK_DIFFERENCE
%token TK_EQUAL
%token TK_IF
%token TK_ELIF
%token TK_ELSE
%token TK_WHILE
%token TK_DO
%token TK_FOR
%token TK_SWITCH
%token TK_CASE
%token TK_DEFAULT
%token TK_PRINT
%token TK_ENDL
%token TK_INCREMENT
%token TK_DECREMENT
%token TK_MORE_EQUAL
%token TK_LESS_EQUAL
%token TK_MULTIPLY_EQUAL
%token TK_DIVIDE_EQUAL
%token TK_QUESTION
%token TK_EXPONENT
%token TK_FACTORIAL
%token TK_CONTINUE
%token TK_BREAK_LOOP
%token TK_GLOBAL
%token TK_READ
%token TK_FUNCTION
%token TK_UNARIO

%start S

%left TK_EXPONENT TK_FACTORIAL
%left TK_LT TK_GT TK_LTE TK_GTE TK_DIFFERENCE TK_EQUAL
%left '*' '/'
%left '+' '-'
%left TK_INCREMENT TK_DECREMENT
%left TK_MORE_EQUAL TK_LESS_EQUAL TK_MULTIPLY_EQUAL TK_DIVIDE_EQUAL
%left TK_AND TK_OR TK_NOT
%left TK_IF TK_ELIF TK_ELSE TK_WHILE TK_DO TK_FOR TK_SWITCH


%%
S			: PUSH_SCOPE T POP_SCOPE {
				$$.transl = $2.transl;
			};
T 			: TK_INT_TYPE TK_MAIN '(' ')' BLOCK {
				cout << 
				"#include <iostream>" << endl <<
				"#include <string.h>" << endl <<
				"#include <stdio.h>" << endl <<
				"int main(void) {" << endl;
				
				string a = "";
				
				for (string decl : decls) {
					cout << decl << endl;
					a = a + decl + "\n";
				}
				
				cout << endl <<
				$5.transl << 
				"\treturn 0;\n}" << endl;
				
				ofstream code1;
				code1.open("Testes/teste.c");
				code1<<"#include <iostream>\n#include <string.h>\n#include <stdio.h>\nint main(void) {\n" << a << "\n" << $5.transl << "\treturn 0;\n}" << endl;
				code1.close();
			};
			
PUSH_SCOPE: {
				pushContext();
				
				$$.transl = "";
				$$.label = "";
			}
			
POP_SCOPE:	{
				popContext();
				
				$$.transl = "";
				$$.label = "";
			}

RAISE_FLAG	: {
				trueFlagOpenBlock();
				string begin = getBeginLabelLoop();
				string end = getEndLabelLoop();
				
				if (getFlagOpenBlock() == 1 && controlTiesContinue != beginGenLoop) {
					setBeginLabelLoop(controlTiesContinue);
				}
				
				if (getFlagOpenBlock() == 1 && controlTiesBreak != endGenLoop) {
					setEndLabelLoop(controlTiesBreak);
				}
				
				$$.transl = "";
				$$.label = "";
			}
			
LOWER_FLAG	: {
				falseFlagOpenBlock();
				string begin = getPrevBeginLabelLoop();
				string end = getPrevEndLabelLoop();
				controlTiesContinue++;
				controlTiesBreak++;
				
				$$.transl = "";
				$$.label = "";
			}
			
BLOCK		:  PUSH_SCOPE '{' STATEMENTS '}' POP_SCOPE {
				$$.transl = $3.transl;
			};

STATEMENTS	: STATEMENT STATEMENTS {
				$$.transl = $1.transl + "\n" + $2.transl;
			}
			| STATEMENT {
				$$.transl = $1.transl + "\n";
			};

STATEMENT 	: EXPR ';' {
				$$.transl = $1.transl;
			}
			| DECLARATION ';' {
				$$.transl = $1.transl;
			}
			| ATTRIBUTION ';' {
				$$.transl = $1.transl;
			}
			| ATTRIBUTION_CONDITIONAL ';' {
				$$.transl = $1.transl;
			}
			| CONDITIONAL {
				$$.transl = $1.transl;
			}
			| LOOP_CONTROL_MECHANISMS ';' {
				$$.transl = $1.transl;
			}
			| READ_OR_PRINT ';'{
				$$.transl = $1.transl;
			}
			| { $$.transl = ""; }
			;

CONDITIONAL : TK_IF '(' EXPR ')' BLOCK {
				if ($3.type == "bool") {
					string end = getEndLabel();
					string var = getNextVar();
					
					decls.push_back("\tint " + var + ";");
					
					$$.transl = $3.transl + 
						"\t" + var + " = !" + $3.label + ";\n" +
						"\tif (" + var + ") goto " + end + ";\n" +
						$5.transl +
						"\t" + end + ":";
				} else{
					// throw compile error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| TK_IF '(' EXPR ')' BLOCK ELSE {
				if ($3.type == "bool") {
					string var = getNextVar();
					string endif = getEndLabel();
					
					decls.push_back("\tint " + var + ";");
					
					$$.transl = $3.transl + 
						"\t" + var + " = !" + $3.label + ";\n" +
						"\tif (" + var + ") goto " + endif + ";\n" +
						$5.transl +
						endif + ":\n" +
						$6.transl;
					
				} else {
					// throw compile error
					yyerror("The conditional is not a boolean");
				}
			}
			| RAISE_FLAG TK_WHILE '(' EXPR ')' BLOCK LOWER_FLAG{
				if ($4.type == "bool") {
					string var = getNextVar();
					string begin = getCurrentBeginLabelLoop();
					string end = getCurrentEndLabelLoop();
					decls.push_back("\tint " + var + ";");
					
					$$.transl = $4.transl +
						begin + ":\t" + var + " = !" + $4.label + ";\n" + 
						"\tif (" + var + ") goto " + end + ";\n" +
						$6.transl +
						"\tgoto " + begin + ";\n" +
						"\t" + end + ":\n";
				} else {
					yyerror("The variable " + $4.label + " with " + $4.type + " type is not a boolean");
				}
			}
			| RAISE_FLAG TK_DO BLOCK TK_WHILE '(' EXPR ')' ';' LOWER_FLAG{
				if ($6.type == "bool") {
					string begin = getCurrentBeginLabelLoop();
					string end = getCurrentEndLabelLoop();
					string var = getNextVar();
					
					decls.push_back("\tint " + var + ";");
					
					$$.transl = $6.transl +
						"\t" + begin + ":\t" + var + " = !" + $6.label + ";\n" + 
						//"\t" + begin + ":\n" +
						$3.transl +
						"\tif (" + var + ") goto " + begin + ";\n";
				} else {
					// throw compile error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| RAISE_FLAG TK_FOR '(' PUSH_SCOPE ATTRIBUTION ';'  EXPR ';' ATTRIBUTION ')' BLOCK LOWER_FLAG POP_SCOPE {
				if ($7.type == "bool") {
					string var = getNextVar();
					string begin = getCurrentBeginLabelLoop();
					string end = getCurrentEndLabelLoop();
					
					decls.push_back("\tint " + var + ";");
					
					$$.transl = $5.transl + "\n" +
					begin + ":"  +
					$7.transl + "\t" + var + "= !" + $7.label + ";\n" +
					"\tif " + '(' + var + ") goto " + end + ";\n" +
					$9.transl + 
					$7.transl +
					"\tgoto " + begin + ";\n" +
					"\t" + end + ":\n";
					
				} else {
					yyerror("The variable " + $7.label + " with " + $7.type + " type is not a boolean");
				}
			}
			| RAISE_FLAG TK_SWITCH '(' EXPR ')' '{' CASE '}' {
				if ($4.type == "int") {
					string var = getNextVar();
					string begin = getBeginLabelLoop();
					
					$$.transl = $4.transl + 
					"\t" + begin + ":\n" +
					$7.transl;
				}else {
					yyerror("The variable " + $4.label + " with " + $4.type + " type is not an integer");
				}
			};
			
ELSE		: TK_ELIF '(' EXPR ')' BLOCK ELSE {
				if ($3.type == "bool") {
					string var = getNextVar();
					string endif = getEndLabel();
					
					decls.push_back("\tint " + var + ";");
					
					$$.transl = $3.transl + 
						"\t" + var + " = !" + $3.label + ";\n" +
						"\tif (" + var + ") goto " + endif + ";\n" +
						$5.transl +
						endif + ":\n" +
						$6.transl;
					
				} else {
					// throw compile error
					yyerror("Conditional is not a boolean.");
				}
			}
			| TK_ELSE BLOCK {
				
				string endelse = getEndLabel();
				string endif = getCurrentEndLabel();
				
				$$.transl = $2.transl /*+ 
					"\tgoto " + endelse + ";\n" +
						endif + ":" + $2.transl +
						"\n" + endelse + ":"*/;
			}
			;
			
CASE		: TK_CASE EXPR BLOCK CASE {
				if ($2.type == "int") {
					string varCase = getCurrentVar();
					string endif = getEndLabel();
					
					$$.transl = $2.transl +
					"\tif (" + varCase + " != " + $2.label + " ) goto " + endif + ";\n" +
					$3.transl +
					"\t" + endif + ":\n" +
					$4.transl;
				} else {
					yyerror("The inserted value isn't an integer\n");
				}
			}
			| TK_DEFAULT BLOCK LOWER_FLAG{
				string endSwitch = getEndLabelLoop();
				
				$$.transl = $2.transl +
				"\t"+ endSwitch +";\n";
			}
			| { 
				string endSwitch = getEndLabelLoop();
				
				$$.transl = "\t" + endSwitch + "\n"; 
			}
			;
			
LOOP_CONTROL_MECHANISMS : TK_CONTINUE {
							int flag = getFlagOpenBlock();
							
							if (flag >= 1) {
								string begin = getCurrentBeginLabelContinue();
								$$.transl = "\tgoto " + begin + ";\n";
							} else {
								yyerror("Loop control mechanism (continue) is out of a loop!");
							}
						}
						| TK_BREAK {
							int flag = getFlagOpenBlock();
							
							if (flag >= 1) {
								string end = getCurrentEndLabelLoopBreak();
								$$.transl = "\tgoto " + end + ";\n";
							} else {
								yyerror("Loop control mechanism (break) is out of a loop!");
							}
						}
						;

READ_OR_PRINT: PRINT {
				$$.transl = $1.transl;
			}
			 | READ {
				$$.transl = $1.transl;
			};
		
PRINT		: TK_PRINT PRINT_ARGS {
				$$.transl = "\tstd::cout" + $2.transl + ";\n";
			};
		
PRINT_ARGS	: PRINT_ARG PRINT_ARGS {
				$$.transl = $1.transl + $2.transl;
			}
			| PRINT_ARG { $$.transl = $1.transl; };
			
PRINT_ARG	: EXPR { $$.transl = " << " + $1.label; }
			| TK_ENDL { $$.transl = " << std::endl"; }
			;

READ		: TK_READ READ_ARGS {
				$$.transl = "\tstd::cin" + $2.transl + ";\n";
			};
			
READ_ARGS	: READ_ARG READ_ARGS {
				$$.transl = $1.transl + $2.transl;
			}
			| READ_ARG { $$.transl = $1.transl; };
			
READ_ARG	: EXPR { $$.transl = " >> " + $1.label; };
			

ATTRIBUTION	: TYPE TK_ID '=' EXPR {
				var_info* info = findVar($2.label);
	
				if (info == nullptr) {
					if ($1.label == "string") {
						if ($4.type == $1.transl) {
							decls.push_back("\tchar " + $2.transl + "[" + to_string($4.label.size()+1) + "]" + ";");
							$$.transl = $4.transl/* + "\tstrcpy(" + $2.transl + "," + $4.transl + ");\n"*/;
							$$.type = $2.type;
							$$.label = $2.label;
						
							insertVar($2.label, {$1.transl, $4.label});
						} else {
							yyerror("The expression value type is different from the target variable type");
						}
					} else {
						if ($4.type == $1.transl) {
							$$.transl = $4.transl;
						
							insertVar($2.label, {$1.transl, $4.label});
						} else {
							yyerror("The expression value type is different from the target variable type");
						}
					}
				} else {
					yyerror("Variable " + $2.label + " already exists!");
				}
			}
			| TK_GLOBAL TYPE TK_ID '=' EXPR {
				var_info* info = findVar($3.label);
	
				if (info == nullptr) {
					if ($4.type == $2.transl) {
						$$.transl = $5.transl;
						
						insertGlobalVar($3.label, {$2.transl, $5.label});
					} else {
						yyerror("Assigning a value with a different type than the defined to the global variable");
					}
				} else {
					yyerror("The variable " + $3.label + " already exists in the code");
				}
			}
			| TK_ID '['VALUE']' '['VALUE']' '=' EXPR {
				var_info* info = findVar($1.label);
				int line = atoi(&$3.transl[6]); 
				int column = atoi(&$6.transl[6]);
				int columnMatrixDeclared = info->collumn;
				
				if (line != 0 && column != 0 && line <= info->line && column <= info->collumn) {	
					if (info != nullptr) {
						// se tipo da expr for igual a do id
						if (info->type == $9.type) {
							if (info->type == "string") {
								string var = getNextVar();
								$$.type = $3.type;
								decls.push_back("\tchar " + var + "[" + to_string($3.label.size()+1) + "]" + ";");
								insertVar(var, {"char", var});
								
								$$.transl = $9.transl + "\tstrcpy(" + info->name + "," + $9.label + ");\n";
								$$.label = $9.label;
							} else {
								int total = column + columnMatrixDeclared * (line - 1);
								$$.type = $9.type;
								$$.transl = $9.transl + "\t" + info->name + "[" + to_string(total) + "] = " + $9.label + ";\n";
								$$.label = $9.label;
							}
						}else {
							yyerror("Expression type different from the matrix type");
						}
					} else {
						yyerror("Variable " + $1.label + " does not exist");
					}
				} else {
					yyerror("Invalid matrix line or column value");
				}
			}
			| TK_ID '['VALUE']' '=' EXPR {
				var_info* info = findVar($1.label);
				int column = atoi(&$3.transl[6]);
				
				if (column != 0 && column <= info->collumn) {	
					if (info != nullptr) {
						// se tipo da expr for igual a do id
						cout << info->type << $6.type << endl;
						if (info->type == $6.type) {
							if (info->type == "string") {
								string var = getNextVar();
								$$.type = $3.type;
								decls.push_back("\tchar " + var + "[" + to_string($6.label.size()+1) + "]" + ";");
								insertVar($1.label, {"char", var});
								
								$$.transl = $6.transl + "\tstrcpy(" + info->name + "," + $6.label + ");\n";
								$$.label = $6.label;
							} else {
								$$.type = $6.type;
								$$.transl = $6.transl + "\t" + info->name + "[" + to_string(column) + "] = " + $6.label + ";\n";
								$$.label = $6.label;
							}
						}else {
							yyerror("Expression type different from the array type.");
						}
					} else {
						yyerror("Variable " + $1.label + " does not exist");
					}
				} else {
					yyerror("Invalid array column value");
				}
			}
			| TK_ID '=' EXPR {
				var_info* info = findVar($1.label);
				
				if (info != nullptr) {
					// se tipo da expr for igual a do id
					if (info->type == $3.type) {
						if (info->type == "string") {
							string var = getNextVar();
							cout << $1.label<< endl;
							$$.type = $3.type;
							//decls.push_back("\tchar " + var + "[" + to_string($3.lenght) + "]" + ";");
							insertVar($1.label, {$3.type, $3.label});
							$$.transl = $3.transl;// + "\tstrcpy(" + var + "," + $3.label + ");\n";
							$$.label = $1.label;
							$$.lenght = $3.lenght;
						} else {
							$$.type = $3.type;
							$$.transl = $3.transl + "\t" + info->name + " = " + $3.label + ";\n";
							$$.label = $3.label;
						}
					} else {
						string var = getNextVar();
						string resType = opMap[info->type + "=" + $3.type];
						
						// se conversão é permitida
						if (resType.size()) {
							$$.transl = $3.transl + "\t" + info->type + " " + 
								var + " = (" + info->type + ") " + $3.label + ";\n\t" +
								info->name + " = " + var + ";\n";
							$$.type = info->type;
							$$.label = var;
						} else {
							yyerror("Implicit conversion from " + info->type + " to " + $3.type + " is not allowed");
						}
					}
				} else {
					yyerror("Variable " + $1.label + " does not exist");
				}
			}
			| INCREMENT {
				$$.transl = $1.transl;
			}
			| DECREMENT {
				$$.transl = $1.transl;
			}
			| OP_COMPOUND {
				$$.transl = $1.transl;
			}
			| UNARIO {
				$$.transl = $1.transl;
			}
			;
			
ATTRIBUTION_CONDITIONAL : TK_ID '=' '(' EXPR ')' TK_QUESTION TK_ID TK_ID {
				var_info* info = findVar($1.label);
				var_info* info2 = findVar($7.label);
				var_info* info3 = findVar($8.label);
				
				if ($4.type == "bool") {
					if (info != nullptr && info2 != nullptr && info3 != nullptr) {
						string var = getNextVar();
						string endif = getEndLabel();
						string endelse = getEndLabel();
						
						decls.push_back("\tint " + var + ";");
						
						$$.transl = $4.transl +
						"\t" + var + " = !" + $4.label + ";\n" +
						"\tif (" + var + ") goto " + endif + ";\n" +
						"\t" + info->name + " = " + info2->name + ";\n" +
						"\tgoto " + endelse + ";\n" +
						"\t" + endif + ":" +
						"\t" + info->name + " = " + info3->name + ";\n" +
						"\t" + endelse + ":\n";
					} else {
						yyerror("Variable " + $1.label + ", or " + $7.label = ", or " + $8.label + " does not exist!");
					}
				} else {
					yyerror("conditional expression does not return boolean value!");
				}
			};

DECLARATION : TYPE TK_ID {
				var_info* info = findVar($2.label);
				
				if (info == nullptr) {
					string var = getNextVar();
					
					insertVar($2.label, {$1.transl, var});
					
					if ($1.transl == "string") {
						decls.push_back("\tchar " + var + "[10000];");
						
						$$.transl = "\tstrcpy(" + var + "," + padraoMap[$1.transl] + ");\n";
						
						$$.label = var;
						$$.type = $1.transl;
					}else {
						decls.push_back("\t" + $1.transl + " " + var + ";");
						
						// tá inserindo o tipo \/ ($1.transl): tirar!
						$$.transl = "\t" + var + " = " + 
							padraoMap[$1.transl] + ";\n";
						$$.label = var;
						$$.type = $1.transl;

					}
				} else {
					yyerror("Variable "+ $2.label + " already exists!");
				}
			}
			| TK_GLOBAL TYPE TK_ID {
				var_info* info = findVar($3.label);
				
				if (info == nullptr) {
					string var = getNextVar();
					
					insertGlobalVar($3.label, {$2.transl, var});
					
					decls.push_back("\t" + $2.transl + " " + var + ";");
					
					// tá inserindo o tipo \/ ($1.transl): tirar!
					$$.transl = "\t" + var + " = " + 
						padraoMap[$2.transl] + ";\n";
					$$.label = var;
					$$.type = $2.transl;
				} else {
					// throw compile error
					yyerror("Variable "+ $3.label + " already exists!");
				}
				
			}
			| TYPE TK_ID '['VALUE']' '['VALUE']'{
				var_info* info = findVar($2.label);
				int line = atoi(&$4.transl[6]);
				int column = atoi(&$7.transl[6]);
				
				if (line != 0 && column != 0) {
					if (info == nullptr) {
						string var = getNextVar();
						
						insertVar($2.label, {$1.transl, var, column, line});
						
						if ($1.transl == "string") {
							decls.push_back("\tchar " + var + "[" + to_string(line*column) + "];");
							$$.transl = "\t" + var + "[" + to_string(line*column) + "];\n";
							
							$$.label = var;
							$$.type = $1.transl;
						} else {
							
							decls.push_back("\t" + $1.transl + " " + var + "[" + to_string(line*column) + "]" + ";");
							
							// tá inserindo o tipo \/ ($1.transl): tirar!
							$$.transl = "\t" + var + "[" + to_string( line*column ) + "];";
							$$.label = var;
							$$.type = $1.transl;
	
						}
					} else {
						yyerror("Variable "+ $2.label + " already exists!");
					}
				} else {
					yyerror("Invalid matrix line or column value.");
				}
			}
			| TYPE TK_ID '['VALUE']'{
				var_info* info = findVar($2.label);
				int column = atoi(&$4.transl[6]);
				
				if (column != 0) {
					if (info == nullptr) {
						string var = getNextVar();
						
						insertVar($2.label, {$1.transl, var, column});
						if ($1.transl == "string") {
							decls.push_back("\tchar " + var + "[" + to_string(column) + "];");
							$$.transl = "\t" + var + "[" + to_string(column) + "];\n";
							
							$$.label = var;
							$$.type = $1.transl;
						} else {
							
							decls.push_back("\t" + $1.transl + " " + var + "[" + to_string(column) + "]" + ";");
							
							// tá inserindo o tipo \/ ($1.transl): tirar!
							$$.transl = "\t" + var + "[" + to_string( column ) + "];";
							$$.label = var;
							$$.type = $1.transl;
						}
					} else {
						yyerror("Variable "+ $2.label + " already exists!");
					}
				} else {
					yyerror("Invalid array line value");
				}
			}
			| TK_GLOBAL TYPE TK_ID '['VALUE']' '['VALUE']' {
				var_info* info = findVar($3.label);
				int line = atoi(&$5.transl[6]);
				int column = atoi(&$8.transl[6]);
				
				if (line != 0 && column != 0) {
					if (info == nullptr) {
						string var = getNextVar();
						
						insertGlobalVar($2.label, {$1.transl, var, column, line});
						
						if ($1.transl == "string") {
							
							decls.push_back("\tchar " + var + "[" + to_string( line*column ) + "]" + ";");
							
							$$.transl = "\t" + var + "[" + to_string( line*column ) + "]" + ";\n";
							
							$$.label = var;
							$$.type = $1.transl;
						}else {
							
							decls.push_back("\t" + $1.transl + " " + var + "[" + to_string( line*column ) + "]" + ";");
							
							// tá inserindo o tipo \/ ($1.transl): tirar!
							$$.transl = "\t" + var + "[" + to_string( line*column ) + "];";
							$$.label = var;
							$$.type = $1.transl;
	
						}
					} else {
						yyerror("Variable "+ $2.label + " already exists!");
					}
				} else {
					yyerror("Invalid matrix line or column value");
				}
			}
			| TK_GLOBAL TYPE TK_ID '['VALUE']'{
				var_info* info = findVar($2.label);
				int column = atoi(&$5.transl[6]);
				
				if (column != 0) {
					if (info == nullptr) {
						string var = getNextVar();
						
						insertGlobalVar($3.label, {$2.transl, var, column});
						if ($1.transl == "string") {
							decls.push_back("\tchar " + var + "[" + to_string(column) + "];");
							$$.transl = "\t" + var + "[" + to_string(column) + "];\n";
							
							$$.label = var;
							$$.type = $2.transl;
						} else {
							
							decls.push_back("\t" + $2.transl + " " + var + "[" + to_string(column) + "]" + ";");
							
							// tá inserindo o tipo \/ ($1.transl): tirar!
							$$.transl = "\t" + var + "[" + to_string( column ) + "];";
							$$.label = var;
							$$.type = $2.transl;
	
						}
					} else {
						yyerror("Variable "+ $3.label + " already exists!");
					}
				} else {
					yyerror("Invalid array line value");
				}
			};

UNARIO	: TK_UNARIO TK_ID {
				var_info* info = findVar($2.label);
				
				if (info != nullptr) {
					if (info->type == "int" || info->type == "float") {
						$$.label = info->name;
						$$.type = info->type;
						$$.transl = 
						"\t-" + info->name + ";\n";
					} else {
						yyerror("Variable " + $2.label + " type is a non-numeric");
					}
				} else {
					yyerror("Variable" + $2.label + " does not exist!");
				}
			}
			;

INCREMENT	: TK_INCREMENT TK_ID {
				var_info* info = findVar($2.label);
				
				if (info != nullptr) {
					if (info->type == "int") {
						$$.label = info->name;
						$$.type = info->type;
						$$.transl = 
						"\t" + info->name + " = " + info->name + " + 1;\n";
					} else {
						yyerror("Variable " + $2.label + " type is not integer");
					}
				} else {
					yyerror("Variable " + $2.label + " does not exist");
				}
			}
			| TK_ID TK_INCREMENT {
				var_info* info = findVar($1.label);
				
				if (info != nullptr) {
					if (info->type == "int") {
						string var = getNextVar();
						
						decls.push_back("\tint " + var + ";");
						
						$$.label = info->name;
						$$.type = info->type;
						$$.transl = "\t" + var + " = " + info->name + " + 1;\n" +
						"\t" + info->name + " = " + var + ";\n";
					} else{
						yyerror("Variable " + $2.label + " type is not integer");
					}
				} else {
					yyerror("Variable" + $2.label + " does not exist");
				}
			}
			;
			
DECREMENT	: TK_DECREMENT TK_ID {
				var_info* info = findVar($2.label);
				
				if (info != nullptr) {
					if (info->type == "int") {
						$$.label = info->name;
						$$.type = info->type;
						$$.transl =
						"\t" + info->name + " = " + info->name + " - 1;\n";
					} else {
						yyerror("Variable " + $2.label + " type is not integer");
					}
				} else {
					yyerror("Variable " + $2.label + " does not exist");
				}
			}
			| TK_ID TK_DECREMENT {
				var_info* info = findVar($1.label);
				
				if (info != nullptr) {
					if (info->type == "int") {
						string var = getNextVar();
						
						decls.push_back("\tint " + var + ";");
						
						$$.label = info->name;
						$$.type = info->type;
						$$.transl = "\t" + var + " = " + info->name + " - 1;\n" +
						"\t" + info->name + " = " + var + ";\n";
					} else {
						yyerror("Variable " + $2.label + " type is not integer");
					}
				} else {
					yyerror("Variable " + $2.label + " does not exist");
				}
			}
			;
			
OP_COMPOUND : TK_ID TK_MORE_EQUAL EXPR {
				var_info* info = findVar($1.label);
				
				if (info != nullptr) {
					if (info->type == $3.type) {
						$$.type = info->type;
						$$.label = info->name;
						$$.transl = $1.transl + $3.transl +
						"\t" + info->name + " = " + info->name + " + " + $3.label + ";\n";
					} else {
						yyerror("Variable " + $1.label + " type different from the plus '" + $3.label + "' value!");
					}
				} else {
					yyerror("Variable " + $1.label + " does not exist!");
				}
			}
			| TK_ID TK_LESS_EQUAL EXPR {
				var_info* info = findVar($1.label);
				
				if (info != nullptr) {
					if (info->type == $3.type) {
						$$.type = info->type;
						$$.label = info->name;
						$$.transl = $1.transl + $3.transl +
						"\t" + info->name + " = " + info->name + " - " + $3.label + ";\n";
					} else {
						yyerror("Variable " + $1.label + " type different from the plus '" + $3.label + "' value!");
					}
				} else {
					yyerror("Variable " + $1.label + " does not exist!");
				}
			}
			| TK_ID TK_MULTIPLY_EQUAL EXPR {
				var_info* info = findVar($1.label);
				
				if (info != nullptr) {
					if (info->type == $3.type) {
						$$.type = info->type;
						$$.label = info->name;
						$$.transl = $1.transl + $3.transl +
						"\t" + info->name + " = " + info->name + " * " + $3.label + ";\n";
					} else {
						yyerror("Variable " + $1.label + " type different from the plus '" + $3.label + "' value!");
					}
				} else {
					yyerror("Variable " + $1.label + " does not exist!");
				}
			}
			| TK_ID TK_DIVIDE_EQUAL EXPR {
				var_info* info = findVar($1.label);
				
				if (info != nullptr) {
					if (info->type == $3.type) {
						$$.type = info->type;
						$$.label = info->name;
						$$.transl = $1.transl + $3.transl +
						"\t" + info->name + " = " + info->name + " / " + $3.label + ";\n";
					} else {
						yyerror("Variable " + $1.label + " type different from the plus '" + $3.label + "' value!");
					}
				} else {
					yyerror("Variable " + $1.label + " does not exist");
				}
			}
			;

EXPR 		: EXPR '+' EXPR {
				string var = getNextVar();
				string resType = opMap[$1.type + "+" + $3.type];
				
				if (resType.size()) {
					$$.transl = $1.transl + $3.transl;
					
					if ($1.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $1.label + ";\n";
						
						$1.label = var1;
					}
					
					if ($3.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $3.label + "\n";
						
						$3.label = var1;
					}
					
					if ($3.type == "string" && $1.type == "string") {
						string var1 = getNextVar();
						
						$$.type = "char";
						decls.push_back("\tchar " + var1 + "[" + to_string($1.lenght+$3.lenght) + "]" + ";");
						
						
						$$.transl += "\tstrcat(" + var1 + "," + $1.label + ");\n" +
									"\tstrcat(" + var1 + "," + $3.label + ");\n";
						$$.label = var;
						$$.lenght = $1.lenght+$3.lenght;
					}
					
					$$.type = resType;
					decls.push_back("\t" + $$.type + " " + var + ";");
					$$.transl += "\t" + var + " = " + 
						$1.label + " + " + $3.label + ";\n";
					$$.label = var;
				} else {
					yyerror("");
				}
			}
			| EXPR '-' EXPR {
				string var = getNextVar();
				string resType = opMap[$1.type + "-" + $3.type];
				
				if (resType.size()) {
					$$.transl = $1.transl + $3.transl;
					
					if ($1.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $1.label + ";\n";
						
						$1.label = var1;
					}
					
					if ($3.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $3.label + "\n";
						
						$3.label = var1;
					}
					
					$$.type = resType;
					decls.push_back("\t" + $$.type + " " + var + ";");
					$$.transl += "\t" + var + " = " + 
						$1.label + " - " + $3.label + ";\n";
					$$.label = var;
				} else {
					// throw compile error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| '-' EXPR {
				string var = getNextVar();
					
					decls.push_back("\t" + $$.type + " " + var + ";");
					$$.transl += "\t" + var + " = " + 
						$2.label + "* -1" + ";\n";
					$$.label = var;
			}
			| EXPR '*' EXPR {
				string var = getNextVar();
				string resType = opMap[$1.type + "*" + $3.type];
			
				if (resType.size()) {
					$$.transl = $1.transl + $3.transl;
					
					if ($1.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $1.label + ";\n";
						
						$1.label = var1;
					}
					
					if ($3.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $3.label + "\n";
						
						$3.label = var1;
					}
					
					$$.type = resType;
					decls.push_back("\t" + $$.type + " " + var + ";");
					$$.transl += "\t" + var + " = " + 
						$1.label + " * " + $3.label + ";\n";
					$$.label = var;
				} else {
					// throw compiler error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| EXPR '/' EXPR {
				string var = getNextVar();
				string resType = opMap[$1.type + "/" + $3.type];
			
				if (resType.size()) {
					$$.transl = $1.transl + $3.transl;
					
					if ($1.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $1.label + ";\n";
						
						$1.label = var1;
					}
					
					if ($3.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $3.label + "\n";
						
						$3.label = var1;
					}
					
					$$.type = resType;
					decls.push_back("\t" + $$.type + " " + var + ";");
					$$.transl += "\t" + var + " = " + 
						$1.label + " / " + $3.label + ";\n";
					$$.label = var;
				} else {
					// throw compiler error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| EXPR '<' EXPR {
				string var = getNextVar();
				string resType = opMap[$1.type + "<" + $3.type];
				
				if (resType.size()) {
					$$.transl = $1.transl + $3.transl;
					
					if ($1.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $1.label + ";\n";
						
						$1.label = var1;
					}
					
					if ($3.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $3.label + "\n";
						
						$3.label = var1;
					}
				
					$$.type = "bool";
					decls.push_back("\tint " + var + ";");
					$$.transl += "\t" + var + " = " + 
						$1.label + " < " + $3.label + ";\n";
					$$.label = var;
				} else {
					// throw compiler error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| EXPR '>' EXPR {
				string var = getNextVar();
				string resType = opMap[$1.type + ">" + $3.type];
				
				if (resType.size()) {
					$$.transl = $1.transl + $3.transl;
					
					if ($1.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $1.label + ";\n";
						
						$1.label = var1;
					}
					
					if ($3.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $3.label + "\n";
						
						$3.label = var1;
					}
				
					$$.type = "bool";
					decls.push_back("\tint " + var + ";");
					$$.transl += "\t" + var + " = " + 
						$1.label + " > " + $3.label + ";\n";
					$$.label = var;
				} else {
					// throw compiler error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}

			}
			| EXPR TK_LTE EXPR {
				string var = getNextVar();
				string resType = opMap[$1.type + "<=" + $3.type];
				
				if (resType.size()) {
					$$.transl = $1.transl + $3.transl;
					
					if ($1.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $1.label + ";\n";
						
						$1.label = var1;
					}
					
					if ($3.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $3.label + "\n";
						
						$3.label = var1;
					}
				
					$$.type = "bool";
					decls.push_back("\tint " + var + ";");
					$$.transl += "\t" + var + " = " + 
						$1.label + " <= " + $3.label + ";\n";
					$$.label = var;
				} else {
					// throw compiler error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| EXPR TK_GTE EXPR {
				string var = getNextVar();
				string resType = opMap[$1.type + ">=" + $3.type];
				
				if (resType.size()) {
					$$.transl = $1.transl + $3.transl;
					
					if ($1.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $1.label + ";\n";
						
						$1.label = var1;
					}
					
					if ($3.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $3.label + "\n";
						
						$3.label = var1;
					}
				
					$$.type = "bool";
					decls.push_back("\tint " + var + ";");
					$$.transl = $1.transl + $3.transl + 
						"\t" + var + " = " + $1.label + " >= " + $3.label + ";\n";
					$$.label = var;
				} else {
					// throw compiler error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| EXPR TK_EQUAL EXPR {
				string var = getNextVar();
				string resType = opMap[$1.type + "==" + $3.type];
				
				if (resType.size()) {
					$$.transl = $1.transl + $3.transl;
					
					if ($1.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $1.label + ";\n";
						
						$1.label = var1;
					}
					
					if ($3.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $3.label + "\n";
						
						$3.label = var1;
					}
				
					$$.type = "bool";
					decls.push_back("\tint " + var + ";");
					$$.transl = $1.transl + $3.transl + 
						"\t" + var + " = " + $1.label + " == " + $3.label + ";\n";
					$$.label = var;
				} else {
					// throw compiler error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| EXPR TK_DIFFERENCE EXPR {
				string var = getNextVar();
				string resType = opMap[$1.type + "!=" + $3.type];
				
				if (resType.size()) {
					$$.transl = $1.transl + $3.transl;
					
					if ($1.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $1.label + ";\n";
						
						$1.label = var1;
					}
					
					if ($3.type != resType) {
						string var1 = getNextVar();
						decls.push_back("\t" + resType + " " + var1 + ";");
						$$.transl += "\t" + var1 + " = (" + 
							resType + ") " + $3.label + "\n";
						
						$3.label = var1;
					}
				
					$$.type = "bool";
					decls.push_back("\tint " + var + ";");
					$$.transl = $1.transl + $3.transl + 
						"\t" + var + " = " + $1.label + " !== " + $3.label + ";\n";
					$$.label = var;
				} else {
					// throw compiler error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| EXPR TK_AND EXPR {
				string var = getNextVar();
				
				if ($1.type == "bool" && $3.type == "bool") {
					decls.push_back("\t" + $$.type + " " + var + ";");
					$$.transl = $1.transl + $3.transl + 
						"\t" + var + " = " + $1.label + " && " + $3.label + ";\n";
					$$.label = var;
				} else {
					// throw compile error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| EXPR TK_OR EXPR {
				string var = getNextVar();
				
				if ($1.type == "bool" && $3.type == "bool") {
					decls.push_back("\t" + $$.type + " " + var + ";");
					$$.transl = $1.transl + $3.transl + 
						"\t" + var + " = " + $1.label + " || " + $3.label + ";\n";
					$$.label = var;
				} else{
					// throw compile error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			} 
			| TK_NOT EXPR {
				string var = getNextVar();
				
				if ($2.type == "bool") {
					decls.push_back("\t" + $$.type + " " + var + ";");
					$$.transl = $2.transl + 
						"\t" + var + " =  ! " + $2.label + ";\n";
					$$.label = var;
				} else {
					// throw compile error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}	
			}
			| '(' TYPE ')' VALUE {
				string var = getNextVar();
				string type = opMap[$2.type + "cast" + $4.type];
				
				if (type.size()) {
					$$.type = type;
					$$.transl = $4.transl + 
						"\t" + $$.type + " " + var + " = (" + $2.transl + ") " + $4.label + ";\n";
					$$.label = var;
				} else {
					// throw compile error
					$$.type = "ERROR";
					$$.transl = "ERROR";
				}
			}
			| EXPR TK_EXPONENT EXPR {
				string var = getNextVar();
				string var1 = getNextVar();
				string var2 = getNextVar();
				string resType = opMap[$1.type + "exp" + $3.type];
				string begin = getBeginLabel();
				string end = getEndLabel();
				
				if (resType.size()) {
					decls.push_back("\t" + $$.type + " " + var + ";");
					decls.push_back("\tbool " + var1 + ";");
					decls.push_back("\t" + $$.type + " " + var2 + ";");
					$$.type = resType;
					
					$$.transl = $3.transl +
						begin + ":\t" + var1 + " = " + var2 + " > " + $3.label + ";\n" +
						"\t" + var1 + " = !" + var1 + ";\n" +
						"\tif (" + var1 + ") goto " + end + ";\n" +
						"\n\t" + $1.label + " = " + $1.label + " * " + $1.label + ";\n" +
						"\t" + var2 + " = " + var2 + " + 1;\n" +
						"\n\tgoto " + begin + ";\n" +
						"\t" + end + ":\n" +
						"\t" + var + " = " + $1.label + ";\n";
					
					$$.label = var;
				} else {
					yyerror("Types " + $1.type + " or " + $3.type + " do not have implicit conversion");
				}
			}
			| EXPR TK_FACTORIAL{
				string var = getNextVar();
				string var1 = getNextVar();
				string var2 = getNextVar();
				string begin = getBeginLabel();
				string end = getEndLabel();
				
				if ($1.type == "int") {
					decls.push_back("\t" + $$.type + " " + var + ";");
					decls.push_back("\tbool " + var1 + ";");
					decls.push_back("\t" + $$.type + " " + var2 + ";");
					$$.type = $1.type;
					
					$$.transl = $1.transl +
						"\t" + var2 + " = " + $1.label + ";\n" +
						begin + ":\t" + var1 + " = " + var2 + " <= 0;\n" +
						"\t" + var1 + " = !" + var1 + ";\n" +
						"\tif (" + var1 + ") goto " + end + ";\n" +
						"\n\t" + var2 + " = " + var2 + " - 1;\n" +
						"\t" + $1.label + " = " + $1.label + " * " + var2 + ";\n" +
						"\n\tgoto " + begin + ";\n" +
						"\t" + end + ":\n" +
						"\t" + var + " = " + $1.label + ";\n";
					
					$$.label = var;
				} else {
					yyerror("Type " + $1.type + " does not have implicit conversion in this expression");
				}
			}
			| VALUE {
				$$.transl = $1.transl;
				$$.label = $1.label;
				$$.type = $1.type;
			};
			
TYPE		: TK_INT_TYPE
			| TK_FLOAT_TYPE
			| TK_DOUBLE_TYPE
			| TK_LONG_TYPE
			| TK_CHAR_TYPE
			| TK_STRING_TYPE
			| TK_BOOL_TYPE
			;
			
VALUE		: TK_NUM {
				string var = getNextVar();
				string value = $1.label;
				
				if ($1.type == "float") {
					value = to_string(stof(value));
				} else if ($1.type == "double") {
					value = to_string(stod(value));
				} else if ($1.type == "long") {
					value = to_string(stol(value));
				}
				
				decls.push_back("\t" + $1.type + " " + var + ";");
				$$.transl = "\t" + var + " = " + value + ";\n";
				$$.label = var;
			}
			| TK_CHAR {
				string var = getNextVar();
				string value = $1.label;
				
				decls.push_back("\t" + $1.type + " " + var + ";");
				$$.transl = "\t" + var + " = " + value + ";\n";
				$$.label = var;
			}
			| TK_STRING {
				string var = getNextVar();
				string value = $1.label;
				decls.push_back("\tchar " + var +"[" + to_string($1.label.size()-2) + "];");
				insertVar(var, {$1.type, var});
				//cout << $1.type << var << endl;
				$$.transl = "\tstrcpy(" + var + "," + value + ");\n";
				$$.label = var;
				$$.lenght = $1.label.size()-2;
			}
			| TK_BOOL {
				string var = getNextVar();
				
				$1.label = ($1.label == "true"? "1" : "0");
				
				decls.push_back("\tint " + var + ";");
				$$.transl = "\t" + var + " = " + value + ";\n";
				$$.label = var;
			}
			| TK_ID {
				var_info* varInfo = findVar($1.label);
				
				if (varInfo != nullptr) {
					$$.type = varInfo->type;
					$$.label = varInfo->name;
					$$.transl = "";
				} else {
					// throw compile error
					yyerror("Variable " + $1.label + " already exists!");
				}
			}
			;

%%

#include "lex.yy.c"

int yyparse();

int main(int argc, char* argv[]) {
	opMapFile.open("util/opmap.dat");
	padraoMapFile.open("util/default.dat");
	
	if (opMapFile.is_open()) {
		while (opMapFile >> type1 >> op >> type2 >> typeRes) {
	    	opMap[type1 + op + type2] = typeRes;
		}
		
		opMapFile.close();
	} else {
		cout << "Unable to open operator map file";
	}
	
	if (padraoMapFile.is_open()) {
		while (padraoMapFile >> type1 >> value) {
	    	padraoMap[type1] = value;
		}
		
		padraoMapFile.close();
	} else {
		cout << "Unable to open default values file";
	}

	yyparse();

	return 0;
}

void yyerror(string MSG ) {
	cout << MSG << endl;
	exit (0);
}

//Incrementa o valor para variáveis do código intermediário
string getNextVar() {
    return "t" + to_string(tempGen++);
}

string getCurrentVar() {
    return "t" + to_string(tempGen);
}

string getBeginLabel() {
	return "BEGIN" + to_string(beginGen++);
}

string getPrevBeginLabel() {
	return "BEGIN" + to_string(beginGen--);
}

string getCurrentBeginLabel() {
	return "BEGIN" + to_string(beginGen);
}

string getBeginLabelLoop() {
	return "BEGINLOOP" + to_string(beginGenLoop++);
}

string getPrevBeginLabelLoop() {
	return "BEGINLOOP" + to_string(beginGenLoop--);
}

string getCurrentBeginLabelLoop() {
	return "BEGINLOOP" + to_string(beginGenLoop);
}

void setBeginLabelLoop(int update) {
	beginGenLoop = update;
}

string getCurrentBeginLabelContinue() {
	int temp = beginGenLoop;
	temp--;
	return "BEGINLOOP" + to_string(temp);
}

string getEndLabel() {
	return "END" + to_string(endGen++);
}

string getCurrentEndLabel() {
	return "END" + to_string(endGen);
}

string getEndLabelLoop() {
	return "ENDLOOP" + to_string(endGenLoop++);
}

string getPrevEndLabelLoop() {
	return "ENDLOOP" + to_string(endGenLoop--);
}

string getCurrentEndLabelLoop() {
	return "ENDLOOP" + to_string(endGenLoop);
}

void setEndLabelLoop(int update) {
	endGenLoop = update;
}

string getCurrentEndLabelLoopBreak() {
	int temp = endGenLoop;
	temp--;
	return "ENDLOOP" + to_string(temp);
}

void trueFlagOpenBlock() {
	openBlock += 1;
}

void falseFlagOpenBlock() {
	openBlock -= 1;
}

int getFlagOpenBlock() {
	return openBlock;
}

var_info* findVar(string label) {
	for (int i = varMap.size() - 1; i >= 0; i--) {
		if (varMap[i].count(label)) {
			return &varMap[i][label];
		}
	}
	
	return nullptr;
}

int findValue(string label) {
	for (int i = 0; i < decls.size(); i++) {
		if (decls.at(i) == label) {
			return i;
		}
	}
	
	return 0;
}

void insertVar(string label, var_info info) {
	varMap[varMap.size() - 1][label] = info;
}

void insertGlobalVar(string label, var_info info) {
	varMap[0][label] = info;
}

void pushContext() {
	map<string, var_info> newContext;
	varMap.push_back(newContext);
}

void popContext() {
	varMap.pop_back();
}