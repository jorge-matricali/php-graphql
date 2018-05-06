namespace GraphQL\Utils;

class SchemaPrinterdoPrintClosureOne
{

    public function __construct()
    {
        
    }

    public function __invoke(type)
    {
    return !(Type::isBuiltInType(type));
    }
}
    