namespace GraphQL\Server;

class HelperresolveHttpStatusClosureThree
{

    public function __construct()
    {
        
    }

    public function __invoke(executionResult, index)
    {
    if !(executionResult instanceof ExecutionResult) {
        throw new InvariantViolation(sprintf("Expecting every entry of batched query result to be instance of %s but entry at position %d is %s", ExecutionResult::class, index, Utils::printSafe(executionResult)));
    }
    }
}
    