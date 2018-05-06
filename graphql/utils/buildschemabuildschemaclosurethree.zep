namespace GraphQL\Utils;

class BuildSchemabuildSchemaClosureThree
{

    public function __construct()
    {
        
    }

    public function __invoke(hasInclude, directive)
    {
    return hasInclude || directive->name == "include";
    }
}
    