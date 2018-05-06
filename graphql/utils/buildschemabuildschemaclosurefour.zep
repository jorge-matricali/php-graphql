namespace GraphQL\Utils;

class BuildSchemabuildSchemaClosureFour
{

    public function __construct()
    {
        
    }

    public function __invoke(hasDeprecated, directive)
    {
    return hasDeprecated || directive->name == "deprecated";
    }
}
    