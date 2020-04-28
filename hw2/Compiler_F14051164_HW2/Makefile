CC := gcc
CFLAGS := -Wall -g
YFLAG := -d -v
LEX_SRC := compiler_hw2.l
YAC_SRC := compiler_hw2.y
HEADER := common.h
TARGET := myparser
v := 1

all: ${TARGET}

${TARGET}: lex.yy.c y.tab.c
	${CC} ${CFLAGS} -o $@ $^

lex.yy.c: ${LEX_SRC} ${HEADER}
	lex $<

y.tab.c: ${YAC_SRC} ${HEADER}
	yacc ${YFLAG} $<

judge: all
	@python3 judge/judge.py -v ${v} || printf "or \`make judge v=1\`"
test01: all
	./${TARGET} < input/in01_arithmetic.go
test02: all
	./${TARGET} < input/in02_precedence.go
test03: all
	./${TARGET} < input/in03_scope.go
test04: all
	./${TARGET} < input/in04_array.go
test05: all
	./${TARGET} < input/in05_assignment.go
test06: all
	./${TARGET} < input/in06_conversion.go
test07: all
	./${TARGET} < input/in07_if.go
test08: all
	./${TARGET} < input/in08_for.go
test09: all
	./${TARGET} < input/in09_type_error.go
test10: all
	./${TARGET} < input/in10_variable_error.go
test11: all
	./${TARGET} < input/in11_monster.go

test: all
	./${TARGET} < input/test.go

clean:
	rm -f ${TARGET} y.tab.* y.output lex.*
