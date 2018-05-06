namespace GraphQL\Executor;

class ExecutordoExecuteClosureOne
{

    public function __construct()
    {
        
    }

    public function __invoke(error)
    {
    // Errors from sub-fields of a NonNull type may propagate to the top level,
    // at which point we still log the error and null the parent field, which
    // in this case is the entire response.
    this->exeContext->addError(error);
    return null;
    }
}
    