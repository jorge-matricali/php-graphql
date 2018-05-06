namespace GraphQL\Error;

use GraphQL\Language\Source;
class SyntaxError extends Error
{
    /**
     * @param Source $source
     * @param int $position
     * @param string $description
     */
    public function __construct(<Source> source, int position, string description) -> void
    {
        var tmpArrayc89c9f64485fdd0ca8c11f84c125d688;
    
        parent::__construct("Syntax Error: {description}", null, source, [position]);
    }

}