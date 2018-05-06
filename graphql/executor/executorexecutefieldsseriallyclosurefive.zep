namespace GraphQL\Executor;

class ExecutorexecuteFieldsSeriallyClosureFive
{
    private responseName;
    private results;

    public function __construct(responseName, results)
    {
                let this->responseName = responseName;
        let this->results = results;

    }

    public function __invoke(resolvedResult)
    {
    this->results[this->responseName];
    return this->results;
    }
}
    