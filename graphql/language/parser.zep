namespace GraphQL\Language;

use GraphQL\Language\AST\ArgumentNode;
use GraphQL\Language\AST\DirectiveDefinitionNode;
use GraphQL\Language\AST\EnumTypeDefinitionNode;
use GraphQL\Language\AST\EnumTypeExtensionNode;
use GraphQL\Language\AST\EnumValueDefinitionNode;
use GraphQL\Language\AST\ExecutableDefinitionNode;
use GraphQL\Language\AST\FieldDefinitionNode;
use GraphQL\Language\AST\InputObjectTypeDefinitionNode;
use GraphQL\Language\AST\InputObjectTypeExtensionNode;
use GraphQL\Language\AST\InputValueDefinitionNode;
use GraphQL\Language\AST\InterfaceTypeDefinitionNode;
use GraphQL\Language\AST\InterfaceTypeExtensionNode;
use GraphQL\Language\AST\ListValueNode;
use GraphQL\Language\AST\BooleanValueNode;
use GraphQL\Language\AST\DirectiveNode;
use GraphQL\Language\AST\DocumentNode;
use GraphQL\Language\AST\EnumValueNode;
use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\FloatValueNode;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\FragmentSpreadNode;
use GraphQL\Language\AST\InlineFragmentNode;
use GraphQL\Language\AST\IntValueNode;
use GraphQL\Language\AST\ListTypeNode;
use GraphQL\Language\AST\Location;
use GraphQL\Language\AST\NameNode;
use GraphQL\Language\AST\NamedTypeNode;
use GraphQL\Language\AST\NodeList;
use GraphQL\Language\AST\NonNullTypeNode;
use GraphQL\Language\AST\NullValueNode;
use GraphQL\Language\AST\ObjectFieldNode;
use GraphQL\Language\AST\ObjectTypeDefinitionNode;
use GraphQL\Language\AST\ObjectValueNode;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Language\AST\OperationTypeDefinitionNode;
use GraphQL\Language\AST\ScalarTypeDefinitionNode;
use GraphQL\Language\AST\ScalarTypeExtensionNode;
use GraphQL\Language\AST\SchemaDefinitionNode;
use GraphQL\Language\AST\SelectionSetNode;
use GraphQL\Language\AST\StringValueNode;
use GraphQL\Language\AST\ObjectTypeExtensionNode;
use GraphQL\Language\AST\TypeExtensionNode;
use GraphQL\Language\AST\TypeSystemDefinitionNode;
use GraphQL\Language\AST\UnionTypeDefinitionNode;
use GraphQL\Language\AST\UnionTypeExtensionNode;
use GraphQL\Language\AST\VariableNode;
use GraphQL\Language\AST\VariableDefinitionNode;
use GraphQL\Error\SyntaxError;
/**
 * Parses string containing GraphQL query or [type definition](type-system/type-language.md) to Abstract Syntax Tree.
 */
class Parser
{
    /**
     * Given a GraphQL source, parses it into a `GraphQL\Language\AST\DocumentNode`.
     * Throws `GraphQL\Error\SyntaxError` if a syntax error is encountered.
     *
     * Available options:
     *
     * noLocation: boolean,
     * (By default, the parser creates AST nodes that know the location
     * in the source that they correspond to. This configuration flag
     * disables that behavior for performance or testing.)
     *
     * experimentalFragmentVariables: boolean,
     * (If enabled, the parser will understand and parse variable definitions
     * contained in a fragment definition. They'll be represented in the
     * `variableDefinitions` field of the FragmentDefinitionNode.
     *
     * The syntax is identical to normal, query-defined variables. For example:
     *
     *   fragment A($var: Boolean = false) on T  {
     *     ...
     *   }
     *
     * Note: this feature is experimental and may change or be removed in the
     * future.)
     *
     * @api
     * @param Source|string $source
     * @param array $options
     * @return DocumentNode
     * @throws SyntaxError
     */
    public static function parse(source, array options = []) -> <DocumentNode>
    {
        var sourceObj, parser;
    
        let sourceObj =  source instanceof Source ? source  : new Source(source);
        let parser =  new self(sourceObj, options);
        return parser->parseDocument();
    }
    
    /**
     * Given a string containing a GraphQL value (ex. `[42]`), parse the AST for
     * that value.
     * Throws `GraphQL\Error\SyntaxError` if a syntax error is encountered.
     *
     * This is useful within tools that operate upon GraphQL Values directly and
     * in isolation of complete GraphQL documents.
     *
     * Consider providing the results to the utility function: `GraphQL\Utils\AST::valueFromAST()`.
     *
     * @api
     * @param Source|string $source
     * @param array $options
     * @return BooleanValueNode|EnumValueNode|FloatValueNode|IntValueNode|ListValueNode|ObjectValueNode|StringValueNode|VariableNode
     */
    public static function parseValue(source, array options = [])
    {
        var sourceObj, parser, value;
    
        let sourceObj =  source instanceof Source ? source  : new Source(source);
        let parser =  new Parser(sourceObj, options);
        parser->expect(Token::SOF);
        let value =  parser->parseValueLiteral(false);
        parser->expect(Token::EOF);
        return value;
    }
    
    /**
     * Given a string containing a GraphQL Type (ex. `[Int!]`), parse the AST for
     * that type.
     * Throws `GraphQL\Error\SyntaxError` if a syntax error is encountered.
     *
     * This is useful within tools that operate upon GraphQL Types directly and
     * in isolation of complete GraphQL documents.
     *
     * Consider providing the results to the utility function: `GraphQL\Utils\AST::typeFromAST()`.
     *
     * @api
     * @param Source|string $source
     * @param array $options
     * @return ListTypeNode|NameNode|NonNullTypeNode
     */
    public static function parseType(source, array options = [])
    {
        var sourceObj, parser, type;
    
        let sourceObj =  source instanceof Source ? source  : new Source(source);
        let parser =  new Parser(sourceObj, options);
        parser->expect(Token::SOF);
        let type =  parser->parseTypeReference();
        parser->expect(Token::EOF);
        return type;
    }
    
    /**
     * @var Lexer
     */
    protected lexer;
    /**
     * Parser constructor.
     * @param Source $source
     * @param array $options
     */
    function __construct(<Source> source, array options = []) -> void
    {
        let this->lexer =  new Lexer(source, options);
    }
    
    /**
     * Returns a location object, used to identify the place in
     * the source that created a given parsed object.
     *
     * @param Token $startToken
     * @return Location|null
     */
    function loc(<Token> startToken)
    {
        if empty(this->lexer->options["noLocation"]) {
            return new Location(startToken, this->lexer->lastToken, this->lexer->source);
        }
        return null;
    }
    
