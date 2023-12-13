all:
	yacc -dv Simple.y
	flex Simple.l
	gcc lex.yy.c y.tab.c