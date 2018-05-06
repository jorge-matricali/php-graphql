namespace GraphQL\Executor;

class ExecutorexecuteOperationClosureThree
{

    public function __construct()
    {
        
    }

    public function __invoke(error)
    {
    this->exeContext->addError(error);
    return null;
    }
}
    