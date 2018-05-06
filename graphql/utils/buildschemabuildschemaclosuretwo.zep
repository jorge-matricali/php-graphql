namespace GraphQL\Utils;

class BuildSchemabuildSchemaClosureTwo
{

    public function __construct()
    {
        
    }

    public function __invoke(hasSkip, directive)
    {
    return hasSkip || directive->name == "skip";
    }
}
    