    /**
     * Determines if the next token is of a given kind
     *
     * @param $kind
     * @return bool
     */
    function peek(kind) -> bool
    {
        return this->lexer->token->kind === kind;
    }
    
    /**
     * If the next token is of the given kind, return true after advancing
     * the parser. Otherwise, do not change the parser state and return false.
     *
     * @param $kind
     * @return bool
     */
    function skip(kind) -> bool
    {
        var match;
    
        let match =  this->lexer->token->kind === kind;
        if match {
            this->lexer->advance();
        }
        return match;
    }
    
    /**
     * If the next token is of the given kind, return that token after advancing
     * the parser. Otherwise, do not change the parser state and return false.
     * @param string $kind
     * @return Token
     * @throws SyntaxError
     */
    function expect(string kind) -> <Token>
    {
        var token;
    
        let token =  this->lexer->token;
        if token->kind === kind {
            this->lexer->advance();
            return token;
        }
        throw new SyntaxError(this->lexer->source, token->start, "Expected {kind}, found " . token->getDescription());
    }
    
    /**
     * If the next token is a keyword with the given value, return that token after
     * advancing the parser. Otherwise, do not change the parser state and return
     * false.
     *
     * @param string $value
     * @return Token
     * @throws SyntaxError
     */
    function expectKeyword(string value) -> <Token>
    {
        var token;
    
        let token =  this->lexer->token;
        if token->kind === Token::NAME && token->value === value {
            this->lexer->advance();
            return token;
        }
        throw new SyntaxError(this->lexer->source, token->start, "Expected \"" . value . "\", found " . token->getDescription());
    }
    
    /**
     * @param Token|null $atToken
     * @return SyntaxError
     */
    function unexpected(<Token> atToken = null) -> <SyntaxError>
    {
        var token;
    
        let token =  atToken ? atToken : this->lexer->token;
        return new SyntaxError(this->lexer->source, token->start, "Unexpected " . token->getDescription());
    }
    
    /**
     * Returns a possibly empty list of parse nodes, determined by
     * the parseFn. This list begins with a lex token of openKind
     * and ends with a lex token of closeKind. Advances the parser
     * to the next lex token after the closing token.
     *
     * @param int $openKind
     * @param callable $parseFn
     * @param int $closeKind
     * @return NodeList
     * @throws SyntaxError
     */
    function any(int openKind, parseFn, int closeKind) -> <NodeList>
    {
        var nodes;
    
        this->expect(openKind);
        let nodes =  [];
        while (!(this->skip(closeKind))) {
            let nodes[] =  {parseFn}(this);
        }
        return new NodeList(nodes);
    }
    
    /**
     * Returns a non-empty list of parse nodes, determined by
     * the parseFn. This list begins with a lex token of openKind
     * and ends with a lex token of closeKind. Advances the parser
     * to the next lex token after the closing token.
     *
     * @param $openKind
     * @param $parseFn
     * @param $closeKind
     * @return NodeList
     * @throws SyntaxError
     */
    function many(openKind, parseFn, closeKind) -> <NodeList>
    {
        var nodes;
    
        this->expect(openKind);
        let nodes =  [{parseFn}(this)];
        while (!(this->skip(closeKind))) {
            let nodes[] =  {parseFn}(this);
        }
        return new NodeList(nodes);
    }
    
    /**
     * Converts a name lex token into a name parse node.
     *
     * @return NameNode
     * @throws SyntaxError
     */
    function parseName() -> <NameNode>
    {
        var token, tmpArrayd184210e1907fe7db91d198282cb8d7a;
    
        let token =  this->expect(Token::NAME);
        let tmpArrayd184210e1907fe7db91d198282cb8d7a = ["value" : token->value, "loc" : this->loc(token)];
        return new NameNode(tmpArrayd184210e1907fe7db91d198282cb8d7a);
    }
    
    /**
     * Implements the parsing rules in the Document section.
     *
     * @return DocumentNode
     * @throws SyntaxError
     */
    function parseDocument() -> <DocumentNode>
    {
        var start, definitions, tmpArrayadea1b85cdde6d0c3f94264cffcac0f0;
    
        let start =  this->lexer->token;
        this->expect(Token::SOF);
        let definitions =  [];
        do {
            let definitions[] =  this->parseDefinition();
        } while (!(this->skip(Token::EOF)));
        let tmpArrayadea1b85cdde6d0c3f94264cffcac0f0 = ["definitions" : new NodeList(definitions), "loc" : this->loc(start)];
        return new DocumentNode(tmpArrayadea1b85cdde6d0c3f94264cffcac0f0);
    }
    
    /**
     * @return ExecutableDefinitionNode|TypeSystemDefinitionNode
     * @throws SyntaxError
     */
    function parseDefinition()
    {
        if this->peek(Token::NAME) {
            switch (this->lexer->token->value) {
                case "query":
                case "mutation":
                case "subscription":
                case "fragment":
                    return this->parseExecutableDefinition();
                // Note: The schema definition language is an experimental addition.
                case "schema":
                case "scalar":
                case "type":
                case "interface":
                case "union":
                case "enum":
                case "input":
                case "extend":
                case "directive":
                    // Note: The schema definition language is an experimental addition.
                    return this->parseTypeSystemDefinition();
            }
        } else {
            if this->peek(Token::BRACE_L) {
                return this->parseExecutableDefinition();
            } else {
                if this->peekDescription() {
                    // Note: The schema definition language is an experimental addition.
                    return this->parseTypeSystemDefinition();
                }
            }
        }
        throw this->unexpected();
    }
    
    /**
     * @return ExecutableDefinitionNode
     * @throws SyntaxError
     */
    function parseExecutableDefinition() -> <ExecutableDefinitionNode>
    {
        if this->peek(Token::NAME) {
            switch (this->lexer->token->value) {
                case "query":
                case "mutation":
                case "subscription":
                    return this->parseOperationDefinition();
                case "fragment":
                    return this->parseFragmentDefinition();
            }
        } else {
            if this->peek(Token::BRACE_L) {
                return this->parseOperationDefinition();
            }
        }
        throw this->unexpected();
    }
    
