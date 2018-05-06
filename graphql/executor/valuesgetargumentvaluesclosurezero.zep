namespace GraphQL\Executor;

class ValuesgetArgumentValuesClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(ArgumentNode arg)
    {
    return arg->name->value;
    }
}
    