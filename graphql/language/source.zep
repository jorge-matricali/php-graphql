namespace GraphQL\Language;

use GraphQL\Utils\Utils;
/**
 * Class Source
 * @package GraphQL\Language
 */
class Source
{
    /**
     * @var string
     */
    public body;
    /**
     * @var int
     */
    public length;
    /**
     * @var string
     */
    public name;
    /**
     * @var SourceLocation
     */
    public locationOffset;
    /**
     * Source constructor.
     *
     * A representation of source input to GraphQL.
     * `name` and `locationOffset` are optional. They are useful for clients who
     * store GraphQL documents in source files; for example, if the GraphQL input
     * starts at line 40 in a file named Foo.graphql, it might be useful for name to
     * be "Foo.graphql" and location to be `{ line: 40, column: 0 }`.
     * line and column in locationOffset are 1-indexed
     *
     * @param string $body
     * @param string|null $name
     * @param SourceLocation|null $location
     */
    public function __construct(string body, name = null, <SourceLocation> location = null) -> void
    {
        Utils::invariant(is_string(body), "GraphQL query body is expected to be string, but got " . Utils::getVariableType(body));
        let this->body = body;
        let this->length =  mb_strlen(body, "UTF-8");
        let this->name =  name ? name : "GraphQL request";
        let this->locationOffset =  location ? location : new SourceLocation(1, 1);
        Utils::invariant(this->locationOffset->line > 0, "line in locationOffset is 1-indexed and must be positive");
        Utils::invariant(this->locationOffset->column > 0, "column in locationOffset is 1-indexed and must be positive");
    }
    
    /**
     * @param $position
     * @return SourceLocation
     */
    public function getLocation(position) -> <SourceLocation>
    {
        var line, column, utfChars, lineRegexp, matches, index, match;
    
        let line = 1;
        let column =  position + 1;
        let utfChars =  json_decode("\"\\u2028\\u2029\"");
        let lineRegexp =  "/\\r\\n|[\\n\\r" . utfChars . "]/su";
        let matches =  [];
        preg_match_all(lineRegexp, mb_substr(this->body, 0, position, "UTF-8"), matches, PREG_OFFSET_CAPTURE);
        for index, match in matches[0] {
            let line += 1;
            let column =  position + 1 - (match[1] + mb_strlen(match[0], "UTF-8"));
        }
        return new SourceLocation(line, column);
    }

}