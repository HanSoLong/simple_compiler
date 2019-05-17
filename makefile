combined: parser.y  test_1.l
	bison -d parser.y
	flex test_1.l
	gcc -o $@ parser.tab.c lex.yy.c

.PHONY: clean
clean: 
	rm -f combined parser.tab.c parser.tab.h lex.yy.c 
