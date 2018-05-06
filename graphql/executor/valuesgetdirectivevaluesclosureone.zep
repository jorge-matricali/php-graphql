namespace GraphQL\Executor;

class ValuesgetDirectiveValuesClosureOne
{
    private directiveDef;

    public function __construct(directiveDef)
    {
                let this->directiveDef = directiveDef;

    }

    public function __invoke(DirectiveNode directive)
    {
    return directive->name->value === this->directiveDef->name;
    }
}
    