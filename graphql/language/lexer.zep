namespace GraphQL\Language;

use GraphQL\Error\SyntaxError;
use GraphQL\Utils\Utils;
use GraphQL\Utils\BlockString;
/**
 * A Lexer is a stateful stream generator in that every time
 * it is advanced, it returns the next token in the Source. Assuming the
 * source lexes, the final Token emitted by the lexer will be of kind
 * EOF, after which the lexer will repeatedly return the same EOF token
 * whenever called.
 *
 * Algorithm is O(N) both on memory and time
 */
class Lexer
{
    /**
     * @var Source
     */
    public source;
    /**
     * @var array
     */
    public options;
    /**
     * The previously focused non-ignored token.
     *
     * @var Token
     */
    public lastToken;
    /**
     * The currently focused non-ignored token.
     *
     * @var Token
     */
    public token;
    /**
     * The (1-indexed) line containing the current token.
     *
     * @var int
     */
    public line;
    /**
     * The character offset at which the current line begins.
     *
     * @var int
     */
    public lineStart;
    /**
     * Current cursor position for UTF8 encoding of the source
     *
     * @var int
     */
    protected position;
    /**
     * Current cursor position for ASCII representation of the source
     *
     * @var int
     */
    protected byteStreamPosition;
    /**
     * Lexer constructor.
     *
     * @param Source $source
     * @param array $options
     */
    public function __construct(<Source> source, array options = []) -> void
    {
        var startOfFileToken;
    
        let startOfFileToken =  new Token(Token::SOF, 0, 0, 0, 0, null);
        let this->source = source;
        let this->options = options;
        let this->lastToken = startOfFileToken;
        let this->token = startOfFileToken;
        let this->line = 1;
        let this->lineStart = 0;
        let this->position = 0;
        let this->byteStreamPosition = 0;
        ;
    }
    
    /**
     * @return Token
     */
    public function advance() -> <Token>
    {
        var token;
    
        let this->lastToken =  this->token;
        let token = this->lookahead();
        let this->token = this->lookahead();
        ;
        return token;
    }
    
    public function lookahead()
    {
        var token;
    
        let token =  this->token;
        if token->kind !== Token::EOF {
            do {
                let token =  token->next ? token->next : (let token->next =  this->readToken(token));
            } while (token->kind === Token::COMMENT);
        }
        return token;
    }
    
    /**
     * @return Token
     */
    public function nextToken() -> <Token>
    {
        trigger_error(__METHOD__ . " is deprecated in favor of advance()", E_USER_DEPRECATED);
        return this->advance();
    }
    
