namespace GraphQL\Type;

class Introspection_schemaClosureFour
{

    public function __construct()
    {
        
    }

    public function __invoke(Schema schema)
    {
    return schema->getDirectives();
    }
}
    