namespace GraphQL\Executor;

class ExecutionResulttoArrayClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(array errors, callable formatter)
    {
    return array_map(formatter, errors);
    }
}
    