    /**
     * @param Token $prev
     * @return Token
     * @throws SyntaxError
     */
    protected function readToken(<Token> prev) -> <Token>
    {
        var bodyLength, position, line, col, code, bytes, tmpListCodeBytes, charCode1, tmpListCharCode1, charCode2, tmpListCharCode2, nextCode, tmpListNextCode, nextNextCode, tmpListNextNextCode, errMessage;
    
        let bodyLength =  this->source->length;
        this->positionAfterWhitespace();
        let position =  this->position;
        let line =  this->line;
        let col =  1 + position - this->lineStart;
        if position >= bodyLength {
            return new Token(Token::EOF, bodyLength, bodyLength, line, col, prev);
        }
        // Read next char and advance string cursor:
        ;
        let tmpListCodeBytes = this->readChar(true);
        ;
        let code = tmpListCodeBytes[1];
        let bytes = tmpListCodeBytes[2];
        // SourceCharacter
        if code < 32 && code !== 9 && code !== 10 && code !== 13 {
            throw new SyntaxError(this->source, position, "Cannot contain the invalid character " . Utils::printCharCode(code));
        }
        if 33 {
            // !
            return new Token(Token::BANG, position, position + 1, line, col, prev);
        } elseif 45 || 48 || 49 || 50 || 51 || 52 || 53 || 54 || 55 || 56 || 57 {
            return this->moveStringCursor(-1, -1 * bytes)->readNumber(line, col, prev);
        } elseif 65 || 66 || 67 || 68 || 69 || 70 || 71 || 72 || 73 || 74 || 75 || 76 || 77 || 78 || 79 || 80 || 81 || 82 || 83 || 84 || 85 || 86 || 87 || 88 || 89 || 90 || 95 || 97 || 98 || 99 || 100 || 101 || 102 || 103 || 104 || 105 || 106 || 107 || 108 || 109 || 110 || 111 || 112 || 113 || 114 || 115 || 116 || 117 || 118 || 119 || 120 || 121 || 122 {
            return this->moveStringCursor(-1, -1 * bytes)->readName(line, col, prev);
        } elseif 125 {
            // }
            return new Token(Token::BRACE_R, position, position + 1, line, col, prev);
        } elseif 124 {
            // |
            return new Token(Token::PIPE, position, position + 1, line, col, prev);
        } elseif 123 {
            // {
            return new Token(Token::BRACE_L, position, position + 1, line, col, prev);
        } elseif 93 {
            // ]
            return new Token(Token::BRACKET_R, position, position + 1, line, col, prev);
        } elseif 91 {
            // [
            return new Token(Token::BRACKET_L, position, position + 1, line, col, prev);
        } elseif 64 {
            // @
            return new Token(Token::AT, position, position + 1, line, col, prev);
        } elseif 61 {
            // =
            return new Token(Token::EQUALS, position, position + 1, line, col, prev);
        } elseif 58 {
            // :
            return new Token(Token::COLON, position, position + 1, line, col, prev);
        } elseif 46 {
            // .
            ;
            let tmpListCharCode1 = this->readChar(true);
            ;
            let charCode1 = tmpListCharCode1[1];
            ;
            let tmpListCharCode2 = this->readChar(true);
            ;
            let charCode2 = tmpListCharCode2[1];
            if charCode1 === 46 && charCode2 === 46 {
                return new Token(Token::SPREAD, position, position + 3, line, col, prev);
            }
        } elseif 41 {
            // )
            return new Token(Token::PAREN_R, position, position + 1, line, col, prev);
        } elseif 40 {
            // (
            return new Token(Token::PAREN_L, position, position + 1, line, col, prev);
        } elseif 36 {
            // $
            return new Token(Token::DOLLAR, position, position + 1, line, col, prev);
        } elseif 35 {
            // #
            this->moveStringCursor(-1, -1 * bytes);
            return this->readComment(line, col, prev);
        } else {
            ;
            let tmpListNextCode = this->readChar();
            ;
            let nextCode = tmpListNextCode[1];
            ;
            let tmpListNextNextCode = this->moveStringCursor(1, 1)->readChar();
            ;
            let nextNextCode = tmpListNextNextCode[1];
            if nextCode === 34 && nextNextCode === 34 {
                return this->moveStringCursor(-2, -1 * bytes - 1)->readBlockString(line, col, prev);
            }
            return this->moveStringCursor(-2, -1 * bytes - 1)->readString(line, col, prev);
        }
        let errMessage =  code === 39 ? "Unexpected single quote character ('), did you mean to use " . "a double quote (\")?"  : "Cannot parse the unexpected character " . Utils::printCharCode(code) . ".";
        throw new SyntaxError(this->source, position, errMessage);
    }
    
    /**
     * Reads an alphanumeric + underscore name from the source.
     *
     * [_A-Za-z][_0-9A-Za-z]*
     *
     * @param int $line
     * @param int $col
     * @param Token $prev
     * @return Token
     */
    protected function readName(int line, int col, <Token> prev) -> <Token>
    {
        var value, start, char, code, tmpListCharCode;
    
        let value = "";
        let start =  this->position;
        let tmpListCharCode = this->readChar();
        let char = tmpListCharCode[0];
        let code = tmpListCharCode[1];
        while (code && (code === 95 || code >= 48 && code <= 57 || code >= 65 && code <= 90 || code >= 97 && code <= 122)) {
            let value .= char;
            let tmpListCharCode = this->moveStringCursor(1, 1)->readChar();
            let char = tmpListCharCode[0];
            let code = tmpListCharCode[1];
        }
        return new Token(Token::NAME, start, this->position, line, col, prev, value);
    }
    
