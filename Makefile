all: 	
		clear
		lex lexico.l
		yacc -d  sintatico.y 
		g++ -o glf -x c++ y.tab.c -w -ll -Iinclude/ -lfl -std=c++11
teste:
	./glf < test/test.foca