    // Implements the parsing rules in the Operations section.
    /**
     * @return OperationDefinitionNode
     * @throws SyntaxError
     */
    function parseOperationDefinition()
    {
        var start, tmpArray3852a8a7b056f80ca8e59acbbdddfb8b, tmpArray40cd750bba9870f18aada2478b24840a, operation, name, tmpArray6c83273405f23ee067d31231a134a76f;
    
        let start =  this->lexer->token;
        if this->peek(Token::BRACE_L) {
            let tmpArray3852a8a7b056f80ca8e59acbbdddfb8b = ["operation" : "query", "name" : null, "variableDefinitions" : new NodeList(tmpArray40cd750bba9870f18aada2478b24840a), "directives" : new NodeList(tmpArray40cd750bba9870f18aada2478b24840a), "selectionSet" : this->parseSelectionSet(), "loc" : this->loc(start)];
            return new OperationDefinitionNode(tmpArray1957614e6091a42925981bf630c21193);
        }
        let operation =  this->parseOperationType();
        let name =  null;
        if this->peek(Token::NAME) {
            let name =  this->parseName();
        }
        let tmpArray6c83273405f23ee067d31231a134a76f = ["operation" : operation, "name" : name, "variableDefinitions" : this->parseVariableDefinitions(), "directives" : this->parseDirectives(false), "selectionSet" : this->parseSelectionSet(), "loc" : this->loc(start)];
        return new OperationDefinitionNode(tmpArray6c83273405f23ee067d31231a134a76f);
    }
    
    /**
     * @return string
     * @throws SyntaxError
     */
    function parseOperationType() -> string
    {
        var operationToken;
    
        let operationToken =  this->expect(Token::NAME);
        switch (operationToken->value) {
            case "query":
                return "query";
            case "mutation":
                return "mutation";
            case "subscription":
                return "subscription";
        }
        throw this->unexpected(operationToken);
    }
    
    /**
     * @return VariableDefinitionNode[]|NodeList
     */
    function parseVariableDefinitions()
    {
        var tmpArray2460d8e0a28850c865cde0dd48838bc3, tmpArray40cd750bba9870f18aada2478b24840a;
    
        let tmpArray2460d8e0a28850c865cde0dd48838bc3 = [this, "parseVariableDefinition"];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return  this->peek(Token::PAREN_L) ? this->many(Token::PAREN_L, tmpArray2460d8e0a28850c865cde0dd48838bc3, Token::PAREN_R)  : new NodeList(tmpArray40cd750bba9870f18aada2478b24840a);
    }
    
    /**
     * @return VariableDefinitionNode
     * @throws SyntaxError
     */
    function parseVariableDefinition() -> <VariableDefinitionNode>
    {
        var start, varr, type, tmpArray8b4aff80d3c8451b0f664a007a10678c;
    
        let start =  this->lexer->token;
        let varr =  this->parseVariable();
        this->expect(Token::COLON);
        let type =  this->parseTypeReference();
        let tmpArray8b4aff80d3c8451b0f664a007a10678c = ["variable" : varr, "type" : type, "defaultValue" :  this->skip(Token::EQUALS) ? this->parseValueLiteral(true)  : null, "loc" : this->loc(start)];
        return new VariableDefinitionNode(tmpArray8b4aff80d3c8451b0f664a007a10678c);
    }
    
    /**
     * @return VariableNode
     * @throws SyntaxError
     */
    function parseVariable() -> <VariableNode>
    {
        var start, tmpArray6410d4c190ed40b87aefa02259760e3c;
    
        let start =  this->lexer->token;
        this->expect(Token::DOLLAR);
        let tmpArray6410d4c190ed40b87aefa02259760e3c = ["name" : this->parseName(), "loc" : this->loc(start)];
        return new VariableNode(tmpArray6410d4c190ed40b87aefa02259760e3c);
    }
    
    /**
     * @return SelectionSetNode
     */
    function parseSelectionSet() -> <SelectionSetNode>
    {
        var start, tmpArray967dcf3c1f0622e4177d9b00a7966199, tmpArrayb54359e5f5387f3e5b64c544f45e58fe;
    
        let start =  this->lexer->token;
        let tmpArray967dcf3c1f0622e4177d9b00a7966199 = ["selections" : this->many(Token::BRACE_L, tmpArrayb54359e5f5387f3e5b64c544f45e58fe, Token::BRACE_R), "loc" : this->loc(start)];
        return new SelectionSetNode(tmpArray4cfea32a7199d620ea0acd52ff11e331);
    }
    
    /**
     *  Selection :
     *   - Field
     *   - FragmentSpread
     *   - InlineFragment
     *
     * @return mixed
     */
    function parseSelection()
    {
        return  this->peek(Token::SPREAD) ? this->parseFragment()  : this->parseField();
    }
    
    /**
     * @return FieldNode
     * @throws SyntaxError
     */
    function parseField() -> <FieldNode>
    {
        var start, nameOrAlias, alias, name, tmpArray121c0778aea4761c94fd35e2865fc045;
    
        let start =  this->lexer->token;
        let nameOrAlias =  this->parseName();
        if this->skip(Token::COLON) {
            let alias = nameOrAlias;
            let name =  this->parseName();
        } else {
            let alias =  null;
            let name = nameOrAlias;
        }
        let tmpArray121c0778aea4761c94fd35e2865fc045 = ["alias" : alias, "name" : name, "arguments" : this->parseArguments(false), "directives" : this->parseDirectives(false), "selectionSet" :  this->peek(Token::BRACE_L) ? this->parseSelectionSet()  : null, "loc" : this->loc(start)];
        return new FieldNode(tmpArray121c0778aea4761c94fd35e2865fc045);
    }
    
    /**
     * @param bool $isConst
     * @return ArgumentNode[]|NodeList
     * @throws SyntaxError
     */
    function parseArguments(bool isConst)
    {
        var item, tmpArraydcd4a6e1a8459238918cb504339796fa, tmpArray40cd750bba9870f18aada2478b24840a;
    
        let item =  isConst ? "parseConstArgument"  : "parseArgument";
        let tmpArraydcd4a6e1a8459238918cb504339796fa = [this, item];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return  this->peek(Token::PAREN_L) ? this->many(Token::PAREN_L, tmpArraydcd4a6e1a8459238918cb504339796fa, Token::PAREN_R)  : new NodeList(tmpArray40cd750bba9870f18aada2478b24840a);
    }
    
    /**
     * @return ArgumentNode
     * @throws SyntaxError
     */
    function parseArgument() -> <ArgumentNode>
    {
        var start, name, value, tmpArraye85e34072cd11931354a7c944b217156;
    
        let start =  this->lexer->token;
        let name =  this->parseName();
        this->expect(Token::COLON);
        let value =  this->parseValueLiteral(false);
        let tmpArraye85e34072cd11931354a7c944b217156 = ["name" : name, "value" : value, "loc" : this->loc(start)];
        return new ArgumentNode(tmpArraye85e34072cd11931354a7c944b217156);
    }
    
    /**
     * @return ArgumentNode
     * @throws SyntaxError
     */
    function parseConstArgument() -> <ArgumentNode>
    {
        var start, name, value, tmpArrayeed720b2c277ded97a1ac54545e5f93f;
    
        let start =  this->lexer->token;
        let name =  this->parseName();
        this->expect(Token::COLON);
        let value =  this->parseConstValue();
        let tmpArrayeed720b2c277ded97a1ac54545e5f93f = ["name" : name, "value" : value, "loc" : this->loc(start)];
        return new ArgumentNode(tmpArrayeed720b2c277ded97a1ac54545e5f93f);
    }
    