    /**
     * Reads a number token from the source file, either a float
     * or an int depending on whether a decimal point appears.
     *
     * Int:   -?(0|[1-9][0-9]*)
     * Float: -?(0|[1-9][0-9]*)(\.[0-9]+)?((E|e)(+|-)?[0-9]+)?
     *
     * @param int $line
     * @param int $col
     * @param Token $prev
     * @return Token
     * @throws SyntaxError
     */
    protected function readNumber(int line, int col, <Token> prev) -> <Token>
    {
        var value, start, char, code, tmpListCharCode, isFloat;
    
        let value = "";
        let start =  this->position;
        let tmpListCharCode = this->readChar();
        let char = tmpListCharCode[0];
        let code = tmpListCharCode[1];
        let isFloat =  false;
        if code === 45 {
            // -
            let value .= char;
            let tmpListCharCode = this->moveStringCursor(1, 1)->readChar();
            let char = tmpListCharCode[0];
            let code = tmpListCharCode[1];
        }
        // guard against leading zero's
        if code === 48 {
            // 0
            let value .= char;
            let tmpListCharCode = this->moveStringCursor(1, 1)->readChar();
            let char = tmpListCharCode[0];
            let code = tmpListCharCode[1];
            if code >= 48 && code <= 57 {
                throw new SyntaxError(this->source, this->position, "Invalid number, unexpected digit after 0: " . Utils::printCharCode(code));
            }
        } else {
            let value .= this->readDigits();
            let tmpListCharCode = this->readChar();
            let char = tmpListCharCode[0];
            let code = tmpListCharCode[1];
        }
        if code === 46 {
            // .
            let isFloat =  true;
            this->moveStringCursor(1, 1);
            let value .= char;
            let value .= this->readDigits();
            let tmpListCharCode = this->readChar();
            let char = tmpListCharCode[0];
            let code = tmpListCharCode[1];
        }
        if code === 69 || code === 101 {
            // E e
            let isFloat =  true;
            let value .= char;
            let tmpListCharCode = this->moveStringCursor(1, 1)->readChar();
            let char = tmpListCharCode[0];
            let code = tmpListCharCode[1];
            if code === 43 || code === 45 {
                // + -
                let value .= char;
                this->moveStringCursor(1, 1);
            }
            let value .= this->readDigits();
        }
        return new Token( isFloat ? Token::FLOAT  : Token::INT, start, this->position, line, col, prev, value);
    }
    
    /**
     * Returns string with all digits + changes current string cursor position to point to the first char after digits
     */
    protected function readDigits()
    {
        var char, code, tmpListCharCode, value;
    
        let tmpListCharCode = this->readChar();
        let char = tmpListCharCode[0];
        let code = tmpListCharCode[1];
        if code >= 48 && code <= 57 {
            // 0 - 9
            let value = "";
            do {
                let value .= char;
                let tmpListCharCode = this->moveStringCursor(1, 1)->readChar();
                let char = tmpListCharCode[0];
                let code = tmpListCharCode[1];
            } while (code >= 48 && code <= 57);
            // 0 - 9
            return value;
        }
        if this->position > this->source->length - 1 {
            let code =  null;
        }
        throw new SyntaxError(this->source, this->position, "Invalid number, expected digit but got: " . Utils::printCharCode(code));
    }
    
    /**
     * @param int $line
     * @param int $col
     * @param Token $prev
     * @return Token
     * @throws SyntaxError
     */
    protected function readString(int line, int col, <Token> prev) -> <Token>
    {
        var start, char, code, bytes, tmpListCharCodeBytes, chunk, value, tmpListCode, position, hex, tmpListHex;
    
        let start =  this->position;
        // Skip leading quote and read first string char:
        let tmpListCharCodeBytes = this->moveStringCursor(1, 1)->readChar();
        let char = tmpListCharCodeBytes[0];
        let code = tmpListCharCodeBytes[1];
        let bytes = tmpListCharCodeBytes[2];
        let chunk = "";
        let value = "";
        while (code !== null && code !== 10 && code !== 13) {
            // Closing Quote (")
            if code === 34 {
                let value .= chunk;
                // Skip quote
                this->moveStringCursor(1, 1);
                return new Token(Token::STRING, start, this->position, line, col, prev, value);
            }
            this->assertValidStringCharacterCode(code, this->position);
            this->moveStringCursor(1, bytes);
            if code === 92 {
                // \
                let value .= chunk;
                ;
                let tmpListCode = this->readChar(true);
                ;
                let code = tmpListCode[1];
                if 34 {
                    let value .= "\"";
                } elseif 117 {
                    let position =  this->position;
                    let tmpListHex = this->readChars(4, true);
                    let hex = tmpListHex[0];
                    if !(preg_match("/[0-9a-fA-F]{4}/", hex)) {
                        throw new SyntaxError(this->source, position - 1, "Invalid character escape sequence: \\u" . hex);
                    }
                    let code =  hexdec(hex);
                    this->assertValidStringCharacterCode(code, position - 2);
                    let value .= Utils::chr(code);
                } elseif 116 {
                    let value .= "	";
                } elseif 114 {
                    let value .= "";
                } elseif 110 {
                    let value .= "
";
                } elseif 102 {
                    let value .= "";
                } elseif 98 {
                    let value .= chr(8);
                } elseif 92 {
                    let value .= "\\";
                } elseif 47 {
                    let value .= "/";
                } else {
                    throw new SyntaxError(this->source, this->position - 1, "Invalid character escape sequence: \\" . Utils::chr(code));
                }
                let chunk = "";
            } else {
                let chunk .= char;
            }
            let tmpListCharCodeBytes = this->readChar();
            let char = tmpListCharCodeBytes[0];
            let code = tmpListCharCodeBytes[1];
            let bytes = tmpListCharCodeBytes[2];
        }
        throw new SyntaxError(this->source, this->position, "Unterminated string.");
    }
    
