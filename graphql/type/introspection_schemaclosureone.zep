namespace GraphQL\Type;

class Introspection_schemaClosureOne
{

    public function __construct()
    {
        
    }

    public function __invoke(Schema schema)
    {
    return schema->getQueryType();
    }
}
    