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

%}

%union{}

%type <yys> expr number

%token <yys> DIGIT LETTER

%left  '|'
%left  '&'
%left  '+'  '-'
%left  '*'  '/'  '%'
%left  UMINUS      /*  supplies  precedence  for  unary  minus  */

%%

list    : /* empty */
        | list stat '\n'
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


func (l *CalcLex) Lex(lval *CalcSymType) int {
	var c int = ' '
	for c == ' ' {
		if l.pos == len(l.s) {
			return 0
		}
		c = int(l.s[l.pos])
		l.pos += 1
	}

	if unicode.IsDigit(c) {
		lval.yys = c - '0'
		return DIGIT
	} else if unicode.IsLower(c) {
		lval.yys = c - 'a'
		return LETTER
	}
	return c
}

func (l *CalcLex) Error(s string) {
	fmt.Printf("syntax error\n")
}

func main() {

	fi := bufio.NewReader(os.NewFile(0, "stdin"))

	for eqn, ok := readline(fi); ok; eqn, ok = readline(fi) {
		fmt.Print("calculating: ", eqn)
		CalcParse(&CalcLex{eqn, 0})
	}
}

func readline(fi *bufio.Reader) (string, bool) {
	s, err := fi.ReadString('\n')
	if err != nil {
		return "", false
	}

	return s, true
}
