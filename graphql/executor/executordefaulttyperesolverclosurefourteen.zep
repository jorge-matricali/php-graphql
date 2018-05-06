namespace GraphQL\Executor;

class ExecutordefaultTypeResolverClosureFourteen
{
    private possibleTypes;

    public function __construct(possibleTypes)
    {
                let this->possibleTypes = possibleTypes;

    }

    public function __invoke(isTypeOfResults)
    {
    for index, result in isTypeOfResults {
        if result {
            return this->possibleTypes[index];
        }
    }
    return null;
    }
}
    