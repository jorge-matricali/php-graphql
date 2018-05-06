namespace GraphQL\Executor\Promise\Adapter;

class ReactPromiseAdapterallClosureOne
{
    private promisesOrValues;

    public function __construct(promisesOrValues)
    {
                let this->promisesOrValues = promisesOrValues;

    }

    public function __invoke(values)
    {
    orderedResults;
    for key, value in this->promisesOrValues {
        orderedResults[key];
    }
    return orderedResults;
    }
}
    