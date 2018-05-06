namespace GraphQL\Type;

class Introspection_schemaClosureTwo
{

    public function __construct()
    {
        
    }

    public function __invoke(Schema schema)
    {
    return schema->getMutationType();
    }
}
    