namespace GraphQL\Error;

class ErrorgetPositionsClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(node)
    {
    return  isset node->loc ? node->loc->start  : null;
    }
}
    