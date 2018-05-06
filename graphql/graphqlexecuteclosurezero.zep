namespace GraphQL;

class GraphQLexecuteClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(ExecutionResult r)
    {
    return r->toArray();
    }
}
    