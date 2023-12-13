all:
	yacc -dv Simple.y
	flex Simple.l
	gcc lex.yy.c y.tab.c


test:
	./a.out unit_tests > out.tm
	./tm out.tm