    /**
     * Reads a block string token from the source file.
     *
     * """("?"?(\\"""|\\(?!=""")|[^"\\]))*"""
     */
    protected function readBlockString(line, col, <Token> prev)
    {
        var start, char, code, bytes, tmpListCharCodeBytes, chunk, value, nextCode, tmpListNextCode, nextNextCode, tmpListNextNextCode, nextNextNextCode, tmpListNextNextNextCode;
    
        let start =  this->position;
        // Skip leading quotes and read first string char:
        let tmpListCharCodeBytes = this->moveStringCursor(3, 3)->readChar();
        let char = tmpListCharCodeBytes[0];
        let code = tmpListCharCodeBytes[1];
        let bytes = tmpListCharCodeBytes[2];
        let chunk = "";
        let value = "";
        while (code !== null) {
            // Closing Triple-Quote (""")
            if code === 34 {
                // Move 2 quotes
                ;
                let tmpListNextCode = this->moveStringCursor(1, 1)->readChar();
                ;
                let nextCode = tmpListNextCode[1];
                ;
                let tmpListNextNextCode = this->moveStringCursor(1, 1)->readChar();
                ;
                let nextNextCode = tmpListNextNextCode[1];
                if nextCode === 34 && nextNextCode === 34 {
                    let value .= chunk;
                    this->moveStringCursor(1, 1);
                    return new Token(Token::BLOCK_STRING, start, this->position, line, col, prev, BlockString::value(value));
                } else {
                    // move cursor back to before the first quote
                    this->moveStringCursor(-2, -2);
                }
            }
            this->assertValidBlockStringCharacterCode(code, this->position);
            this->moveStringCursor(1, bytes);
            ;
            let tmpListNextCode = this->readChar();
            ;
            let nextCode = tmpListNextCode[1];
            ;
            let tmpListNextNextCode = this->moveStringCursor(1, 1)->readChar();
            ;
            let nextNextCode = tmpListNextNextCode[1];
            ;
            let tmpListNextNextNextCode = this->moveStringCursor(1, 1)->readChar();
            ;
            let nextNextNextCode = tmpListNextNextNextCode[1];
            // Escape Triple-Quote (\""")
            if code === 92 && nextCode === 34 && nextNextCode === 34 && nextNextNextCode === 34 {
                this->moveStringCursor(1, 1);
                let value .= chunk . "\"\"\"";
                let chunk = "";
            } else {
                this->moveStringCursor(-2, -2);
                let chunk .= char;
            }
            let tmpListCharCodeBytes = this->readChar();
            let char = tmpListCharCodeBytes[0];
            let code = tmpListCharCodeBytes[1];
            let bytes = tmpListCharCodeBytes[2];
        }
        throw new SyntaxError(this->source, this->position, "Unterminated string.");
    }
    
    protected function assertValidStringCharacterCode(code, position) -> void
    {
        // SourceCharacter
        if code < 32 && code !== 9 {
            throw new SyntaxError(this->source, position, "Invalid character within String: " . Utils::printCharCode(code));
        }
    }
    
    protected function assertValidBlockStringCharacterCode(code, position) -> void
    {
        // SourceCharacter
        if code < 32 && code !== 9 && code !== 10 && code !== 13 {
            throw new SyntaxError(this->source, position, "Invalid character within String: " . Utils::printCharCode(code));
        }
    }
    
    /**
     * Reads from body starting at startPosition until it finds a non-whitespace
     * or commented character, then places cursor to the position of that character.
     */
    protected function positionAfterWhitespace() -> void
    {
        var code, bytes, tmpListCodeBytes, nextCode, nextBytes, tmpListNextCodeNextBytes;
    
        while (this->position < this->source->length) {
            ;
            let tmpListCodeBytes = this->readChar();
            ;
            let code = tmpListCodeBytes[1];
            let bytes = tmpListCodeBytes[2];
            // Skip whitespace
            // tab | space | comma | BOM
            if code === 9 || code === 32 || code === 44 || code === 65279 {
                this->moveStringCursor(1, bytes);
            } else {
                if code === 10 {
                    // new line
                    this->moveStringCursor(1, bytes);
                    let this->line++;
                    let this->lineStart =  this->position;
                } else {
                    if code === 13 {
                        // carriage return
                        ;
                        let tmpListNextCodeNextBytes = this->moveStringCursor(1, bytes)->readChar();
                        ;
                        let nextCode = tmpListNextCodeNextBytes[1];
                        let nextBytes = tmpListNextCodeNextBytes[2];
                        if nextCode === 10 {
                            // lf after cr
                            this->moveStringCursor(1, nextBytes);
                        }
                        let this->line++;
                        let this->lineStart =  this->position;
                    } else {
                        break;
                    }
                }
            }
        }
    }
    
