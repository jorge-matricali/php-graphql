namespace GraphQL\Type;

class Introspection_schemaClosureThree
{

    public function __construct()
    {
        
    }

    public function __invoke(Schema schema)
    {
    return schema->getSubscriptionType();
    }
}
    