    // Implements the parsing rules in the Fragments section.
    /**
     * @return FragmentSpreadNode|InlineFragmentNode
     * @throws SyntaxError
     */
    function parseFragment()
    {
        var start, tmpArray800ea00781b56b0634cbeb81c7b16a46, typeCondition, tmpArray117b83791c0bc931a3e0312b4cd31cc5;
    
        let start =  this->lexer->token;
        this->expect(Token::SPREAD);
        if this->peek(Token::NAME) && this->lexer->token->value !== "on" {
            let tmpArray800ea00781b56b0634cbeb81c7b16a46 = ["name" : this->parseFragmentName(), "directives" : this->parseDirectives(false), "loc" : this->loc(start)];
            return new FragmentSpreadNode(tmpArray800ea00781b56b0634cbeb81c7b16a46);
        }
        let typeCondition =  null;
        if this->lexer->token->value === "on" {
            this->lexer->advance();
            let typeCondition =  this->parseNamedType();
        }
        let tmpArray117b83791c0bc931a3e0312b4cd31cc5 = ["typeCondition" : typeCondition, "directives" : this->parseDirectives(false), "selectionSet" : this->parseSelectionSet(), "loc" : this->loc(start)];
        return new InlineFragmentNode(tmpArray117b83791c0bc931a3e0312b4cd31cc5);
    }
    
    /**
     * @return FragmentDefinitionNode
     * @throws SyntaxError
     */
    function parseFragmentDefinition() -> <FragmentDefinitionNode>
    {
        var start, name, variableDefinitions, typeCondition, tmpArraydbfa259d442ceb95238466c5f1facdba;
    
        let start =  this->lexer->token;
        this->expectKeyword("fragment");
        let name =  this->parseFragmentName();
        // Experimental support for defining variables within fragments changes
        // the grammar of FragmentDefinition:
        //   - fragment FragmentName VariableDefinitions? on TypeCondition Directives? SelectionSet
        let variableDefinitions =  null;
        if isset this->lexer->options["experimentalFragmentVariables"] {
            let variableDefinitions =  this->parseVariableDefinitions();
        }
        this->expectKeyword("on");
        let typeCondition =  this->parseNamedType();
        let tmpArraydbfa259d442ceb95238466c5f1facdba = ["name" : name, "variableDefinitions" : variableDefinitions, "typeCondition" : typeCondition, "directives" : this->parseDirectives(false), "selectionSet" : this->parseSelectionSet(), "loc" : this->loc(start)];
        return new FragmentDefinitionNode(tmpArraydbfa259d442ceb95238466c5f1facdba);
    }
    
    /**
     * @return NameNode
     * @throws SyntaxError
     */
    function parseFragmentName() -> <NameNode>
    {
        if this->lexer->token->value === "on" {
            throw this->unexpected();
        }
        return this->parseName();
    }
    
    // Implements the parsing rules in the Values section.
    /**
     * Value[Const] :
     *   - [~Const] Variable
     *   - IntValue
     *   - FloatValue
     *   - StringValue
     *   - BooleanValue
     *   - NullValue
     *   - EnumValue
     *   - ListValue[?Const]
     *   - ObjectValue[?Const]
     *
     * BooleanValue : one of `true` `false`
     *
     * NullValue : `null`
     *
     * EnumValue : Name but not `true`, `false` or `null`
     *
     * @param $isConst
     * @return BooleanValueNode|EnumValueNode|FloatValueNode|IntValueNode|StringValueNode|VariableNode|ListValueNode|ObjectValueNode|NullValueNode
     * @throws SyntaxError
     */
    function parseValueLiteral(isConst)
    {
        var token, tmpArray8abaa4fac6244048d5caaf05866a2fd9, tmpArrayfc4bfc166748557f1be3e1ab6b720817, tmpArray7dd987ec5ea23fea5c58c5b52c1338a2, tmpArray410baa167d4b6ff585c036403a05e1df, tmpArray241f5a62a9e6a7441a625fbc3f5b10b2;
    
        let token =  this->lexer->token;
        if Token::BRACKET_L {
            return this->parseArray(isConst);
        } elseif Token::NAME {
            if token->value === "true" || token->value === "false" {
                this->lexer->advance();
                let tmpArray7dd987ec5ea23fea5c58c5b52c1338a2 = ["value" : token->value === "true", "loc" : this->loc(token)];
                return new BooleanValueNode(tmpArray7dd987ec5ea23fea5c58c5b52c1338a2);
            } else {
                if token->value === "null" {
                    this->lexer->advance();
                    let tmpArray410baa167d4b6ff585c036403a05e1df = ["loc" : this->loc(token)];
                    return new NullValueNode(tmpArray410baa167d4b6ff585c036403a05e1df);
                } else {
                    this->lexer->advance();
                    let tmpArray241f5a62a9e6a7441a625fbc3f5b10b2 = ["value" : token->value, "loc" : this->loc(token)];
                    return new EnumValueNode(tmpArray241f5a62a9e6a7441a625fbc3f5b10b2);
                }
            }
        } elseif Token::STRING || Token::BLOCK_STRING {
            return this->parseStringLiteral();
        } elseif Token::FLOAT {
            this->lexer->advance();
            let tmpArrayfc4bfc166748557f1be3e1ab6b720817 = ["value" : token->value, "loc" : this->loc(token)];
            return new FloatValueNode(tmpArrayfc4bfc166748557f1be3e1ab6b720817);
        } elseif Token::INT {
            this->lexer->advance();
            let tmpArray8abaa4fac6244048d5caaf05866a2fd9 = ["value" : token->value, "loc" : this->loc(token)];
            return new IntValueNode(tmpArray8abaa4fac6244048d5caaf05866a2fd9);
        } elseif Token::BRACE_L {
            return this->parseObject(isConst);
        } else {
            if !(isConst) {
                return this->parseVariable();
            }
        }
        throw this->unexpected();
    }
    
    /**
     * @return StringValueNode
     */
    function parseStringLiteral() -> <StringValueNode>
    {
        var token, tmpArray5902d7e868fdd898c3e426b8e2b2b868;
    
        let token =  this->lexer->token;
        this->lexer->advance();
        let tmpArray5902d7e868fdd898c3e426b8e2b2b868 = ["value" : token->value, "block" : token->kind === Token::BLOCK_STRING, "loc" : this->loc(token)];
        return new StringValueNode(tmpArray5902d7e868fdd898c3e426b8e2b2b868);
    }
    
    /**
     * @return BooleanValueNode|EnumValueNode|FloatValueNode|IntValueNode|StringValueNode|VariableNode
     * @throws SyntaxError
     */
    function parseConstValue()
    {
        return this->parseValueLiteral(true);
    }
    
