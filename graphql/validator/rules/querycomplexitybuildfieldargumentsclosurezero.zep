namespace GraphQL\Validator\Rules;

class QueryComplexitybuildFieldArgumentsClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(error)
    {
    return error->getMessage();
    }
}
    