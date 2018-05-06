namespace GraphQL\Type;

class SchemaValidationContextgetUnionMemberTypeNodesClosureZero
{
    private typeName;

    public function __construct(typeName)
    {
                let this->typeName = typeName;

    }

    public function __invoke(NamedTypeNode value)
    {
    return value->name->value === this->typeName;
    }
}
    