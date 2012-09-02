#!/bin/sh

# create parser
for y in *.y
do
    go tool yacc -o ${y%.y}.go -p Calc $y
done

# build go
go build