    /**
     * @return BooleanValueNode|EnumValueNode|FloatValueNode|IntValueNode|ListValueNode|ObjectValueNode|StringValueNode|VariableNode
     */
    function parseVariableValue()
    {
        return this->parseValueLiteral(false);
    }
    
    /**
     * @param bool $isConst
     * @return ListValueNode
     */
    function parseArray(bool isConst) -> <ListValueNode>
    {
        var start, item, tmpArray4798aa6662fbb67370837939610d0570, tmpArray7c99514bd94eadee02995bf63a872306;
    
        let start =  this->lexer->token;
        let item =  isConst ? "parseConstValue"  : "parseVariableValue";
        let tmpArray4798aa6662fbb67370837939610d0570 = ["values" : this->any(Token::BRACKET_L, tmpArray7c99514bd94eadee02995bf63a872306, Token::BRACKET_R), "loc" : this->loc(start)];
        return new ListValueNode(tmpArrayf1fe1a4e6ce86e14e0c6a3b40dcc1ca7);
    }
    
    /**
     * @param $isConst
     * @return ObjectValueNode
     */
    function parseObject(isConst) -> <ObjectValueNode>
    {
        var start, fields, tmpArrayc6628b01375f97f797c0bafb80879ca5;
    
        let start =  this->lexer->token;
        this->expect(Token::BRACE_L);
        let fields =  [];
        while (!(this->skip(Token::BRACE_R))) {
            let fields[] =  this->parseObjectField(isConst);
        }
        let tmpArrayc6628b01375f97f797c0bafb80879ca5 = ["fields" : new NodeList(fields), "loc" : this->loc(start)];
        return new ObjectValueNode(tmpArrayc6628b01375f97f797c0bafb80879ca5);
    }
    
    /**
     * @param $isConst
     * @return ObjectFieldNode
     */
    function parseObjectField(isConst) -> <ObjectFieldNode>
    {
        var start, name, tmpArrayf187ff8dcced64e7fc62096a362a71a6;
    
        let start =  this->lexer->token;
        let name =  this->parseName();
        this->expect(Token::COLON);
        let tmpArrayf187ff8dcced64e7fc62096a362a71a6 = ["name" : name, "value" : this->parseValueLiteral(isConst), "loc" : this->loc(start)];
        return new ObjectFieldNode(tmpArrayf187ff8dcced64e7fc62096a362a71a6);
    }
    
    // Implements the parsing rules in the Directives section.
    /**
     * @param bool $isConst
     * @return DirectiveNode[]|NodeList
     * @throws SyntaxError
     */
    function parseDirectives(isConst)
    {
        var directives;
    
        let directives =  [];
        while (this->peek(Token::AT)) {
            let directives[] =  this->parseDirective(isConst);
        }
        return new NodeList(directives);
    }
    
    /**
     * @param bool $isConst
     * @return DirectiveNode
     * @throws SyntaxError
     */
    function parseDirective(bool isConst) -> <DirectiveNode>
    {
        var start, tmpArray33a97023d60c2df2c5017b4fda85c4d7;
    
        let start =  this->lexer->token;
        this->expect(Token::AT);
        let tmpArray33a97023d60c2df2c5017b4fda85c4d7 = ["name" : this->parseName(), "arguments" : this->parseArguments(isConst), "loc" : this->loc(start)];
        return new DirectiveNode(tmpArray33a97023d60c2df2c5017b4fda85c4d7);
    }
    
    // Implements the parsing rules in the Types section.
    /**
     * Handles the Type: TypeName, ListType, and NonNullType parsing rules.
     *
     * @return ListTypeNode|NameNode|NonNullTypeNode
     * @throws SyntaxError
     */
    function parseTypeReference()
    {
        var start, type, tmpArrayb4f565ea0ea612d1095b90b2be478b9e, tmpArray9f82cdf5b5c538013ab9073495c99bf2;
    
        let start =  this->lexer->token;
        if this->skip(Token::BRACKET_L) {
            let type =  this->parseTypeReference();
            this->expect(Token::BRACKET_R);
            let type =  new ListTypeNode(["type" : type, "loc" : this->loc(start)]);
        } else {
            let type =  this->parseNamedType();
        }
        if this->skip(Token::BANG) {
            let tmpArray9f82cdf5b5c538013ab9073495c99bf2 = ["type" : type, "loc" : this->loc(start)];
            return new NonNullTypeNode(tmpArray9f82cdf5b5c538013ab9073495c99bf2);
        }
        return type;
    }
    
    function parseNamedType()
    {
        var start, tmpArray3113577239e30ba9b583683d47fe8206;
    
        let start =  this->lexer->token;
        let tmpArray3113577239e30ba9b583683d47fe8206 = ["name" : this->parseName(), "loc" : this->loc(start)];
        return new NamedTypeNode(tmpArray3113577239e30ba9b583683d47fe8206);
    }
    
    // Implements the parsing rules in the Type Definition section.
    /**
     * TypeSystemDefinition :
     *   - SchemaDefinition
     *   - TypeDefinition
     *   - TypeExtension
     *   - DirectiveDefinition
     *
     * TypeDefinition :
     *   - ScalarTypeDefinition
     *   - ObjectTypeDefinition
     *   - InterfaceTypeDefinition
     *   - UnionTypeDefinition
     *   - EnumTypeDefinition
     *   - InputObjectTypeDefinition
     *
     * @return TypeSystemDefinitionNode
     * @throws SyntaxError
     */
    function parseTypeSystemDefinition()
    {
        var keywordToken;
    
        // Many definitions begin with a description and require a lookahead.
        let keywordToken =  this->peekDescription() ? this->lexer->lookahead()  : this->lexer->token;
        if keywordToken->kind === Token::NAME {
            switch (keywordToken->value) {
                case "schema":
                    return this->parseSchemaDefinition();
                case "scalar":
                    return this->parseScalarTypeDefinition();
                case "type":
                    return this->parseObjectTypeDefinition();
                case "interface":
                    return this->parseInterfaceTypeDefinition();
                case "union":
                    return this->parseUnionTypeDefinition();
                case "enum":
                    return this->parseEnumTypeDefinition();
                case "input":
                    return this->parseInputObjectTypeDefinition();
                case "extend":
                    return this->parseTypeExtension();
                case "directive":
                    return this->parseDirectiveDefinition();
            }
        }
        throw this->unexpected(keywordToken);
    }
    
    /**
     * @return bool
     */
    function peekDescription() -> bool
    {
        return this->peek(Token::STRING) || this->peek(Token::BLOCK_STRING);
    }
    
    /**
     * @return StringValueNode|null
     */
    function parseDescription()
    {
        if this->peekDescription() {
            return this->parseStringLiteral();
        }
    }
    
