package lox

import "core:os"
import "core:fmt"
import "core:bufio"
import "core:c"

import lex "lexer"

main :: proc() {
	fmt.println(os.args)
	if (len(os.args) > 2) {
		fmt.println("Usage: odinlox [script]")
		os.exit(64)
	} else if (len(os.args) == 2) {
		fmt.println("Executing file..")
		runFile(os.args[1])
	} else {
		fmt.println("Hello stranger this is the kuro programming language!")
		fmt.println("Feel free to type in commands")
		repl(os.stdin)
	}
}

run :: proc(src: string) {
	l := lex.init(src)
	defer lex.destroy(&l)
	lex.scan_tokens(&l)

	for token, i in l.tokens {
		fmt.print(token)
	}
}

runFile :: proc(path: string) {
	data, ok := os.read_entire_file(path);if !ok {
		fmt.eprintln("Error: failed to load the file!")
		return
	}
	defer delete(data)

	run(string(data))
}

repl :: proc(input: os.Handle) {
	buf: [1024]byte
	l := lex.init("")
	defer lex.destroy(&l)

	for {
		fmt.print(">> ")
		n, err := os.read(os.stdin, buf[:]);if err < 0 {
			fmt.panicf("Error: %#v", err)
		}
		l.data = buf[:n]

		lex.scan_tokens(&l)

		if len(l.tokens) > 1 { 	// dont print if only the EOF
			for t in l.tokens {
				fmt.println(t)
			}
		}

		lex.reset(&l)
	}
}
