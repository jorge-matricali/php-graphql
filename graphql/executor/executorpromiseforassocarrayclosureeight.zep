namespace GraphQL\Executor;

class ExecutorpromiseForAssocArrayClosureEight
{
    private keys;

    public function __construct(keys)
    {
                let this->keys = keys;

    }

    public function __invoke(values)
    {
    resolvedResults;
    for i, value in values {
        resolvedResults[this->keys[i]];
    }
    return self::fixResultsIfEmptyArray(resolvedResults);
    }
}
    