    /**
     * @return SchemaDefinitionNode
     * @throws SyntaxError
     */
    function parseSchemaDefinition() -> <SchemaDefinitionNode>
    {
        var start, directives, operationTypes, tmpArray01d038655efe5d7164dd2657b7ba3ad5, tmpArrayac38a4fe9bb1f59f2b0c8e634325d3af;
    
        let start =  this->lexer->token;
        this->expectKeyword("schema");
        let directives =  this->parseDirectives(true);
        let tmpArray01d038655efe5d7164dd2657b7ba3ad5 = [this, "parseOperationTypeDefinition"];
        let operationTypes =  this->many(Token::BRACE_L, tmpArray01d038655efe5d7164dd2657b7ba3ad5, Token::BRACE_R);
        let tmpArrayac38a4fe9bb1f59f2b0c8e634325d3af = ["directives" : directives, "operationTypes" : operationTypes, "loc" : this->loc(start)];
        return new SchemaDefinitionNode(tmpArrayac38a4fe9bb1f59f2b0c8e634325d3af);
    }
    
    /**
     * @return OperationTypeDefinitionNode
     * @throws SyntaxError
     */
    function parseOperationTypeDefinition() -> <OperationTypeDefinitionNode>
    {
        var start, operation, type, tmpArrayc3e770fe88ca3b1b2b9b85ed121cb30c;
    
        let start =  this->lexer->token;
        let operation =  this->parseOperationType();
        this->expect(Token::COLON);
        let type =  this->parseNamedType();
        let tmpArrayc3e770fe88ca3b1b2b9b85ed121cb30c = ["operation" : operation, "type" : type, "loc" : this->loc(start)];
        return new OperationTypeDefinitionNode(tmpArrayc3e770fe88ca3b1b2b9b85ed121cb30c);
    }
    
    /**
     * @return ScalarTypeDefinitionNode
     * @throws SyntaxError
     */
    function parseScalarTypeDefinition() -> <ScalarTypeDefinitionNode>
    {
        var start, description, name, directives, tmpArray0150ac139d28c11902e74466bf746e57;
    
        let start =  this->lexer->token;
        let description =  this->parseDescription();
        this->expectKeyword("scalar");
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        let tmpArray0150ac139d28c11902e74466bf746e57 = ["name" : name, "directives" : directives, "loc" : this->loc(start), "description" : description];
        return new ScalarTypeDefinitionNode(tmpArray0150ac139d28c11902e74466bf746e57);
    }
    
    /**
     * @return ObjectTypeDefinitionNode
     * @throws SyntaxError
     */
    function parseObjectTypeDefinition() -> <ObjectTypeDefinitionNode>
    {
        var start, description, name, interfaces, directives, fields, tmpArrayc09d59adca0dc0c3b57a3ecc50edc32b;
    
        let start =  this->lexer->token;
        let description =  this->parseDescription();
        this->expectKeyword("type");
        let name =  this->parseName();
        let interfaces =  this->parseImplementsInterfaces();
        let directives =  this->parseDirectives(true);
        let fields =  this->parseFieldsDefinition();
        let tmpArrayc09d59adca0dc0c3b57a3ecc50edc32b = ["name" : name, "interfaces" : interfaces, "directives" : directives, "fields" : fields, "loc" : this->loc(start), "description" : description];
        return new ObjectTypeDefinitionNode(tmpArrayc09d59adca0dc0c3b57a3ecc50edc32b);
    }
    
    /**
     * @return NamedTypeNode[]
     */
    function parseImplementsInterfaces() -> array
    {
        var types;
    
        let types =  [];
        if this->lexer->token->value === "implements" {
            this->lexer->advance();
            do {
                let types[] =  this->parseNamedType();
            } while (this->peek(Token::NAME));
        }
        return types;
    }
    
    /**
     * @return FieldDefinitionNode[]|NodeList
     * @throws SyntaxError
     */
    function parseFieldsDefinition()
    {
        var tmpArraya4e28b48748e6364ec8bf360948d830c, tmpArray40cd750bba9870f18aada2478b24840a;
    
        let tmpArraya4e28b48748e6364ec8bf360948d830c = [this, "parseFieldDefinition"];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return  this->peek(Token::BRACE_L) ? this->many(Token::BRACE_L, tmpArraya4e28b48748e6364ec8bf360948d830c, Token::BRACE_R)  : new NodeList(tmpArray40cd750bba9870f18aada2478b24840a);
    }
    
    /**
     * @return FieldDefinitionNode
     * @throws SyntaxError
     */
    function parseFieldDefinition() -> <FieldDefinitionNode>
    {
        var start, description, name, args, type, directives, tmpArrayd88f1937cab2e33222fc46877d352d6d;
    
        let start =  this->lexer->token;
        let description =  this->parseDescription();
        let name =  this->parseName();
        let args =  this->parseArgumentDefs();
        this->expect(Token::COLON);
        let type =  this->parseTypeReference();
        let directives =  this->parseDirectives(true);
        let tmpArrayd88f1937cab2e33222fc46877d352d6d = ["name" : name, "arguments" : args, "type" : type, "directives" : directives, "loc" : this->loc(start), "description" : description];
        return new FieldDefinitionNode(tmpArrayd88f1937cab2e33222fc46877d352d6d);
    }
    
    /**
     * @return InputValueDefinitionNode[]|NodeList
     * @throws SyntaxError
     */
    function parseArgumentDefs()
    {
        var tmpArray40cd750bba9870f18aada2478b24840a, tmpArrayab716942889a79c0547f8683268d6ddd;
    
        if !(this->peek(Token::PAREN_L)) {
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            return new NodeList(tmpArray40cd750bba9870f18aada2478b24840a);
        }
        let tmpArrayab716942889a79c0547f8683268d6ddd = [this, "parseInputValueDef"];
        return this->many(Token::PAREN_L, tmpArrayab716942889a79c0547f8683268d6ddd, Token::PAREN_R);
    }
    
    /**
     * @return InputValueDefinitionNode
     * @throws SyntaxError
     */
    function parseInputValueDef() -> <InputValueDefinitionNode>
    {
        var start, description, name, type, defaultValue, directives, tmpArraydace3a1b86909bcfdc40679b7d0e806a;
    
        let start =  this->lexer->token;
        let description =  this->parseDescription();
        let name =  this->parseName();
        this->expect(Token::COLON);
        let type =  this->parseTypeReference();
        let defaultValue =  null;
        if this->skip(Token::EQUALS) {
            let defaultValue =  this->parseConstValue();
        }
        let directives =  this->parseDirectives(true);
        let tmpArraydace3a1b86909bcfdc40679b7d0e806a = ["name" : name, "type" : type, "defaultValue" : defaultValue, "directives" : directives, "loc" : this->loc(start), "description" : description];
        return new InputValueDefinitionNode(tmpArraydace3a1b86909bcfdc40679b7d0e806a);
    }
    
