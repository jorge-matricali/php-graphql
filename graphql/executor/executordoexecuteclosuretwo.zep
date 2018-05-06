namespace GraphQL\Executor;

class ExecutordoExecuteClosureTwo
{

    public function __construct()
    {
        
    }

    public function __invoke(data)
    {
    return new ExecutionResult((array) data, this->exeContext->errors);
    }
}
    