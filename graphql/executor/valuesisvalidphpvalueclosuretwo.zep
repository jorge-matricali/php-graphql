namespace GraphQL\Executor;

class ValuesisValidPHPValueClosureTwo
{

    public function __construct()
    {
        
    }

    public function __invoke(error)
    {
    return error->getMessage();
    }
}
    