    /**
     * Reads a comment token from the source file.
     *
     * #[\u0009\u0020-\uFFFF]*
     *
     * @param $line
     * @param $col
     * @param Token $prev
     * @return Token
     */
    protected function readComment(line, col, <Token> prev) -> <Token>
    {
        var start, value, bytes, char, code, tmpListCharCodeBytes;
    
        let start =  this->position;
        let value = "";
        let bytes = 1;
        do {
            let tmpListCharCodeBytes = this->moveStringCursor(1, bytes)->readChar();
            let char = tmpListCharCodeBytes[0];
            let code = tmpListCharCodeBytes[1];
            let bytes = tmpListCharCodeBytes[2];
            let value .= char;
        } while (code && (code > 31 || code === 9));
        return new Token(Token::COMMENT, start, this->position, line, col, prev, value);
    }
    
    /**
     * Reads next UTF8Character from the byte stream, starting from $byteStreamPosition.
     *
     * @param bool $advance
     * @param int $byteStreamPosition
     * @return array
     */
    protected function readChar(bool advance = false, int byteStreamPosition = null) -> array
    {
        var code, utf8char, bytes, positionOffset, ord, pos, tmpArrayc36802b81443e21fc8bc886e5692ff07;
    
        if byteStreamPosition === null {
            let byteStreamPosition =  this->byteStreamPosition;
        }
        let code =  null;
        let utf8char = "";
        let bytes = 0;
        let positionOffset = 0;
        if isset this->source->body[byteStreamPosition] {
            let ord =  ord(this->source->body[byteStreamPosition]);
            if ord < 128 {
                let bytes = 1;
            } else {
                if ord < 224 {
                    let bytes = 2;
                } elseif ord < 240 {
                    let bytes = 3;
                } else {
                    let bytes = 4;
                }
            }
            let utf8char = "";
            let pos = byteStreamPosition;
            for pos in range(byteStreamPosition, byteStreamPosition + bytes) {
                let utf8char .= this->source->body[pos];
            }
            let positionOffset = 1;
            let code =  bytes === 1 ? ord  : Utils::ord(utf8char);
        }
        if advance {
            this->moveStringCursor(positionOffset, bytes);
        }
        let tmpArrayc36802b81443e21fc8bc886e5692ff07 = [utf8char, code, bytes];
        return tmpArrayc36802b81443e21fc8bc886e5692ff07;
    }
    
    /**
     * Reads next $numberOfChars UTF8 characters from the byte stream, starting from $byteStreamPosition.
     *
     * @param $numberOfChars
     * @param bool $advance
     * @param null $byteStreamPosition
     * @return array
     */
    protected function readChars(numberOfChars, bool advance = false, null byteStreamPosition = null) -> array
    {
        var result, totalBytes, byteOffset, i, char, code, bytes, tmpListCharCodeBytes, tmpArrayf3b6da50b25f3ac7aa6b7c2c3660203d;
    
        let result = "";
        let totalBytes = 0;
        let byteOffset =  byteStreamPosition ? byteStreamPosition : this->byteStreamPosition;
        let i = 0;
        for i in range(0, numberOfChars) {
            let tmpListCharCodeBytes = this->readChar(false, byteOffset);
            let char = tmpListCharCodeBytes[0];
            let code = tmpListCharCodeBytes[1];
            let bytes = tmpListCharCodeBytes[2];
            let totalBytes += bytes;
            let byteOffset += bytes;
            let result .= char;
        }
        if advance {
            this->moveStringCursor(numberOfChars, totalBytes);
        }
        let tmpArrayf3b6da50b25f3ac7aa6b7c2c3660203d = [result, totalBytes];
        return tmpArrayf3b6da50b25f3ac7aa6b7c2c3660203d;
    }
    
    /**
     * Moves internal string cursor position
     *
     * @param $positionOffset
     * @param $byteStreamOffset
     * @return $this
     */
    protected function moveStringCursor(positionOffset, byteStreamOffset)
    {
        let this->position += positionOffset;
        let this->byteStreamPosition += byteStreamOffset;
        return this;
    }

}