    /**
     * @return InterfaceTypeDefinitionNode
     * @throws SyntaxError
     */
    function parseInterfaceTypeDefinition() -> <InterfaceTypeDefinitionNode>
    {
        var start, description, name, directives, fields, tmpArray86743347992e6ca1f9564658c098c31a;
    
        let start =  this->lexer->token;
        let description =  this->parseDescription();
        this->expectKeyword("interface");
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        let fields =  this->parseFieldsDefinition();
        let tmpArray86743347992e6ca1f9564658c098c31a = ["name" : name, "directives" : directives, "fields" : fields, "loc" : this->loc(start), "description" : description];
        return new InterfaceTypeDefinitionNode(tmpArray86743347992e6ca1f9564658c098c31a);
    }
    
    /**
     * @return UnionTypeDefinitionNode
     * @throws SyntaxError
     */
    function parseUnionTypeDefinition() -> <UnionTypeDefinitionNode>
    {
        var start, description, name, directives, types, tmpArraye91d210e245128b4c7922be5d6b2768f;
    
        let start =  this->lexer->token;
        let description =  this->parseDescription();
        this->expectKeyword("union");
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        let types =  this->parseMemberTypesDefinition();
        let tmpArraye91d210e245128b4c7922be5d6b2768f = ["name" : name, "directives" : directives, "types" : types, "loc" : this->loc(start), "description" : description];
        return new UnionTypeDefinitionNode(tmpArraye91d210e245128b4c7922be5d6b2768f);
    }
    
    /**
     * MemberTypes :
     *   - `|`? NamedType
     *   - MemberTypes | NamedType
     *
     * @return NamedTypeNode[]
     */
    function parseMemberTypesDefinition() -> array
    {
        var types;
    
        let types =  [];
        if this->skip(Token::EQUALS) {
            // Optional leading pipe
            this->skip(Token::PIPE);
            do {
                let types[] =  this->parseNamedType();
            } while (this->skip(Token::PIPE));
        }
        return types;
    }
    
    /**
     * @return EnumTypeDefinitionNode
     * @throws SyntaxError
     */
    function parseEnumTypeDefinition() -> <EnumTypeDefinitionNode>
    {
        var start, description, name, directives, values, tmpArray1c91bb974ccd9625268b99252c647a7c;
    
        let start =  this->lexer->token;
        let description =  this->parseDescription();
        this->expectKeyword("enum");
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        let values =  this->parseEnumValuesDefinition();
        let tmpArray1c91bb974ccd9625268b99252c647a7c = ["name" : name, "directives" : directives, "values" : values, "loc" : this->loc(start), "description" : description];
        return new EnumTypeDefinitionNode(tmpArray1c91bb974ccd9625268b99252c647a7c);
    }
    
    /**
     * @return EnumValueDefinitionNode[]|NodeList
     * @throws SyntaxError
     */
    function parseEnumValuesDefinition()
    {
        var tmpArray3fdbba1f0fca6d2cb334ca9f85ef1642, tmpArray40cd750bba9870f18aada2478b24840a;
    
        let tmpArray3fdbba1f0fca6d2cb334ca9f85ef1642 = [this, "parseEnumValueDefinition"];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return  this->peek(Token::BRACE_L) ? this->many(Token::BRACE_L, tmpArray3fdbba1f0fca6d2cb334ca9f85ef1642, Token::BRACE_R)  : new NodeList(tmpArray40cd750bba9870f18aada2478b24840a);
    }
    
    /**
     * @return EnumValueDefinitionNode
     * @throws SyntaxError
     */
    function parseEnumValueDefinition() -> <EnumValueDefinitionNode>
    {
        var start, description, name, directives, tmpArraybee47a496796438fd5bc465716d0be49;
    
        let start =  this->lexer->token;
        let description =  this->parseDescription();
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        let tmpArraybee47a496796438fd5bc465716d0be49 = ["name" : name, "directives" : directives, "loc" : this->loc(start), "description" : description];
        return new EnumValueDefinitionNode(tmpArraybee47a496796438fd5bc465716d0be49);
    }
    
    /**
     * @return InputObjectTypeDefinitionNode
     * @throws SyntaxError
     */
    function parseInputObjectTypeDefinition() -> <InputObjectTypeDefinitionNode>
    {
        var start, description, name, directives, fields, tmpArray5a0ac2ae1eadde03d1dc7e54dd64086b;
    
        let start =  this->lexer->token;
        let description =  this->parseDescription();
        this->expectKeyword("input");
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        let fields =  this->parseInputFieldsDefinition();
        let tmpArray5a0ac2ae1eadde03d1dc7e54dd64086b = ["name" : name, "directives" : directives, "fields" : fields, "loc" : this->loc(start), "description" : description];
        return new InputObjectTypeDefinitionNode(tmpArray5a0ac2ae1eadde03d1dc7e54dd64086b);
    }
    
    /**
     * @return InputValueDefinitionNode[]|NodeList
     * @throws SyntaxError
     */
    function parseInputFieldsDefinition()
    {
        var tmpArray64c505cfaceeaa099a08101a3b895f3a, tmpArray40cd750bba9870f18aada2478b24840a;
    
        let tmpArray64c505cfaceeaa099a08101a3b895f3a = [this, "parseInputValueDef"];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return  this->peek(Token::BRACE_L) ? this->many(Token::BRACE_L, tmpArray64c505cfaceeaa099a08101a3b895f3a, Token::BRACE_R)  : new NodeList(tmpArray40cd750bba9870f18aada2478b24840a);
    }
    
    /**
     * TypeExtension :
     *   - ScalarTypeExtension
     *   - ObjectTypeExtension
     *   - InterfaceTypeExtension
     *   - UnionTypeExtension
     *   - EnumTypeExtension
     *   - InputObjectTypeDefinition
     *
     * @return TypeExtensionNode
     * @throws SyntaxError
     */
    function parseTypeExtension() -> <TypeExtensionNode>
    {
        var keywordToken;
    
        let keywordToken =  this->lexer->lookahead();
        if keywordToken->kind === Token::NAME {
            switch (keywordToken->value) {
                case "scalar":
                    return this->parseScalarTypeExtension();
                case "type":
                    return this->parseObjectTypeExtension();
                case "interface":
                    return this->parseInterfaceTypeExtension();
                case "union":
                    return this->parseUnionTypeExtension();
                case "enum":
                    return this->parseEnumTypeExtension();
                case "input":
                    return this->parseInputObjectTypeExtension();
            }
        }
        throw this->unexpected(keywordToken);
    }
    
