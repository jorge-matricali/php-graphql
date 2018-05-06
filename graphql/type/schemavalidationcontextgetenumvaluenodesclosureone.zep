namespace GraphQL\Type;

class SchemaValidationContextgetEnumValueNodesClosureOne
{
    private valueName;

    public function __construct(valueName)
    {
                let this->valueName = valueName;

    }

    public function __invoke(EnumValueDefinitionNode value)
    {
    return value->name->value === this->valueName;
    }
}
    