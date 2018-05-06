namespace GraphQL\Utils;

class BuildSchemabuildSchemaClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(typeName)
    {
    throw new Error("Type \"" . typeName . "\" not found in document.");
    }
}
    