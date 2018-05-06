namespace GraphQL\Utils;

class astvalueFromASTClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(field)
    {
    return field->name->value;
    }
}
    