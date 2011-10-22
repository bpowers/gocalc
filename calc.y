%{

package main

import (
	"bufio"
	"fmt"
	"os"
	"unicode"
)

var regs = make([]int, 26)
var base int


var fi *bufio.Reader // input
var line string      // current input line
var lineno int       // current input line number
var linep int        // index to next rune in unput
var nerrors int      // error count
var peekrune int     // backup runt from input
var sym string
var vflag bool

%}

%union {
	numb int
}

%type <numb> expr number

%token <numb> DIGIT LETTER

%left  '|'
%left  '&'
%left  '+'  '-'
%left  '*'  '/'  '%'
%left  UMINUS      /*  supplies  precedence  for  unary  minus  */

%%

list    : /* empty */
        | list stat '\n'
        | list error '\n'
        ;

stat :    expr
               {    fmt.Printf( "%d\n", $1 );  }
     |    LETTER  '='  expr
               {    regs[$1]  =  $3;  }
     ;


expr :    '('  expr  ')'
               {    $$  =  $2;  }
     |    expr  '+'  expr
               {    $$  =  $1  +  $3;  }
     |    expr  '-'  expr
               {    $$  =  $1  -  $3;  }
     |    expr  '*'  expr
               {    $$  =  $1  *  $3;  }
     |    expr  '/'  expr
               {    $$  =  $1  /  $3;  }
     |    expr  '%'  expr
               {    $$  =  $1  %  $3;  }
     |    expr  '&'  expr
               {    $$  =  $1  &  $3;  }
     |    expr  '|'  expr
               {    $$  =  $1  |  $3;  }
     |    '-'  expr        %prec  UMINUS
               {    $$  =  -  $2;  }
     |    LETTER
               {    $$  =  regs[$1];  }
     |    number
     ;

number    :    DIGIT
               {
		       $$ = $1;
		       if $1==0 {
			       base = 8
		       } else {
			       base = 10
		       }
	       }
     |    number  DIGIT
               {    $$  =  base * $1  +  $2;  }
     ;

%%      /*  start  of  programs  */

type CalcLex struct {
	s string
	pos int
}


func (l *CalcLex) Lex(lval *calc_SymType) int {
	var c int = ' '
	for c == ' ' {
		if l.pos == len(l.s) {
			return 0
		}
		c = int(l.s[l.pos])
		l.pos += 1
	}

	if unicode.IsDigit(c) {
		lval.numb = c - '0'
		return DIGIT
	} else if unicode.IsLower(c) {
		lval.numb = c - 'a'
		return LETTER
	}
	return c
}

func (l *CalcLex) Error(s string) {
	fmt.Printf("syntax error\n")
}

func main() {
	fi = bufio.NewReader(os.NewFile(0, "stdin"))

	for eqn, ok := readline(); ok; eqn, ok = readline() {
		fmt.Print("calculating: ", eqn)
		calc_Parse(&CalcLex{eqn, 0})
	}
}

func readline() (string, bool) {
	s, err := fi.ReadString('\n')
	if err != nil {
		return "", false
	}

	return s, true
}
