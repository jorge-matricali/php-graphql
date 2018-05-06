namespace GraphQL\Type;

class SchemaConfigcreateClosureZero
{
    private strategy;

    public function __construct(strategy)
    {
                let this->strategy = strategy;

    }

    public function __invoke(name)
    {
    return this->strategy->resolveType(name);
    }
}
    