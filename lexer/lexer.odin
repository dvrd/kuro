package lexer

import "core:fmt"

Lexer :: struct {
	data:   []u8,
	offset: int,
	tokens: [dynamic]Token,
}

Token :: struct {
	offset:  int,
	kind:    TokenKind,
	literal: string,
}

TokenKind :: enum {
	Illegal,
	EOF,

	// Idents & Literals
	Ident,
	Number,

	// Operators
	Assign,
	Plus,
	Minus,
	Bang,
	Asterisk,
	Slash,

	//Comparators
	LAngle,
	RAngle,
	Eq,
	NotEq,

	// Delimiters
	Comma,
	Semicolon,
	Dot,
	// Grouping
	Lparen,
	Rparen,
	LSquirly,
	RSquirly,
	// Keywords
	Function,
	Let,
	True,
	False,
	If,
	Else,
	Return,
}

init :: proc(data: string) -> Lexer {
	lexer := Lexer {
		data   = transmute([]u8)data,
		tokens = make([dynamic]Token),
	}
	return lexer
}

reset :: proc(l: ^Lexer) {
	clear(&l.tokens)
	l.data = {}
	l.offset = 0
}

destroy :: proc(l: ^Lexer) {
	delete(l.tokens)
}

scan_tokens :: proc(l: ^Lexer) {
	for !is_at_end(l) {
		scan_token(l)
	}
	append(&l.tokens, Token{offset = l.offset, kind = .EOF})
}

scan_token :: proc(l: ^Lexer) {
	c := next(l)
	if is_whitespace(c) {return}
	start := l.offset - 1
	//odinfmt: disable
	switch c {
		case '+': append(&l.tokens, Token{start, .Plus, "+"})
		case '-': append(&l.tokens, Token{start, .Minus, "-"})
		case '*': append(&l.tokens, Token{start, .Asterisk, "*"})
		case '/': append(&l.tokens, Token{start, .Slash, "/"})
		case '<': append(&l.tokens, Token{start, .LAngle, "<"})
		case '>': append(&l.tokens, Token{start, .RAngle, ">"})
		case '(': append(&l.tokens, Token{start, .Lparen, "("})
		case ')': append(&l.tokens, Token{start, .Rparen, ")"})
		case '{': append(&l.tokens, Token{start, .LSquirly, "{"})
		case '}': append(&l.tokens, Token{start, .RSquirly, "}"})
		case ';': append(&l.tokens, Token{start, .Semicolon, ";"})
		case ',': append(&l.tokens, Token{start, .Comma, ","})
		case '.': append(&l.tokens, Token{start, .Dot, "."})
		case '=':
			if peek(l) == '=' {
				append(&l.tokens, Token{start, .Eq, "=="})
				next(l)
			} else {
				append(&l.tokens, Token{start, .Assign, "="})
			}
		case '!':
			if peek(l) == '=' {
				append(&l.tokens, Token{start, .NotEq, "!="})
				next(l)
			} else {
				append(&l.tokens, Token{start, .Bang, "!"})
			}
		case 'a'..='z', 'A'..='Z', '_':
			for is_alpha_numeric(peek(l)) do next(l)

			switch ident := string(l.data[start : l.offset]); ident {
				case "if":			append(&l.tokens, Token{start, .If, "if"})
				case "else": 		append(&l.tokens, Token{start, .Else, "else"})
				case "fn": 			append(&l.tokens, Token{start, .Function, "fn"})
				case "let":			append(&l.tokens, Token{start, .Let, "let"})
				case "true":		append(&l.tokens, Token{start, .True, "true"})
				case "false": 	append(&l.tokens, Token{start, .False, "false"})
				case "return": 	append(&l.tokens, Token{start, .Return, "return"})
				case:						append(&l.tokens, Token{start, .Ident, ident})
			}
		case '0'..='9':
			for is_digit(peek(l)) do next(l)
			append(&l.tokens, Token{start, .Number, string(l.data[start : l.offset])})
		case: append(&l.tokens, Token{start, .Illegal, ""})
	}
	//odinfmt: enable
}

is_at_end :: proc(l: ^Lexer) -> bool {
	return l.offset >= len(l.data)
}

next :: proc(l: ^Lexer) -> u8 #no_bounds_check {
	next: u8
	if l.offset < len(l.data) {
		next = l.data[l.offset]
		l.offset += 1
	}
	return next
}

peek :: proc(l: ^Lexer) -> u8 #no_bounds_check {
	if l.offset >= len(l.data) {
		return 0x0
	} else {
		return l.data[l.offset]
	}
}

is_digit :: proc(c: u8) -> bool {
	return c >= '0' && c <= '9'
}

is_alpha :: proc(c: u8) -> bool {
	return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c == '_'
}

is_alpha_numeric :: proc(c: u8) -> bool {
	return is_alpha(c) || is_digit(c)
}

is_whitespace :: proc(c: u8) -> bool {
	return c == ' ' || c == '\n' || c == '\r' || c == '\t'
}
