namespace GraphQL\Utils;

class astvalueFromASTUntypedClosureOne
{
    private variables;

    public function __construct(variables)
    {
                let this->variables = variables;

    }

    public function __invoke(node)
    {
    return self::valueFromASTUntyped(node, this->variables);
    }
}
    