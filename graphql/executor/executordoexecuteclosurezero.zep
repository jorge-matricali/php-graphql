namespace GraphQL\Executor;

class ExecutordoExecuteClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(callable resolve)
    {
    return {resolve}(this->executeOperation(this->exeContext->operation, this->exeContext->rootValue));
    }
}
    