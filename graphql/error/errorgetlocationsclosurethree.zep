namespace GraphQL\Error;

class ErrorgetLocationsClosureThree
{

    public function __construct()
    {
        
    }

    public function __invoke(node)
    {
    if node->loc {
        return node->loc->source->getLocation(node->loc->start);
    }
    }
}
    