CC := gcc
CFLAGS := -Wall
YFLAG := -d -v
LEX_SRC := compiler_hw3.l
YAC_SRC := compiler_hw3.y
HEADER := common.h
COMPILER := mycompiler
JAVABYTECODE := hw3.j
EXEC := Main
v := 0

all: ${COMPILER}

${COMPILER}: lex.yy.c y.tab.c
	${CC} ${CFLAGS} -o $@ $^

lex.yy.c: ${LEX_SRC} ${HEADER}
	lex $<

y.tab.c: ${YAC_SRC} ${HEADER}
	yacc ${YFLAG} $<


test: all
	./${COMPILER} < test.go

test01: all
	./${COMPILER} < input/in01_arithmetic.go
test02: all
	./${COMPILER} < input/in02_precedence.go
test03: all
	./${COMPILER} < input/in03_scope.go
test04: all
	./${COMPILER} < input/in04_array.go
test05: all
	./${COMPILER} < input/in05_assignment.go
test06: all
	./${COMPILER} < input/in06_conversion.go
test07: all
	./${COMPILER} < input/in07_if.go
test08: all
	./${COMPILER} < input/in08_for.go
test09: all
	./${COMPILER} < input/in09_type_error.go
test10: all
	./${COMPILER} < input/in10_variable_error.go
test11: all
	./${COMPILER} < input/in11_nested_if.go
test12: all
	./${COMPILER} < input/in12_nested_for.go
test13: all
	./${COMPILER} < input/in13_monster.go


${JAVABYTECODE}: ${COMPILER}
ifeq (,$(wildcard ${JAVABYTECODE}))
	@echo "${JAVABYTECODE} does not exist."
endif

${EXEC}.class: ${JAVABYTECODE}
	@java -jar jasmin.jar -g ${JAVABYTECODE}

run: ${EXEC}.class
	@java ${EXEC} || java -Xverify:none ${EXEC}

judge: all
	@python3 judge/judge.py -v ${v} || printf "or \`make judge v=1\`"

clean:
	rm -f ${COMPILER} y.tab.* y.output lex.* ${EXEC}.class *.j
