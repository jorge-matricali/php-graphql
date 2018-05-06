namespace GraphQL\Type;

class Introspection_schemaClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(Schema schema)
    {
    return array_values(schema->getTypeMap());
    }
}
    