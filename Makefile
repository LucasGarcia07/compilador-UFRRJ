all: 	
		clear
		lex lexico.l
		yacc -d sintatico.y
		g++ -o glf y.tab.c -ll
		
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

teste:
	for i in ./test/*.foca; do\
		echo "\n\033[0;31m Testing file: \033[0;32m$$i\033[0m";\
		./glf < $$i;\
	done
		
clean:
	rm y.tab.c
	rm y.tab.h
	rm lex.yy.c
	rm glf