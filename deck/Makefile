# Build the slide PDF
all: main.pdf

main.pdf: main.typ lib/*.typ
	typst compile --root . main.typ main.pdf

watch:
	typst watch --root . main.typ main.pdf

clean:
	rm -f main.pdf

.PHONY: all watch clean
