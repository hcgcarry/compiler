CC := gcc
CFLAGS := -Wall
SRC := compiler_hw1.l
TARGET := myscanner
v := 1

all: ${TARGET}

${TARGET}: lex.yy.c
	@${CC} ${CFLAGS} -o $@ $<

lex.yy.c: ${SRC}
	@lex ${SRC}
test:all
	@./${TARGET} < input/test.go
test01:all
	@./${TARGET} < input/in01_arithmetic.go
test02:all
	@./${TARGET} < input/in02_conversion.go
test03:all
	@./${TARGET} < input/in03_relational.go
test04:all
	@./${TARGET} < input/in04_assignment.go
test05:all
	@./${TARGET} < input/in05_declaration.go
test06:all
	@./${TARGET} < input/in06_if.go
test07:all
	@./${TARGET} < input/in07_if_else.go
test08:all
	@./${TARGET} < input/in08_for.go
test09:all
	@./${TARGET} < input/in09_comment.go
test10:all
	@./${TARGET} < input/in10_print.go
test11:all
	@./${TARGET} < input/in11_monster.go

judge: all
	@python3 judge/judge.py -v ${v} || printf "or \`make judge v=1\`"

clean:
	@rm -f ${TARGET} lex.*
