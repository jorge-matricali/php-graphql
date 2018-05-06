namespace GraphQL\Language;

/**
 * Represents a range of characters represented by a lexical token
 * within a Source.
 */
class Token
{
    // Each kind of token.
    const SOF = "<SOF>";
    const EOF = "<EOF>";
    const BANG = "!";
    const DOLLAR = "$";
    const PAREN_L = "(";
    const PAREN_R = ")";
    const SPREAD = "...";
    const COLON = ":";
    const EQUALS = "=";
    const AT = "@";
    const BRACKET_L = "[";
    const BRACKET_R = "]";
    const BRACE_L = "{";
    const PIPE = "|";
    const BRACE_R = "}";
    const NAME = "Name";
    const INT = "Int";
    const FLOAT = "Float";
    const STRING = "String";
    const BLOCK_STRING = "BlockString";
    const COMMENT = "Comment";
    /**
     * @param $kind
     * @return mixed
     */
    public static function getKindDescription(kind)
    {
        var description;
    
        trigger_error("Deprecated as of 16.10.2016 ($kind itself contains description string now)", E_USER_DEPRECATED);
        let description =  [];
        let description[self::SOF] = "<SOF>";
        let description[self::EOF] = "<EOF>";
        let description[self::BANG] = "!";
        let description[self::DOLLAR] = "$";
        let description[self::PAREN_L] = "(";
        let description[self::PAREN_R] = ")";
        let description[self::SPREAD] = "...";
        let description[self::COLON] = ":";
        let description[self::EQUALS] = "=";
        let description[self::AT] = "@";
        let description[self::BRACKET_L] = "[";
        let description[self::BRACKET_R] = "]";
        let description[self::BRACE_L] = "{";
        let description[self::PIPE] = "|";
        let description[self::BRACE_R] = "}";
        let description[self::NAME] = "Name";
        let description[self::INT] = "Int";
        let description[self::FLOAT] = "Float";
        let description[self::STRING] = "String";
        let description[self::BLOCK_STRING] = "BlockString";
        let description[self::COMMENT] = "Comment";
        return description[kind];
    }
    
    /**
     * The kind of Token (see one of constants above).
     *
     * @var string
     */
    public kind;
    /**
     * The character offset at which this Node begins.
     *
     * @var int
     */
    public start;
    /**
     * The character offset at which this Node ends.
     *
     * @var int
     */
    public end;
    /**
     * The 1-indexed line number on which this Token appears.
     *
     * @var int
     */
    public line;
    /**
     * The 1-indexed column number at which this Token begins.
     *
     * @var int
     */
    public column;
    /**
     * @var string|null
     */
    public value;
    /**
     * Tokens exist as nodes in a double-linked-list amongst all tokens
     * including ignored tokens. <SOF> is always the first node and <EOF>
     * the last.
     *
     * @var Token
     */
    public prev;
    /**
     * @var Token
     */
    public next;
    /**
     * Token constructor.
     * @param $kind
     * @param $start
     * @param $end
     * @param $line
     * @param $column
     * @param Token $previous
     * @param null $value
     */
    public function __construct(kind, start, end, line, column, <Token> previous = null, null value = null) -> void
    {
        let this->kind = kind;
        let this->start =  (int) start;
        let this->end =  (int) end;
        let this->line =  (int) line;
        let this->column =  (int) column;
        let this->prev = previous;
        let this->next =  null;
        let this->value = value;
    }
    
    /**
     * @return string
     */
    public function getDescription() -> string
    {
        return this->kind . ( this->value ? " \"" . this->value . "\""  : "");
    }
    
    /**
     * @return array
     */
    public function toArray() -> array
    {
        var tmpArray79fe37a462574cda26f1abe463f7870d;
    
        let tmpArray79fe37a462574cda26f1abe463f7870d = ["kind" : this->kind, "value" : this->value, "line" : this->line, "column" : this->column];
        return tmpArray79fe37a462574cda26f1abe463f7870d;
    }

}