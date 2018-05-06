namespace GraphQL\Utils;

class astvalueFromASTUntypedClosureThree
{
    private variables;

    public function __construct(variables)
    {
                let this->variables = variables;

    }

    public function __invoke(field)
    {
    return self::valueFromASTUntyped(field->value, this->variables);
    }
}
    