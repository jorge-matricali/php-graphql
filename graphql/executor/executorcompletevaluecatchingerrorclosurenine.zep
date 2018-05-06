namespace GraphQL\Executor;

class ExecutorcompleteValueCatchingErrorClosureNine
{
    private exeContext;

    public function __construct(exeContext)
    {
                let this->exeContext = exeContext;

    }

    public function __invoke(error)
    {
    this->exeContext->addError(error);
    return this->exeContext->promises->createFulfilled(null);
    }
}
    