    /**
     * @return ScalarTypeExtensionNode
     * @throws SyntaxError
     */
    function parseScalarTypeExtension() -> <ScalarTypeExtensionNode>
    {
        var start, name, directives, tmpArraycc0a88aef0504dce512fbebefd3d4885;
    
        let start =  this->lexer->token;
        this->expectKeyword("extend");
        this->expectKeyword("scalar");
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        if count(directives) === 0 {
            throw this->unexpected();
        }
        let tmpArraycc0a88aef0504dce512fbebefd3d4885 = ["name" : name, "directives" : directives, "loc" : this->loc(start)];
        return new ScalarTypeExtensionNode(tmpArraycc0a88aef0504dce512fbebefd3d4885);
    }
    
    /**
     * @return ObjectTypeExtensionNode
     * @throws SyntaxError
     */
    function parseObjectTypeExtension() -> <ObjectTypeExtensionNode>
    {
        var start, name, interfaces, directives, fields, tmpArraya1b6f825147467e96355831cdecece57;
    
        let start =  this->lexer->token;
        this->expectKeyword("extend");
        this->expectKeyword("type");
        let name =  this->parseName();
        let interfaces =  this->parseImplementsInterfaces();
        let directives =  this->parseDirectives(true);
        let fields =  this->parseFieldsDefinition();
        if !(interfaces) && count(directives) === 0 && count(fields) === 0 {
            throw this->unexpected();
        }
        let tmpArraya1b6f825147467e96355831cdecece57 = ["name" : name, "interfaces" : interfaces, "directives" : directives, "fields" : fields, "loc" : this->loc(start)];
        return new ObjectTypeExtensionNode(tmpArraya1b6f825147467e96355831cdecece57);
    }
    
    /**
     * @return InterfaceTypeExtensionNode
     * @throws SyntaxError
     */
    function parseInterfaceTypeExtension() -> <InterfaceTypeExtensionNode>
    {
        var start, name, directives, fields, tmpArray813aa60b7a8dd0b498cb874b6611ead2;
    
        let start =  this->lexer->token;
        this->expectKeyword("extend");
        this->expectKeyword("interface");
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        let fields =  this->parseFieldsDefinition();
        if count(directives) === 0 && count(fields) === 0 {
            throw this->unexpected();
        }
        let tmpArray813aa60b7a8dd0b498cb874b6611ead2 = ["name" : name, "directives" : directives, "fields" : fields, "loc" : this->loc(start)];
        return new InterfaceTypeExtensionNode(tmpArray813aa60b7a8dd0b498cb874b6611ead2);
    }
    
    /**
     * @return UnionTypeExtensionNode
     * @throws SyntaxError
     */
    function parseUnionTypeExtension() -> <UnionTypeExtensionNode>
    {
        var start, name, directives, types, tmpArray7f3ff1073529b0c7be0f88aaf20b5bcd;
    
        let start =  this->lexer->token;
        this->expectKeyword("extend");
        this->expectKeyword("union");
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        let types =  this->parseMemberTypesDefinition();
        if count(directives) === 0 && !(types) {
            throw this->unexpected();
        }
        let tmpArray7f3ff1073529b0c7be0f88aaf20b5bcd = ["name" : name, "directives" : directives, "types" : types, "loc" : this->loc(start)];
        return new UnionTypeExtensionNode(tmpArray7f3ff1073529b0c7be0f88aaf20b5bcd);
    }
    
    /**
     * @return EnumTypeExtensionNode
     * @throws SyntaxError
     */
    function parseEnumTypeExtension() -> <EnumTypeExtensionNode>
    {
        var start, name, directives, values, tmpArray28b6c9432683605574cae60ce5fc99c9;
    
        let start =  this->lexer->token;
        this->expectKeyword("extend");
        this->expectKeyword("enum");
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        let values =  this->parseEnumValuesDefinition();
        if count(directives) === 0 && count(values) === 0 {
            throw this->unexpected();
        }
        let tmpArray28b6c9432683605574cae60ce5fc99c9 = ["name" : name, "directives" : directives, "values" : values, "loc" : this->loc(start)];
        return new EnumTypeExtensionNode(tmpArray28b6c9432683605574cae60ce5fc99c9);
    }
    
    /**
     * @return InputObjectTypeExtensionNode
     * @throws SyntaxError
     */
    function parseInputObjectTypeExtension() -> <InputObjectTypeExtensionNode>
    {
        var start, name, directives, fields, tmpArray1794cef740a4e93e39fbd6d9791b76b1;
    
        let start =  this->lexer->token;
        this->expectKeyword("extend");
        this->expectKeyword("input");
        let name =  this->parseName();
        let directives =  this->parseDirectives(true);
        let fields =  this->parseInputFieldsDefinition();
        if count(directives) === 0 && count(fields) === 0 {
            throw this->unexpected();
        }
        let tmpArray1794cef740a4e93e39fbd6d9791b76b1 = ["name" : name, "directives" : directives, "fields" : fields, "loc" : this->loc(start)];
        return new InputObjectTypeExtensionNode(tmpArray1794cef740a4e93e39fbd6d9791b76b1);
    }
    
    /**
     * DirectiveDefinition :
     *   - directive @ Name ArgumentsDefinition? on DirectiveLocations
     *
     * @return DirectiveDefinitionNode
     * @throws SyntaxError
     */
    function parseDirectiveDefinition() -> <DirectiveDefinitionNode>
    {
        var start, description, name, args, locations, tmpArray4090bd1a72e32d5449ba2b4d702c46c8;
    
        let start =  this->lexer->token;
        let description =  this->parseDescription();
        this->expectKeyword("directive");
        this->expect(Token::AT);
        let name =  this->parseName();
        let args =  this->parseArgumentDefs();
        this->expectKeyword("on");
        let locations =  this->parseDirectiveLocations();
        let tmpArray4090bd1a72e32d5449ba2b4d702c46c8 = ["name" : name, "arguments" : args, "locations" : locations, "loc" : this->loc(start), "description" : description];
        return new DirectiveDefinitionNode(tmpArray4090bd1a72e32d5449ba2b4d702c46c8);
    }
    
    /**
     * @return NameNode[]
     * @throws SyntaxError
     */
    function parseDirectiveLocations() -> array
    {
        var locations;
    
        // Optional leading pipe
        this->skip(Token::PIPE);
        let locations =  [];
        do {
            let locations[] =  this->parseDirectiveLocation();
        } while (this->skip(Token::PIPE));
        return locations;
    }
    
    /**
     * @return NameNode
     * @throws SyntaxError
     */
    function parseDirectiveLocation() -> <NameNode>
    {
        var start, name;
    
        let start =  this->lexer->token;
        let name =  this->parseName();
        if DirectiveLocation::has(name->value) {
            return name;
        }
        throw this->unexpected(start);
    }

}