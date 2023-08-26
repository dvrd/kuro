package lexer

import "core:testing"
import "core:fmt"

@(test)
test_lexer :: proc(t: ^testing.T) {
	data := "=+(){},;"
	lexer := init(data)
	defer destroy(&lexer)
	scan_tokens(&lexer)

	expected_tokens := []Token{
		{0, .Eq, "="},
		{1, .Add, "+"},
		{2, .OpenParen, "("},
		{3, .CloseParen, ")"},
		{4, .OpenBrace, "{"},
		{5, .CloseBrace, "}"},
		{6, .Comma, ","},
		{7, .Semicolon, ";"},
		{8, .EOF, ""},
	}

	for token, i in lexer.tokens {
		tokens_are_equal(lexer.tokens[i], expected_tokens[i])
	}
}

@(test)
test_lexer_full :: proc(t: ^testing.T) {
	data :=
		"five := 5\n" +
		"ten := 10\n" +
		"add :: proc(x, y: int) -> int {\n" +
		"    return x + y\n" +
		"}\n" +
		"result := add(five, ten)\n"
	lexer := init(data)
	defer destroy(&lexer)
	scan_tokens(&lexer)

	expected_tokens := []Token{
		{0, .Ident, "five"},
		{5, .Colon, ":"},
		{6, .Eq, "="},
		{8, .Integer, "5"},
		{10, .Ident, "ten"},
		{14, .Colon, ":"},
		{15, .Eq, "="},
		{17, .Integer, "10"},
		{20, .Ident, "add"},
		{24, .Colon, ":"},
		{25, .Colon, ":"},
		{27, .Proc, "proc"},
		{31, .OpenParen, "("},
		{32, .Ident, "x"},
		{33, .Comma, ","},
		{35, .Ident, "y"},
		{36, .Colon, ":"},
		{38, .Ident, "int"},
		{41, .CloseParen, ")"},
		{43, .ArrowRight, "->"},
		{46, .Ident, "int"},
		{50, .OpenBrace, "{"},
		{56, .Return, "return"},
		{63, .Ident, "x"},
		{65, .Add, "+"},
		{67, .Ident, "y"},
		{69, .CloseBrace, "}"},
		{71, .Ident, "result"},
		{78, .Colon, ":"},
		{79, .Eq, "="},
		{81, .Ident, "add"},
		{84, .OpenParen, "("},
		{85, .Ident, "five"},
		{89, .Comma, ","},
		{91, .Ident, "ten"},
		{94, .CloseParen, ")"},
		{96, .EOF, ""},
	}

	for token, i in lexer.tokens {
		msg, ok := tokens_are_equal(token, expected_tokens[i])
		if !ok do panic(msg)
	}
}

tokens_are_equal :: proc(a: Token, b: Token) -> (msg: string, ok: bool = true) {
	if a.offset != b.offset {
		fmt.println(a, b)
		msg = "Token offset mismatch"
	}
	if a.kind != b.kind {
		fmt.println(a, b)
		msg = "Token kind mismatch"
	}
	if a.literal != b.literal {
		fmt.println(a, b)
		msg = "Token text mismatch"
	}
	if msg != "" {
		ok = false
	}
	return
}
