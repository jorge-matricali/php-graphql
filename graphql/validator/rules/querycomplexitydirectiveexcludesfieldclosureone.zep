namespace GraphQL\Validator\Rules;

class QueryComplexitydirectiveExcludesFieldClosureOne
{

    public function __construct()
    {
        
    }

    public function __invoke(error)
    {
    return error->getMessage();
    }
}
    