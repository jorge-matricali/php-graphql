namespace GraphQL\Language\AST;

use GraphQL\Language\Source;
use GraphQL\Language\Token;
/**
 * Contains a range of UTF-8 character offsets and token references that
 * identify the region of the source from which the AST derived.
 */
class Location
{
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
     * The Token at which this Node begins.
     *
     * @var Token
     */
    public startToken;
    /**
     * The Token at which this Node ends.
     *
     * @var Token
     */
    public endToken;
    /**
     * The Source document the AST represents.
     *
     * @var Source|null
     */
    public source;
    /**
     * @param $start
     * @param $end
     * @return static
     */
    public static function create(start, end) -> <static>
    {
        var tmp;
    
        let tmp =  new static();
        let tmp->start = start;
        let tmp->end = end;
        return tmp;
    }
    
    public function __construct(<Token> startToken = null, <Token> endToken = null, <Source> source = null) -> void
    {
        let this->startToken = startToken;
        let this->endToken = endToken;
        let this->source = source;
        if startToken && endToken {
            let this->start =  startToken->start;
            let this->end =  endToken->end;
        }
    }

}