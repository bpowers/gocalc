include $(GOROOT)/src/Make.inc

TARG = calc

GOFILES = \
	calc.go

CLEANFILES += \
	calc.go\
	y.output\

include $(GOROOT)/src/Make.cmd

.PHONY: gofmt
gofmt:
	gofmt -w $(GOFILES)

calc.go: calc.y
	goyacc -o $@ -p calc_ $<
