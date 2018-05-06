namespace GraphQL\Validator\Rules;

class KnownTypeNamesgetVisitorClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke()
    {
    return Visitor::skipNode();
    }
}
    